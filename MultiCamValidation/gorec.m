% the main script for the multicamera validation
% reads the points and the camera matrices
% and does 3D reconstructions 
% evaluates the reprojection errors
% to check whether the P matrices still hold or not
%
% $Id: gorec.m,v 2.1 2005/05/23 16:22:51 svoboda Exp $

clear all;

% add necessary paths
addpath ../CommonCfgAndIO
addpath ./CoreFunctions
addpath ./InputOutputFunctions
addpath ../RansacM; % ./Ransac for mex functions (it is significantly faster for noisy data)

% get the configuration						
config = configdata(expname);

UNDO_RADIAL = logical(config.cal.UNDO_RADIAL | config.cal.UNDO_HEIKK);

if UNDO_RADIAL
	% add functions dealing with radial distortion
	addpath ../RadialDistortions
end

% read the input data
loaded = loaddata(config);
linear = loaded;		% initalize the linear structure

CAMS = size(config.cal.cams2use,2);
FRAMES = size(loaded.IdMat,2);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% See the README how to compute data
% for undoing of the radial distortion
if config.cal.UNDO_RADIAL
  for i=1:CAMS,
	[K,kc] = readradfile(sprintf(config.files.rad,config.cal.cams2use(i)));
	xn	   = undoradial(loaded.Ws(i*3-2:i*3,:),K,[kc,0]);
	linear.Ws(i*3-2:i*3,:) = xn;
  end
elseif config.cal.UNDO_HEIKK,
  for i=1:CAMS,
	heikkpar = load(sprintf(config.files.heikkrad,config.cal.cams2use(i)),'-ASCII');
	xn = undoheikk(heikkpar(1:4),heikkpar(5:end),loaded.Ws(i*3-2:i*3-1,:)');
	linear.Ws(i*3-2:i*3-1,:) = xn';
  end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Detection of outliers
% RANSAC is pairwise applied
disp('RANSAC validation step running ...');

inl.IdMat = findinl(linear.Ws,linear.IdMat,config.cal.INL_TOL);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% fill cam(i) structures
for i=1:CAMS,
  cam(i).camId     = config.cal.cams2use(i);
  cam(i).ptsLoaded = find(loaded.IdMat(i,:)); % loaded structure
  cam(i).ptsInl	   = find(inl.IdMat(i,:));	% survived initial pairwise validation
  cam(i).xgt	   = loaded.Ws(3*i-2:3*i,cam(i).ptsLoaded);
  cam(i).xlin	   = linear.Ws(3*i-2:3*i,cam(i).ptsLoaded);
  cam(i).xgtin	   = loaded.Ws(3*i-2:3*i,cam(i).ptsInl);
  cam(i).P		   = loaded.Pmat{i};
  [cam(i).K, cam(i).R, cam(i).t, cam(i).C] = P2KRtC(cam(i).P);
end

% estimate the working volume which is
% the intersection of the view cones
disp('Computing maximal possible working volume')
tic,
[workingvolume.Xmat,workingvolume.idxisa] = workvolume(cam);
toc
% plot3(workingvolume.Xmat(workingvolume.idxisa,1),workingvolume.Xmat(workingvolume.idxisa,2),workingvolume.Xmat(workingvolume.idxisa,3),'.')
Rmat =[];
for i=1:CAMS
	Rmat = [Rmat;cam(i).R];
end
drawscene(workingvolume.Xmat(workingvolume.idxisa,:)',[cam(:).C],Rmat,3,'cloud','Maximal working volume',[cam(:).camId]);
drawnow


disp('***********************************************************')
disp('Computing a robust 3D reconstruction via camera sampling ...')
% compute a reconstruction robustly

t1 = cputime;
reconstructed = estimateX(linear,inl.IdMat,cam,config);
reconstructed.CamIds = config.cal.cams2use(reconstructed.CamIdx);
t2 = cputime;
disp(sprintf('Elapsed time for 3D computation: %d minutes %d seconds',floor((t2-t1)/60), round(mod((t2-t1),60))))

% compute reprojections
for i=1:CAMS,
  xe		= linear.Pmat{i}*reconstructed.X;
  cam(i).xe	= xe./repmat(xe(3,:),3,1);
  
  % these points were the input into Martinec and Pajdla filling
  mask.rec = zeros(1,FRAMES);	% mask of points that survived validation so far
  mask.vis = zeros(1,FRAMES); % maks of visible points
  mask.rec(reconstructed.ptsIdx)  = 1;
  mask.vis(cam(i).ptsLoaded) = 1;
  mask.both			   = mask.vis & mask.rec; % which points are visible and reconstructed for a particular camera
  unmask.rec			   = cumsum(mask.rec);
  unmask.vis			   = cumsum(mask.vis);
  cam(i).recandvis = unmask.rec(~xor(mask.rec,mask.both) & mask.rec);
  cam(i).visandrec = unmask.vis(~xor(mask.rec,mask.both) & mask.rec);
  cam(i).err2d	 = sqrt(sum([cam(i).xe(1:2,cam(i).recandvis) - cam(i).xlin(1:2,cam(i).visandrec)].^2));
  cam(i).mean2Derr = mean(cam(i).err2d);
  cam(i).std2Derr  = std(cam(i).err2d);
end

% plot measured and reprojected 2D points
for i=1:CAMS
  figure(i+10)
  clf	
  plot(cam(i).xgt(1,:),cam(i).xgt(2,:),'ro');
  hold on, grid on
  plot(cam(i).xgtin(1,:),cam(i).xgtin(2,:),'bo');
  plot(cam(i).xlin(1,:),cam(i).xlin(2,:),'go');
  plot(cam(i).xe(1,:),cam(i).xe(2,:),'k+')
  title(sprintf('measured, o, vs reprojected, +,  2D points (camera: %d)',config.cal.cams2use(i)));
  for j=1:size(cam(i).visandrec,2); % plot the reprojection errors
	line([cam(i).xlin(1,cam(i).visandrec(j)),cam(i).xe(1,cam(i).recandvis(j))],[cam(i).xlin(2,cam(i).visandrec(j)),cam(i).xe(2,cam(i).recandvis(j))],'Color','g');
  end
  % draw the image boarder
  line([0 0 0 loaded.Res(i,1) loaded.Res(i,1) loaded.Res(i,1) loaded.Res(i,1) 0],[0 loaded.Res(i,2) loaded.Res(i,2) loaded.Res(i,2) loaded.Res(i,2) 0 0 0],'Color','k','LineWidth',2,'LineStyle','--')
  axis('equal')
end

% plot the 3D points
figure(100),
clf
plot3(reconstructed.X(1,:),reconstructed.X(2,:),reconstructed.X(3,:),'*');
grid on

figure(31)
clf
bar(config.cal.cams2use,[cam.mean2Derr;cam.std2Derr]',1.5)
grid on
xlabel('Id of the camera')
title('2D error: mean (blue), std (red)')
ylabel('pixels')

%%%
% print the results in a text form
reconstructed

%%%
% save the data for non-linear estimation
% the idea is to apply the caltech non-linear optimization
% or any other alternative traditional calibration method to the 
% robustly reconstructed points. These 3D points will play the role
% of a calibration grid.
%
% It is also assumed that the majority of the cameras are good to produce
% acceptable 3D points. Othewise, we are trying to perform the calibration by using
% a bad calibration grid
%
% This assumes sufficient overlap between cameras. No point filling applied
%
% 3D-2D correspondences is needed for each camera
for i=1:CAMS,
  xe = loaded.Ws(i*3-2:i*3, reconstructed.ptsIdx(logical(loaded.IdMat(i,reconstructed.ptsIdx))));
  Xe = reconstructed.X(:, logical(loaded.IdMat(i,reconstructed.ptsIdx)));
  corresp = [Xe',xe'];
  save(sprintf(config.files.points4cal,config.cal.cams2use(i)),'corresp','-ASCII');
end
																				
