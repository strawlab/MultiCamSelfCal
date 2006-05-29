% auxiliary script for joining particular oscar settings
%
% The current version is still not optimal. It would be good to have
% some nicer version. It is not very automatic and it does not use the configdata
%
% $Id: joinoscars.m,v 1.5 2004/04/06 12:57:57 svoboda Exp $
%

clear all;

datapath = '/home/svoboda/viroomData/oscar/demo_3p3c_p%d/';
setups = [1:3];	% related to the data path
path2save = '/home/svoboda/viroomData/oscar/oscardemo3/';

% Some dirty scale factors to make ETH Oscar setup compatible
% with Leuven libraries
% the coordinates and resolutions will be divided by theses values
scalefactor.cameras = 1;
scalefactor.projectors = 1;

% the following indexes are related to the setups
idxcams = [1:4];
idxproj	= [5];

% load the partial data sets and join them in a consitent way
% tested with three setups, three cameras and one projector each.
% the three cameras are the same for all the particular datasets
Ws = []; IdMat = []; Res = [];
for i=1:size(setups,2),
	pts = load([sprintf(datapath,setups(i)),'points.dat']);
	proj(1:3*size(setups,2),1:size(pts,2)) = NaN;
	proj(i*3-2:i*3,:) = pts(idxproj*3-2:idxproj*3,:);
	proj(i*3-2:i*3-1,:) = proj(i*3-2:i*3-1,:)/scalefactor.projectors;
	pts(1:3:3*size(idxcams,2),:) = pts(1:3:3*size(idxcams,2),:)/scalefactor.cameras;
	pts(2:3:3*size(idxcams,2),:) = pts(2:3:3*size(idxcams,2),:)/scalefactor.cameras;
	Ws = [Ws, [pts(1:3*size(idxcams,2),:); proj]];
	id = load([sprintf(datapath,setups(i)),'IdMat.dat']);
	projid(1:size(setups,2),1:size(pts,2)) = 0;
	projid(i,:)=id(idxproj,:);
	IdMat = [IdMat,[id(idxcams,:); projid]];
	Res = [Res; load([sprintf(datapath,setups(i)),'Res.dat'])];
	proj =[]; projid=[];
end
% The Res matrix needs a special care when putting
% camera and projector resolutions together
Res2 = Res([idxcams,idxproj:size(idxcams,2)+1:end],:);
Res2(idxcams,:) = Res2(idxcams,:)/scalefactor.cameras;
Res2(end-2:end,:) = Res2(end-2:end,:)/scalefactor.projectors;

% savings
save([path2save,'points.dat'],'Ws','-ASCII');
save([path2save,'IdMat.dat'],'IdMat','-ASCII');
save([path2save,'Res.dat'],'Res2','-ASCII');

