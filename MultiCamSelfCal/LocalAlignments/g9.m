function [align] = g9(in,config)
% g9 ... local alignment for room G9
%
% [align] = G9(in,config)
% in, cam, config ... see the main GOCAL script
%
% align ... structures aligned wit the specified world frame
%
% $Id: g9.m,v 1.1 2005/05/20 15:31:31 svoboda Exp $

REALVIZ = 0;

Cst = in.Cst;
Rot = in.Rot;

drawscene(in.Xe,Cst',Rot,41,'cloud','Graphical Output Validation: View from top or bottom',config.cal.cams2use);

% definition of the absolute world frame
% cam(1).C = [3, 1.25, 0.57]';
cam(2).C = [3, 1.8, 0.2]';
cam(3).C = [-2.2, 2.05, 0.1]';
cam(4).C = [-2.2, 2.05, 3.2]';

idx = [2:4];

% of the similarity computation

[align.simT.s, align.simT.R, align.simT.t]  = estsimt([Cst(idx,:)'],[cam(idx).C]);
[align.P, align.X]							= align3d(in.Pe,in.Xe,align.simT);	 		
% save aligned data
if 1 % SAVE_STEPHI | SAVE_PGUHA
	[align.Cst,align.Rot] = savecalpar(align.P,config);
end
drawscene(align.X,align.Cst',align.Rot,61,'cloud','Graphical Output Validation: Aligned data',config.cal.cams2use);

set(gca,'CameraTarget',[0,0,0]);
set(gca,'CameraPosition',[0,1,0]);

figure(61), 
% print -depsc graphevalaligned.eps
eval(['print -depsc ', config.paths.data, 'topview.eps'])

drawscene(align.X,align.Cst',align.Rot,62,'cloud','Graphical Output Validation: Aligned data',config.cal.cams2use);

set(gca,'CameraTarget',[0,2.05,0]);
set(gca,'CameraPosition',[0,2.05,3]);

figure(62), 
% print -depsc graphevalaligned.eps
eval(['print -depsc ', config.paths.data, 'sideview.eps'])

return
