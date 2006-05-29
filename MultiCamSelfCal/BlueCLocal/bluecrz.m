function [align] = bluecrz(in,config)
% bluecrz ... localized output function for the BlueCRZ installation
%
% [align] = bluecrz(in,config)
% in, cam, config ... see the main GOCAL script
%
% align ... structures aligned wit the specified world frame
%
% $Id: bluecrz.m,v 2.1 2005/05/20 15:27:37 svoboda Exp $

Cst = in.Cst;
Rot = in.Rot;

drawscene(in.Xe,Cst',Rot,41,'cloud','Graphical Output Validation: View from top or bottom',config.cal.cams2use);

horizplane.idx(1) = find(config.cal.cams2use==9);
horizplane.idx(2) = find(config.cal.cams2use==10);
horizplane.idx(3) = find(config.cal.cams2use==17);
horizplane.idx(4) = find(config.cal.cams2use==18);
horizplane.vec = pinv([Cst(horizplane.idx,1:2),ones(size(horizplane.idx))'])*Cst(horizplane.idx,3);
horizplane.par = [-horizplane.vec(1),-horizplane.vec(2),1,-horizplane.vec(3)];
horizplane.n   = horizplane.par(1:3)';

% set the camera on top
set(gca,'CameraTarget',mean(Cst(horizplane.idx,:)));
set(gca,'CameraPosition',mean(Cst(horizplane.idx,:))+3*horizplane.n');
% figure(41), print -depsc grapheval.eps

% definition of the absolute world frame
cave.x=2.8; cave.y=2.8; cave.z=2.36;
cam(9).C  = [cave.x/2, -cave.y/2, cave.z]';
cam(10).C =	[cave.x/2, cave.y/2, cave.z]';
cam(17).C = [-cave.x/2, -cave.y/2, cave.z]';
cam(18).C = [-cave.x/2, cave.y/2, cave.z]'; 
cam(4).C  = [0,0.05,3.7]';		   % relatively ad hoc values to improve the stability 
% of the similarity computation

[align.simT.s, align.simT.R, align.simT.t]  = estsimt([Cst(find(config.cal.cams2use==4),:)',Cst(horizplane.idx,1:3)'],[cam(:).C]);
[align.P, align.X]							= align3d(in.Pe,in.Xe,align.simT);	 		
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
% set(gca,'CameraPosition',align.Cst(find(config.cal.cams2use==4),:)); % view from the perspective of the camera4 

%   drawscene(in.Xe,Cst',Rot,42,'cloud','Graphical Output Validation: View from side',config.cal.cams2use);
%   set(gca,'CameraTarget',mean(Cst(horizplane.idx,:)));
%   set(gca,'CameraPosition',mean(Cst(horizplane.idx,:)+Cst(horizplane(4),:)-Cst(horizplane(1),:))');

figure(61), 
% print -depsc graphevalaligned.eps
eval(['print -depsc ', config.paths.data, 'graphevalaligned.eps'])

return;
