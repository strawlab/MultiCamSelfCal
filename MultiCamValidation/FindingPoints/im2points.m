% Read all images and extract point coordinates.
%
% All information needed are stored and retrieved 
% from the function CONFIGDATA

% $Author: svoboda $
% $Revision: 2.0 $
% $Id: im2points.m,v 2.0 2003/06/19 12:07:11 svoboda Exp $
% $State: Exp $

clear all;

% add path to config data
addpath ../Cfg
% add path for graphical output if needed
addpath ../OutputFunctions

SHOWFIG	  = 0; % show images during point extraction
STEP4STAT = 5; % step for computing average and std images, if 1 then all images taken

config = configdata(expname);

im.dir = config.paths.img;
im.ext = config.files.imgext;

NoCams = size(config.files.idxcams,2);	% number of cameras 

% load image names
for i=1:NoCams,
  seq(i).camId = config.files.idxcams(i);
  if seq(i).camId > -1
	if findstr(expname,'oscar')
	  seq(i).data = dir([sprintf(im.dir,seq(i).camId),config.files.imnames,'*.',im.ext]);
	else
	  seq(i).data = dir([sprintf(im.dir,seq(i).camId),sprintf(config.files.imnames,seq(i).camId),im.ext]);
	end
  else
	seq(i).data = dir([im.dir,sprintf(config.files.imnames),im.ext]);
  end
  seq(i).size = size(seq(i).data,1);
  if seq(i).size<4
	error('Not enough images found. Wrong image path or name pattern?');
  end
end

% Expected number of 3D points is equal to the number of frames.
% In fact, some frames might be without any calibration point

% Becouse of non-consistent stopping of capturing, the sequences might 
% have different number of images, select the minimal value as the right one
NoPoints = min([seq.size]);
pointsIdx = [1:STEP4STAT:NoPoints];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% beginning of the findings

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
Ws    = [];	  % joint image matrix
Res	  = [];	  % resolution of cameras
IdMat = ones(NoCams,NoPoints); 
% IdMat is very important for Martinec&Pajdla filling [ECCV2002]
% it is a NoCams x NoPoints matrix, 
% IdMat(i,j) = 0 -> no j-th point in i-th
% IdMat(i,j) = 1 -> point successfully detected


disp('*********************************************')
disp('Finding points (laser projections) in cameras')
disp(sprintf('Totally %d cameras, %d images for each cam', NoCams, NoPoints'))
disp('*********************************************')
for i=1:NoCams,
  t1 = cputime;
  disp(sprintf('Finding points in camera No: %0.2d',config.files.idxcams(i)))
  Points = [];
  avIM  = imread(sprintf(config.files.avIM,seq(i).camId));
  stdIM	= imread(sprintf(config.files.stdIM,seq(i).camId));
  for j=1:NoPoints,
	[pos,err] = getpoint([sprintf(im.dir,seq(i).camId),seq(i).data(j).name], SHOWFIG, config.imgs, avIM, stdIM);
	if err	  
	  IdMat(i,j) = 0;
	  Points = [Points, [NaN; NaN; NaN]];
	else
	  Points = [Points, [pos; 1]];
	end
  end
  Ws = [Ws; Points];
  Res= [Res; size(avIM,2), size(avIM,1)];
  t2 = cputime;
  disp(sprintf('Elapsed time for finding points in one camera: %d minutes %d seconds',floor((t2-t1)/60), round(mod((t2-t1),60))))
end

%%% End of the findings
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if findstr(expname,'oscar')
  % needs special care for handling projector data
  ProjPoints = load(config.files.projdata,'-ASCII');
  Ws = [Ws; ProjPoints(:,2:3)'; ones(size(ProjPoints(:,1)'))];
  IdMat = [IdMat; ones(size(ProjPoints(:,1)'))];
  Res	= [Res; config.imgs.projres];
end

save(config.files.points, 'Ws','-ASCII')
save(config.files.Res, 'Res', '-ASCII')
save(config.files.IdMat, 'IdMat', '-ASCII')

% display the overall statistics 
disp('Overall statistics from im2points:  ************************  ')
disp(sprintf('Total number of frames (possible 3D points): %d',NoPoints))
disp(sprintf('Total number of cameras %d', NoCams))
disp('More important statistics: *********************************  ')
disp(sprintf('Detected 3D points:                    %d', sum(sum(IdMat)>0)))
disp(sprintf('Detected 3D points in at least 3 cams: %d', sum(sum(IdMat)>2)))
disp(sprintf('Detected 3D points in ALL cameras:     %d', sum(sum(IdMat)==NoCams)))








