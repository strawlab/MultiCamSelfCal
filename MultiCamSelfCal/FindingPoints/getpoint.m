function [pos,err] = getpoint(imname, showfig, imconfig, avIM, stdIM)
% GETPOINT ... extracts position of an LED from an image
%              only one or none LED is expected
%
% function [pos,err] = getpoint(imname, showfig, imconfig, avIM, stdIM)
%
% imname ... name of the image (full path should be specified)
% showfig .. show figures (1->on/0->off)
% imconfig . config.imgs, see CONFIGDATA
% avIM   ... average image of the camera, see IM2POINTS
% stdIM  ... image of standard deviations, see IM2POINTS 
%
% pos ...... 2x1 vector containing (x,y)'-coordinates of the point
%            if error then 0 is returned
% err ...... boolean, indicates an error (ambiguous blobs, point too
%            eccentric, etc.)

% $Author: svoboda $
% $Revision: 2.6 $
% $Id: getpoint.m,v 2.6 2005/05/20 12:05:40 svoboda Exp $
% $State: Exp $


err = 0;

foo = ver('images');
IPT_VER = str2num(foo.Version(1));
if IPT_VER >= 5
  region_properties_function = 'regionprops';
else
  region_properties_function = 'imfeature';
end
  
SHOW_WARN = 0;	% show warnings?
BLK_PROC  = 0;	% blkproc may be faster for bigger LEDs, rather not
SUB_PIX	  = 1/imconfig.subpix;	% required sub-pixel precision 3 -> 1/3 pixel

TEST_AREA = 0;	% check the size of the thresholded blob? (mostly not necessary)				   
TEST_ECC = 0;	% perform the eccentricity check? (mostly not necessary)
ECC_THR	 = 0.99;	% eccentricity threshold (for validity check)
					% this threshold is not usable in the current implementation

LEDSIZE = imconfig.LEDsize; % avg diameter of a LED in pixels

im.name = imname;

% threshold for the LED detection, set to a default value if not specified
try imconfig.LEDthr; catch imconfig.LEDthr = 70; end

%%%
% set figure handles
fig.im4thr     = 1; % image used for thresholding
fig.imOrig     = 2; % original image
fig.blob       = 3; % ouput of bwlabel
fig.subI       = 4; % subimage (local neighbourhood of est. LED pos.)

im.info = imfinfo(im.name); 
im.orig = imread(im.name);

if strcmp(im.info.ColorType,'grayscale');
	im.I = im.orig;
else
	[im.r,im.c] = size(im.orig(:,:,1));
	im.R  = im.orig(:,:,1);	% Red component 
	im.G  = im.orig(:,:,2);	% Green	component
end

% find possible location of the point by thresholding
if strcmp(imconfig.LEDcolor,'green')
  im.thr = uint8(abs(double(im.G(:,:))-double(avIM(:,:,2)))); % on which image the thresholding will be done
  im.std = stdIM(:,:,2); % use green component
  im.fit = im.G;			% image for fitting of the PSF
elseif strcmp(imconfig.LEDcolor,'red')
  im.thr = uint8(abs(double(im.R(:,:))-double(avIM(:,:,1)))); % on which image the thresholding will be done
  im.std = stdIM(:,:,1); % use red component
  im.fit = im.R;			% image for fitting of the PSF
elseif strcmp(im.info.ColorType,'grayscale')
  im.thr = uint8(abs(double(im.I)-double(avIM)));
  im.std = stdIM; 
  im.fit = im.I; 
elseif ~strcmp(im.info.ColorType,'grayscale') & strcmp(imconfig.LEDcolor,'intensity')
  try im.I; catch im.I = uint8(round(mean(double(im.orig),3))); end
  im.thr = uint8(round(abs(double(im.I)-double(mean(avIM,3)))));
  try im.std = stdIM; catch im.std = uint8(round(mean(double(stdIM),3))); end
  try im.fit = im.I; catch im.fit = im.I; end
else
  error('getpoint: no valid color of the laser pointer, see CONFIGDATA');
end

% show figures if required, may be useful when debugging
if showfig
  figure(fig.imOrig),
  clf
  imshow(im.orig)
  title(strcat(im.name, ' original'))
  hold on
  figure(fig.im4thr),
  clf
  imshow(im.thr);
  title(strcat(im.name, ' image to be thresholded'))
  drawnow
  hold on
end

[maxint,idx]  = max(im.thr(:));
leds.thr	  = double(maxint)*0.99;  %4/5;

if ( (im.thr(idx) < 5*double(im.std(idx))) | ( im.thr(idx)< imconfig.LEDthr )) 
  if SHOW_WARN
	warning('Perhaps no LED in the image, detected maximum of image difference is too low')
	disp(sprintf('Max: %d, Thr4Max1: %d, Thr4Max2: %d',double(im.thr(idx)), 10*double(im.std(idx)), imconfig.LEDthr))
  end
  err=1;
  pos=0;
  return;
else
	[L,num]=bwlabel(im.thr>leds.thr);
end

if num>1 % sum(diff(any(im.thr>leds.thr,2))>0)>1
  if SHOW_WARN
	warning('More than one blob detected')
	figure(99), imshow(im.thr>leds.thr), title('thresholded image');
	disp('press a key to continue')
	pause
  end
  err=1;
  pos=0;
  return;
else    
  im.stats = eval([region_properties_function,'(L,',char(39),'Centroid',char(39),')']);  
  rawpos   = round([im.stats.Centroid(2),im.stats.Centroid(1)]);
  % rawpos = zeros(1,2);
  % [rawpos(1),rawpos(2)] = ind2sub(size(im.thr),idx);
end


leds.size  = round(LEDSIZE/1.2); 
% (2*leds.size+1)x(2*leds.size+1) is the area of interest around each detected LED
% check if the LED lies in the allowed position (not very close to the image border
% it is because of the implementation not because of principle
if rawpos(1)-leds.size < 1 | rawpos(1)+leds.size > size(im.thr,1) | ...
      rawpos(2)-leds.size < 1 | rawpos(2)+leds.size > size(im.thr,2)
  if SHOW_WARN
	warning('LED position lies outside allowed boundary');
  end
  err = 1;
  pos =	0;
  return;
end

leds.rows  = (rawpos(1)-leds.size):(rawpos(1)+leds.size);
leds.cols  = (rawpos(2)-leds.size):(rawpos(2)+leds.size);
% [L,num]	   = bwlabel(im.thr(leds.rows,leds.cols)>leds.thr);

% perform checks of the thresholded blob if required
if TEST_ECC
  im.stats = eval([region_properties_function,'(L,',char(39),'Eccentricity',char(39),')']); 
  if (im.stats.Eccentricity > ECC_THR)
	if SHOW_WARN
	  warning(sprintf('eccentricity treshold %2.4f exceeded by %2.4f', ECC_THR, im.stats.Eccentricity));
	end
	err = 1; pos = 0; return;
  end
end
if TEST_AREA
  im.stats = eval([region_properties_function,'(L,',char(39),'Area',char(39),')']); 
  if im.stats.Area > size(leds.rows,2)*size(leds.cols,2)/1.5
	if SHOW_WARN
	  warning('Detected LED to too big')
	end
	err=1;
	pos=0;
	return;
  end
end


% Crop the sub-image of interest around found LED
IM  = im.fit(leds.rows,leds.cols);

% visual check of LED position
if showfig
  figure(fig.subI), clf
  imshow(im.thr>leds.thr)
  hold on
  plot(rawpos(2),rawpos(1),'g+','EraseMode','Back');
  drawnow
  % pause
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% interpolate local neighborhood and find the maxima
% by correlation with the gaussian (see declaration of Gsize)
leds.scale = SUB_PIX; % the area of interest will be inreased by leds.scale using bilinear interpolation
					  % leds.size should be comparable to the leds.scale. If leds.size is assumed too small
					  % then the correlation based detection does not work
					  % properly
finepos = getfinepos(IM,rawpos,leds,LEDSIZE,BLK_PROC,showfig,SHOW_WARN);



%%% plot information about detected LED
if showfig
  figure(fig.im4thr)
  plot(finepos(2),finepos(1),'r+','EraseMode','Back');
  figure(fig.imOrig)
  plot(finepos(2),finepos(1),'r+','EraseMode','Back','MarkerSize',25,'LineWidth',3);
  drawnow
end

if showfig
  pause
end

pos = [finepos(2); finepos(1)];

return % end of the getpoint function

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
% internal function for finding the fine position
function finepos = getfinepos(IM,rawpos,leds,LEDSIZE,BLK_PROC,showfig,SHOW_WARN)

  Gsize = round(leds.scale*LEDSIZE/2); % (2*Gsize+1)x(2*Gsize+1) is the dimension of the Gaussian mask that models PSF

  % t1 = cputime;
  IM2 = imresize(IM,leds.scale,'bicubic'); % zoom in
  % disp(sprintf('elapsed for resize: %f',cputime-t1'))

  % Correlation mask that approximates point spread function (PSF) of a LED
  Gaussian = fspecial('Gaussian',2*Gsize+1,leds.scale*LEDSIZE/3);

  % activerows = ceil(size(Gaussian,1)/2):(size(IM2,1)-floor(size(Gaussian,1)/2));
  % activecols = ceil(size(Gaussian,2)/2):(size(IM2,2)-floor(size(Gaussian,2)/2));

  %%%
  % generally it evaluates only 5x5 region aroung the rough position
  % it is scaled accordingly. The 5x5 grid is a compromise between the speed 
  % and the robustness against bad rough position
  sc = 2; % 2 is for 5x5 neigh, 1 is for 3x3, 3 is for 9x9 and so on
  activerows = ceil(size(IM2,1)/2)-sc*round(leds.scale):ceil(size(IM2,1)/2)+sc*round(leds.scale);
  activecols = ceil(size(IM2,2)/2)-sc*round(leds.scale):ceil(size(IM2,2)/2)+sc*round(leds.scale);
  im2activerows = ceil(size(IM2,1)/2)-floor(size(Gaussian,1)/2)-sc*round(leds.scale):ceil(size(IM2,1)/2)+floor(size(Gaussian,1)/2)+sc*round(leds.scale);
  im2activecols = ceil(size(IM2,2)/2)-floor(size(Gaussian,2)/2)-sc*round(leds.scale):ceil(size(IM2,2)/2)+floor(size(Gaussian,2)/2)+sc*round(leds.scale);
  
  % CHECK if leds.size and leds.scale have reasonable values
  % and correct them if not. 
  % typically, if the assumed LED size is fairly small, a complete IM2 must be taken
  if (min([im2activerows,im2activecols])<1)
	if SHOW_WARN
	  warning('probably incorect setting of leds.size and leds.scale variables')
	end
	im2activerows = 1:size(IM2,1);
	im2activecols = 1:size(IM2,2);
	activerows = ceil(size(Gaussian,1)/2):(size(IM2,1)-floor(size(Gaussian,1)/2));
	activecols = ceil(size(Gaussian,2)/2):(size(IM2,2)-floor(size(Gaussian,2)/2));
  end
  
  corrcoefmat = zeros(size(IM2));
  % t1 = cputime;
  if BLK_PROC	% blkproc may be faster for big neighbourhoods
	corrcoefmat(activerows,activecols) = blkproc(IM2(activerows,activecols),[1,1],[Gsize,Gsize],'corr2',Gaussian);
  else
	G   = double(Gaussian(:));
	Gn  = G-mean(G);
	Gn2 = sum(Gn.^2);
	B	= im2col(double(IM2(im2activerows,im2activecols)),size(Gaussian),'sliding'); 
	corrcoefmat(activerows,activecols) = col2im(mycorr2(B,G,Gn,Gn2), size(Gaussian), size(IM2(im2activerows,im2activecols)),'sliding');
	% corrcoefmat(activerows,activecols) = colfilt(double(IM2(activerows,activecols)),size(Gaussian),'sliding','mycorr2',G,Gn,Gn2);
  end
  % disp(sprintf('elapsed for coorrelations: %f',cputime-t1'))

  [maxcorrcoef,idxmaxcorrcoef] = max(corrcoefmat(:));
  [rmax,cmax] = ind2sub(size(corrcoefmat),idxmaxcorrcoef);  
  finepos	  = rawpos+([rmax,cmax]-ceil(size(IM2)/2))./leds.scale;

  %%%
  % plot the subimage with detected position of the maximal correlation
  %%%

  if showfig
	figure(5),
	clf
	subplot(2,2,4)
	showimg(IM2,5);
	title('Interpolated ROI')
	% colormap('gray');
	hold on
	axis on
	plot(cmax,rmax,'g+','EraseMode','Back','MarkerSize',15,'LineWidth',3)
	hold off
	subplot(2,2,3)
	mesh(corrcoefmat)
	title('Correlation coeffs')
	subplot(2,2,1)
	mesh(double(IM2(activerows,activecols)))
	title('Active ROI')
	subplot(2,2,2)
	mesh(Gaussian)
	title('PSF approx by 2D Gaussian')
	drawnow
	% pause
  end

return
















