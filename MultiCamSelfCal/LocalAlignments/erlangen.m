function [align] = erlangen(in,config)
% erlangen ... local routines for the hoengg installation
%
% [align] = erlangen(in,config)
% in, cam, config ... see the main GOCAL script
%
% align ... structures aligned wit the specified world frame
%
% $Id: erlangen.m,v 1.3 2005/05/20 15:31:30 svoboda Exp $

REALVIZ = 0;

Cst = in.Cst;
Rot = in.Rot;

drawscene(in.Xe,Cst',Rot,41,'cloud','Graphical Output Validation: View from top or bottom',config.cal.cams2use);

% definition of the absolute world frame

if REALVIZ
	cam(1).C = [1.20055 -1.85769 4.02702]';
	cam(2).C = [0.382772 -4.49652 5.28274]';
	cam(3).C = [-2.99133 -3.90767 6.1968]';
	cam(4).C = [-2.92944 -2.40276 -7.78579]';
	cam(5).C = [-9.00505 -5.61218 -9.73132]';
	cam(6).C = [-7.76965 -2.94546 -1.63609]';
else % own measurement
	cam(1).C = [1.16, 0.3, 1.8]';
	cam(2).C = [1.1, 3.0, 2.5]';
	cam(3).C = [-0.9, 2.4, 1.56]';
	cam(4).C = [0.15, -2.5, 2.2]';
	cam(5).C = [-1.95, -2.65, 2.45]';
	cam(6).C = [-1.75, -2.2, 1.42]';
end
% of the similarity computation

[align.simT.s, align.simT.R, align.simT.t]  = estsimt([Cst'],[cam(:).C]);
[align.P, align.X]							= align3d(in.Pe,in.Xe,align.simT);	 		
% save aligned data
if 1 % SAVE_STEPHI | SAVE_PGUHA
	[align.Cst,align.Rot] = savecalpar(align.P,config);
end
drawscene(align.X,align.Cst',align.Rot,61,'cloud','Graphical Output Validation: Aligned data',config.cal.cams2use);

set(gca,'CameraTarget',[0,0,0]);
set(gca,'CameraPosition',[0,0,1]);

figure(61), 
% print -depsc graphevalaligned.eps
eval(['print -depsc ', config.paths.data, 'topview.eps'])

drawscene(align.X,align.Cst',align.Rot,62,'cloud','Graphical Output Validation: Aligned data',config.cal.cams2use);

set(gca,'CameraTarget',[0,0,0.9]);
set(gca,'CameraPosition',[2,0,0.9]);

figure(62), 
% print -depsc graphevalaligned.eps
eval(['print -depsc ', config.paths.data, 'sideview.eps'])

return
