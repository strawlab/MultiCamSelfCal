% im2pointsLocally    computes image statistics from several images
%                     and finds the projections of laser points
%
% The version for local computation on each machine
%
% The computation core is taken from  im2points.m
% computes average image and image of standard deviations
% requires configdata.m
% The name of the experiment has to be specified
% it determines the location of files etc ...
%
% the scripts serves as a template for a multiprocessing
% it assumes a vector of camera IDs CamIds to be known
% indexes in the CamIds are supposed to be correct
%

donefile = '.done';

addpath /home/svoboda/Work/BlueCCal/BlueCFindingPoints

% config = localconfig('BlueCHoengg')
config = localconfig('BlueCRZ')

STEP4STAT = 5; % step for computing average and std images, if 1 then all images taken

im.dir = config.paths.data;
im.ext = config.files.imgext;

% get the information about machine
machinename = getenv('HOST');
CamsIds = str2num(machinename(find(machinename>47 & machinename<58)));

NoCams = size(CamsIds,2);
CamsIds

% load image names
for i=1:NoCams,
  seq(i).camId = CamsIds(i);
  if seq(i).camId > -1
	seq(i).data = dir([sprintf(im.dir,seq(i).camId),sprintf(config.files.imnames,seq(i).camId),im.ext]);
	[sprintf(im.dir,seq(i).camId),sprintf(config.files.imnames,seq(i).camId),im.ext]
  else
	seq(i).data = dir([im.dir,sprintf(config.files.imnames),im.ext]);
  end
  seq(i).size = size(seq(i).data,1);
  if seq(i).size<4
	i, seq
	error('Not enough images found. Wrong image path or name pattern?');
  end
end

% Expected number of 3D points is equal to the number of frames.
% In fact, some frames might be without any calibration point

% Because of non-consistent stopping of capturing, the sequences might 
% have different number of images, select the minimal value as the right one
NoPoints = min([seq.size]);

% compute the average images that will be used for finding LEDs
% if not already computed

pointsIdx = [1:STEP4STAT:NoPoints];

t = cputime;
for i=1:NoCams,
  if ~exist(sprintf(config.files.avIM,seq(i).camId)),
	disp(sprintf('The average image of the camera %d is being computed',seq(i).camId));
	avIM = zeros(size(imread([sprintf(im.dir,seq(i).camId),seq(i).data(1).name])));
	for j=pointsIdx,
	  IM = imread([sprintf(im.dir,seq(i).camId),seq(i).data(j).name]);
	  avIM = avIM + double(IM);
	end
	avIM = uint8(round(avIM./size(pointsIdx,2)));
	imwrite(avIM,sprintf(config.files.avIM,seq(i).camId));
  else	disp('Average files already exist');
  end
end
disp(sprintf('Elapsed time for average images: %d [sec]',cputime-t))
% compute the standard deviations images that will be used for finding LEDs
% if not already computed
t = cputime;
for i=1:NoCams,
  if ~exist(sprintf(config.files.stdIM,seq(i).camId)),
	avIM = double(imread(sprintf(config.files.avIM,seq(i).camId)));
	disp(sprintf('The image of standard deviations of the camera %d is being computed',seq(i).camId));
	stdIM = zeros(size(imread([sprintf(im.dir,seq(i).camId),seq(i).data(1).name])));
	for j=pointsIdx,
	  IM = imread([sprintf(im.dir,seq(i).camId),seq(i).data(j).name]);
	  stdIM = stdIM + (double(IM)-avIM).^2;
	end
	stdIM = uint8(round(sqrt(stdIM./(size(pointsIdx,2)-1))));
	imwrite(stdIM,sprintf(config.files.stdIM,seq(i).camId));
  else
	disp('Image of standard deviations already exist')
  end
end
disp(sprintf('Elapsed time for computation of images [sec]: %d',cputime-t))

% find points in the images
Ws    = [];
IdWs  = [];
Res	  = [];

IdMat = ones(NoCams,NoPoints); 
% IdMat is very important for Martinec&Pajdla filling [ECCV2002]
% it is a NoCams x NoPoints matrix, 
% IdMat(i,j) = 0 -> no j-th point in i-th
% IdMat(i,j) = 1 -> point successfully detected

for i=1:NoCams,
  Points = [];
  avIM  = imread(sprintf(config.files.avIM,seq(i).camId));
  stdIM	= imread(sprintf(config.files.stdIM,seq(i).camId));
  for j=1:NoPoints,
	[pos,err] = getpoint([sprintf(im.dir,seq(i).camId),seq(i).data(j).name], 0, config.imgs, avIM, stdIM);
	if err	  
	  IdMat(i,j) = 0;
	  Points = [Points, [NaN; NaN; NaN]];
	else
	  Points = [Points, [pos; 1]];
	end
  end
  Ws = [Ws; Points];
  Res= [Res; size(avIM,2), size(avIM,1)];
end

idx = '.';
for i=CamsIds,
  idx = sprintf('%s%02d',idx,i);
end
	
save([config.files.points,idx], 'Ws','-ASCII')
% save(config.files.IdPoints,'IdWs','-ASCII')
save([config.files.Res,idx], 'Res', '-ASCII')
save([config.files.IdMat,idx], 'IdMat', '-ASCII')

% write auxiliary file that is done
done=1;
save(donefile,'done','-ascii');

% exit the Matlab
% this script is to be used in the batch mode
% hence exit at the end is necessary
exit;
