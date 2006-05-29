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
% $Revision: 2.0 $
% $Id: getpoint.m,v 2.0 2003/06/19 12:07:10 svoboda Exp $
% $State: Exp $

function [pos,err] = getpoint(imname, showfig, imconfig, avIM, stdIM,subpix)

err = 0;

SHOW_WARN = 0;	% show warnings?
BLK_PROC  = 0;	% blkproc may be faster for bigger LEDs
SUB_PIX	  = 1/imconfig.subpix;	% required sub-pixel precision 3 -> 1/3 pixel

TEST_ECC = 0;	% perform the eccentricity check?
ECC_THR	 = 0.7;	% eccentricity threshold (for validity check)
				% this threshold is not usable in the current implementation

LEDSIZE = imconfig.LEDsize; % avg diameter of a LED in pixels

im.name = imname;

%%%
% set figure handles
fig.im4thr     = 1; % image used for thresholding
fig.imOrig     = 2; % original image
fig.blob       = 3; % ouput of bwlabel
fig.subI       = 4; % subimage (local neighbourhood of est. LED pos.)

im.info = imfinfo(im.name); 
im.orig = imread(im.name);

if findstr(im.info.ColorType,'grayscale');
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

% sortedInt = sort(double(im.thr(:))); % sort intensities
[maxint,idx]  = max(im.thr(:));
leds.thr	  = double(maxint)*4/5;
aboveThr	  = sum(sum(im.thr>leds.thr));
% check how many pixels lie above the threshold
% if too many, there is probably no LED at all
% otherwise, take the position of the maximal intensity
% as the LED position
if aboveThr > (pi*LEDSIZE^2/2) 
  if SHOW_WARN
	warning('Perhaps no LED in the image, detected blob is too large')
  end
  err=1;
  pos=0;
  return;
elseif ( (im.thr(idx) < 5*double(im.std(idx))) | ( im.thr(idx)< 70 )) 
  if SHOW_WARN
	warning('Perhaps no LED in the image, detected maximum of image difference is too low')
  end
  err=1;
  pos=0;
  return;
else  
  rawpos = zeros(1,2);
  [rawpos(1),rawpos(2)] = ind2sub(size(im.thr),idx);
end

leds.size  = round(LEDSIZE/1.2); % (2*leds.size+1)x(2*leds.size+1) is the area of interest around each detected LED
% check if the LED lies in the allowed position (not very close to the image border
% it is because of the implementation not because of principle
if rawpos(1)-leds.size < 1 | rawpos(1)+leds.size > size(im.thr,1) | ...
      rawpos(2)-leds.size < 1 | rawpos(2)+leds.size > size(im.thr,2)
  if SHOW_WARN
	warning('LED position lies outside allowed boundary');
  end
  err = 1;
  pos =	0;
  return
end

leds.rows  = (rawpos(1)-leds.size):(rawpos(1)+leds.size);
leds.cols  = (rawpos(2)-leds.size):(rawpos(2)+leds.size);
[L,num]	   = bwlabel(im.thr(leds.rows,leds.cols)>leds.thr);
%%%
% define subimage as local neighbour of estimated LED position
if TEST_ECC
  im.stats = imfeature(L,'Centroid','Eccentricity');
else
  im.stats = imfeature(L,'Centroid');
end
 
if size(im.stats,1)>1,
  if SHOW_WARN
	warning('More than one blob detected')
  end
  err=1; pos=0;
  return;
end

if TEST_ECC
  if (im.stats.Eccentricity > ECC_THR)
	warning('eccentricity treshold exceeded');
	err = 1; pos = 0;
  end
end

% Crop the sub-image of interest around found LED
IM  = im.fit(leds.rows,leds.cols);

% visual check of LED position
if showfig
  figure(fig.subI)
  imshow(IM)
  plot(im.stats(1).Centroid(1),im.stats(1).Centroid(2),'g+','EraseMode','Back');
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
Gsize = round(leds.scale*LEDSIZE/2); % (2*Gsize+1)x(2*Gsize+1) is the dimension of the Gaussian mask that models PSF

%activerows = (Gsize+1):(leds.scale*(leds.size*2+1)-Gsize-1);
%activecols = (Gsize+1):(leds.scale*(leds.size*2+1)-Gsize-1);

% t1 = cputime;
IM2 = imresize(IM,leds.scale,'bicubic'); % zoom in
% disp(sprintf('elapsed for resize: %f',cputime-t1'))

% Correlation mask that approximates point spread function (PSF) of a LED
Gaussian = fspecial('Gaussian',2*Gsize+1,leds.scale*LEDSIZE/3);

activerows = ceil(size(Gaussian,1)/2):(size(IM2,1)-floor(size(Gaussian,1)/2));
activecols = ceil(size(Gaussian,2)/2):(size(IM2,2)-floor(size(Gaussian,2)/2));

% check if leds.size and leds.scale have reasonable values
if (size(activerows,2)<5 | size(activerows,2)>50)
  error('probably incorect setting of leds.size and leds.scale variables')
end
  
corrcoefmat = zeros(size(IM2));
% t1 = cputime;
if BLK_PROC	% blkproc may be faster for big neighbourhoods
  corrcoefmat(activerows,activecols) = blkproc(IM2(activerows,activecols),[1,1],[Gsize,Gsize],'corr2',Gaussian);
else
  G   = double(Gaussian(:));
  Gn  = G-mean(G);
  Gn2 = sum(Gn.^2);
  B	  = im2col(double(IM2),size(Gaussian),'sliding'); 
  corrcoefmat(activerows,activecols) = col2im(mycorr2(B,G,Gn,Gn2), size(Gaussian), size(IM2),'sliding');
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
  % colormap('gray');
  hold on
  axis on
  plot(cmax,rmax,'g+','EraseMode','Back')
  hold off
  subplot(2,2,3)
  mesh(corrcoefmat)
  subplot(2,2,1)
  mesh(double(IM2(activerows,activecols)))
  subplot(2,2,2)
  mesh(Gaussian)
  drawnow
  % pause
end

%%% plot information about detected LED
if showfig
  figure(fig.im4thr)
  plot(finepos(2),finepos(1),'r+','EraseMode','Back');
  figure(fig.imOrig)
  plot(finepos(2),finepos(1),'r+','EraseMode','Back','MarkerSize',10);
  drawnow
end

if showfig
  pause
end

pos = [finepos(2); finepos(1)];

















