% script for demonstrating the localized points
% it load the input images and the matrix with found points
% and it denotes the position of the detected LED
% and it saves the augmented images on the disk if required

% $Author: svoboda $
% $Revision: 2.2 $
% $Id: showpoints.m,v 2.2 2005/05/20 12:54:51 svoboda Exp $
% $State: Exp $

clear all;
addpath ../CommonCfgAndIO

SAVE_IMG	   = 1;		% Do you want to save images?
COMPOSE_IMGS   = 1;		% Do you want to see composed images?
						% the function getframe which is used here is not really robust
						% no window can overlay the most active figure(1)
						% otherwise it will not work correctly

% load the confidata
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

% for i=1:NoCams,
%   seq(i).camId = config.files.idxcams(i);
%   if seq(i).camId > -1
% 	seq(i).data = dir([sprintf(im.dir,seq(i).camId),sprintf(config.files.imnames,seq(i).camId),im.ext]);
%   else
% 	seq(i).data = dir([im.dir,sprintf(config.files.imnames),im.ext]);
%   end
%   seq(i).size = size(seq(i).data,1);
%   if seq(i).size<4
% 	error('Not enough images found. Wrong image path or name pattern?');
%   end
% end

loaded = loaddata(config);


if ~COMPOSE_IMGS
% load images and show the results
  for i=1:NoCams,
	for j=1:size(loaded.IdMat,2),
	  IM= imread([sprintf(im.dir,seq(i).camId),seq(i).data(j).name]);
	  figure(1), clf, axes('Position',[0 0 1 1]), axis off
	  imshow(IM), hold on, 
	  text(15,20,sprintf('Camera: %0.2d Frame: %0.3d',config.files.idxcams(i),j),'Color','green','FontWeight','bold','FontSize',12,'EraseMode','back');
	  if loaded.IdMat(i,j)>0
		plot(loaded.Ws(3*i-2,j),loaded.Ws(3*i-1,j),'go','MarkerSize',25,'LineWidth',2,'EraseMode','back');
		plot(loaded.Ws(3*i-2,j),loaded.Ws(3*i-1,j),'r+','MarkerSize',15,'LineWidth',1,'EraseMode','back');	
	  else
		text(15,40,'No point found','Color','green','FontWeight','bold','FontSize',12,'EraseMode','back');
	  end
	  if SAVE_IMG
		eval(sprintf('print -djpeg -r72 %spoint.cam%d.%d.jpg',config.paths.data, config.files.idxcams(i),j))
	  end
	  hold off
	end
  end
end

% show the composed figures
if COMPOSE_IMGS
  for j=1:size(loaded.IdMat,2),
	% IMcomposed = uint8(zeros(size(IM,1),size(IM,2),3,NoCams));
	for i=1:NoCams,
	  IM= imread([sprintf(im.dir,seq(i).camId),seq(i).data(j).name]);
	  fig1 = figure(1); clf, axes('Position',[0 0 1 1]), axis off
	  imshow(IM), hold on, 
	  text(15,20,sprintf('Camera: %0.2d Frame: %0.3d',config.files.idxcams(i),j),'Color','green','FontWeight','bold','FontSize',12,'EraseMode','back');
	  if loaded.IdMat(i,j)>0
		plot(loaded.Ws(3*i-2,j),loaded.Ws(3*i-1,j),'go','MarkerSize',25,'LineWidth',2,'EraseMode','back');
		plot(loaded.Ws(3*i-2,j),loaded.Ws(3*i-1,j),'r+','MarkerSize',15,'LineWidth',1,'EraseMode','back');	
	  else
		text(15,40,'No point found','Color','green','FontWeight','bold','FontSize',12,'EraseMode','back');
	  end
	  IMannotated = getframe(gcf);
	  IMcomposed(:,:,:,i) = IMannotated.cdata;
	  hold off
	end
	fig2 = figure(2); clf, axes('Position',[0 0 1 1]), axis off,
	montage(IMcomposed);
	if SAVE_IMG
	  % eval(sprintf('print -djpeg -r152 %spoints.composed.%d.jpg',config.paths.data, j))
	  eval(sprintf('print -depsc %spoints.composed.%04d.eps',config.paths.data, j))
	end
  end
end

