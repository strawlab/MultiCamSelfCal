function [align] = bluechoengg(in,config)
% bluechoengg ... local routines for the hoengg installation
%
% [align] = bluechoengg(in,config)
% in, config ... see the main GOCAL script
%
% align ... structures aligned wit the specified world frame
%
% $Id: bluechoengg.m,v 2.1 2005/05/20 15:27:37 svoboda Exp $

Cst = in.Cst;
Rot = in.Rot;

drawscene(in.Xe,Cst',Rot,41,'cloud','Graphical Output Validation: View from top or bottom',config.cal.cams2use);

horizplane.idx(1) = find(config.cal.cams2use==13);
horizplane.idx(2) = find(config.cal.cams2use==14);
horizplane.idx(3) = find(config.cal.cams2use==15);
horizplane.idx(4) = find(config.cal.cams2use==16);
horizplane.vec = pinv([Cst(horizplane.idx,1:2),ones(size(horizplane.idx))'])*Cst(horizplane.idx,3);
horizplane.par = [-horizplane.vec(1),-horizplane.vec(2),1,-horizplane.vec(3)];
horizplane.n   = horizplane.par(1:3)';

% set the camera on top
set(gca,'CameraTarget',mean(Cst(horizplane.idx,:)));
set(gca,'CameraPosition',mean(Cst(horizplane.idx,:))+3*horizplane.n');
% figure(41), print -depsc grapheval.eps

% definition of the absolute world frame
% ccam(11).C = [1.40, -2.05, 2.70];
cam(13).C = [-1.40, -2.55, 2.70]';
cam(14).C = [-1.40, 2.70, 2.70]';
cam(15).C = [0, 2.70, 2.70]';
cam(16).C = [1.40, 2.70, 2.70]';

cam(1).C  = [-3.70, -2.55, 1.55]';		   % relatively ad hoc values to improve the stability 
cam(5).C	= [-3.70, 4.06, 1.55]';
cam(6).C  = [3.70, 4.06, 1.55]';
cam(10).C	= [3.70, -2.55, 1.55]';
% of the similarity computation

[align.simT.s, align.simT.R, align.simT.t]  = estsimt([Cst(find(config.cal.cams2use==1),:)', Cst(find(config.cal.cams2use==5),:)', Cst(find(config.cal.cams2use==6),:)', Cst(find(config.cal.cams2use==10),:)',Cst(horizplane.idx,1:3)'],[cam(:).C]);
[align.P, align.X]						  = align3d(in.Pe,in.Xe,align.simT);	 		
% save aligned data
if 1 % SAVE_STEPHI | SAVE_PGUHA
	[align.Cst,align.Rot] = savecalpar(align.P,config);
end
% plot the 3D results from a better perspective by estimating the plane of the Cams 9,10,17,18
% let call this plane "horizontal".
% this plot makes sense only for the BigBlueC
horizplane.vec = pinv([align.Cst(horizplane.idx,1:2),ones(size(horizplane.idx))'])*align.Cst(horizplane.idx,3);
horizplane.par = [-horizplane.vec(1),-horizplane.vec(2),1,-horizplane.vec(3)];
horizplane.n   = horizplane.par(1:3)';
drawscene(align.X,align.Cst',align.Rot,61,'cloud','Graphical Output Validation: View from the top camera',config.cal.cams2use);
% set the camera on top
set(gca,'CameraTarget',mean(align.Cst(horizplane.idx,:)));
set(gca,'CameraPosition',mean(align.Cst(horizplane.idx,:))+3*horizplane.n');
% set(gca,'CameraPosition',align.Cst(find(config.cal.cams2use==15),:)); % view from the perspective of the camera4 

%   drawscene(in.Xe,Cst',Rot,42,'cloud','Graphical Output Validation: View from side',config.cal.cams2use);
%   set(gca,'CameraTarget',mean(Cst(horizplane.idx,:)));
%   set(gca,'CameraPosition',mean(Cst(horizplane.idx,:)+Cst(horizplane(4),:)-Cst(horizplane(1),:))');

figure(61), 
% print -depsc graphevalaligned.eps
eval(['print -depsc ', config.paths.data, 'graphevalaligned.eps'])

return
