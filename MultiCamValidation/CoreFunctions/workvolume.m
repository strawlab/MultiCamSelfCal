function [Xmat,idxisa] = workvolume(cam,room,imres,idxcams)

STEP = 0.1;

if nargin < 4
	idxcams = [1:size(cam,2)];
end

if nargin < 3
	imres = repmat([640 480],size(idxcams,2),1);
end
imres = imres(idxcams,:);

if nargin < 2
	% room [x_min, x_max, y_min, y_max, z_min, z_max]
	room = [-3 3 -3 3 0 3];
end	

% compose Pmat containing all P matrices
Pmat = [];
for i=idxcams,
	Pmat = [Pmat; cam(i).P];
end

% create points

zcoor = room(5):STEP:room(6);
znum = size(zcoor,2);
ycoor = room(3):STEP:room(4);
ynum = size(ycoor,2);
xcoor = room(1):STEP:room(2);
xnum = size(xcoor,2);


buff  = repmat(ycoor,znum,1);
yvec  = reshape(buff,prod(size(buff)),1);
zvec  = repmat(zcoor',ynum,1);

buff = repmat(xcoor,znum*ynum,1);
xvec = reshape(buff,prod(size(buff)),1);

Xmat = [xvec,repmat([yvec,zvec],xnum,1)];
Xmat = [Xmat,ones(size(Xmat(:,1)))];

clear buff

size(Xmat)
umat = Pmat*Xmat';

% normalize projected points in umat
scalemat = [];
for i=1:size(idxcams,2),
	scalemat = [scalemat; repmat(umat(3*i,:),3,1)];
end
umat = umat./scalemat;
clear scalemat;
mask = zeros(size(umat));
mask(1:3:end,:) = umat(1:3:end,:)<repmat(imres(:,1),1,size(mask,2));
mask(2:3:end,:) = umat(2:3:end,:)<repmat(imres(:,2),1,size(mask,2));
mask(3:3:end,:) = 1;
mask = mask.*(umat>0);
idxisa = find(sum(mask)==size(mask,1));

return;

