function [align] = flydra(in,config)

Cst = in.Cst;
Rot = in.Rot;

v = version; Octave = v(1)<'5';  % Crude Octave test
if ~Octave,
  drawscene(in.Xe,Cst',Rot,41,'cloud','Graphical Output Validation: View from top or bottom (no sRt)',config.cal.cams2use);
end

% definition of the absolute world frame (in cm)

%% for hummingbird cage
%
%cam(3).C = [168, 173, 185]';
%cam(4).C = [142, 76, 89]';
%cam(1).C = [81, 72, 165]';
%cam(2).C = [22,  15, 176]';
%cam(5).C = [53.5, 175, 78]';

% definition of the absolute world frame (in mm) (Doug's cube)

% cam(1).C = [10, 390, 600]';		
% cam(2).C = [460,  380, 600]';
% cam(3).C = [430, 115, 580]';
% cam(4).C = [0, 0, 610]';
% cam(5).C = [240, 150, 610]';

% definition of the absolute world frame (in mm) (windtunnel June 2005)

%cam(1).C = [1510, 180, 500+322]';
%cam(2).C = [1140,  260, 450+322]';
%cam(3).C = [1040, 25, 480+322]';
%cam(4).C = [490, 160, 390+322]';
%cam(5).C = [900, 25, 400+322]';

% the above numbers (from June 2005) transformed to acheive better
% agreement (July 3, 2005)

%cam(1).C = [1585.0266, 157.1808, 725.3687]';
%cam(2).C = [1221.0045, 230.7819, 717.1524]';
%cam(3).C = [1123.2774, -2.1424, 731.8758]';
%cam(4).C = [580.8019, 124.5745, 705.3737]';
%cam(5).C = [978.8653, 3.3878, 663.1311]';

% cal July 5, 2005

%cam(1).C = [1710, 375, 820]';
%cam(2).C = [1110, 316, 800]';
%cam(3).C = [1110, 100, 466]';
%cam(4).C = [-380, 290, 875]';
%cam(5).C = [440, 15, 680]';

% touch-up July 6, 2005 (5c)

cam(1).C = [1853.5325, 228.1160, 971.5365]';
cam(2).C = [1202.0386, 199.5437, 953.7752]';
cam(3).C = [1183.3920, 41.6797, 537.2034]';
cam(4).C = [-406.8365, 229.6378, 1073.0449]';
cam(5).C = [460.2840, -60.0974, 778.1218]';

% touch-up Aug 22, 2005 (touch-up from A applied to B)

%cam(1).C = cam(1).C - [130.0*0.83, 0., 110.0*0.83]';
%cam(2).C = cam(2).C - [130.0*0.83, 0., 110.0*0.83]';
%cam(3).C = cam(3).C - [130.0*0.83, 0., 110.0*0.83]';
%cam(4).C = cam(4).C - [130.0*0.83, 0., 110.0*0.83]';
%cam(5).C = cam(5).C - [130.0*0.83, 0., 110.0*0.83]';

% touch-up Jan 27, 2006 ( hacked-in estimate )

cam(1).C = cam(1).C - [130.0*0.83+20.0, 0., 110.0*0.83]';
cam(2).C = cam(2).C - [130.0*0.83+10.0, 0., 110.0*0.83]';
cam(3).C = cam(3).C - [130.0*0.83+10.0, 0., 110.0*0.83]';
cam(4).C = cam(4).C - [130.0*0.83, 0., 110.0*0.83]';
cam(5).C = cam(5).C - [130.0*0.83, 0., 110.0*0.83]';

% new Feb 14, 2006

cam(1).C = [1760, 190, 850]';
cam(2).C = [1060, 260, 785]';
cam(3).C = [1070, 70, 470 ]';
cam(4).C = [-380, 230, 873]';
cam(5).C = [380, -10, 670]';

% moved cam 2006 03 07 19:45

cam(1).C = [1760, 190, 850]';
cam(2).C = [1060, 260, 785]';
cam(3).C = [1070, 190, 510 ]';
cam(4).C = [-380, 230, 873]';
cam(5).C = [380, 120, 670]';

if 1,
  
% 2006 03 31

cam(1).C = [640, -105, 170]';
cam(2).C = [1220, 172, 912]';
cam(3).C = [475, 172, 580 ]';
cam(4).C = [-350, 172, 932]';
cam(5).C = [320, -105, 170]';

% 2006 04 03e

cam(3).C = [380, 240, 530 ]';

% 2006 04 04a

cam(4).C = [-115, 220, 800]';
end

% 2006 09 14

cam(1).C = [685, 220, 775]';
cam(2).C = [1220, 172, 912]';
cam(3).C = [380, 240, 530 ]';
cam(4).C = [-115, 220, 800]';
cam(5).C = [180, 240, 740]';


% of the similarity computation

[align.simT.s, align.simT.R, align.simT.t]  = estsimt([Cst'],[cam(:).C]);
[align.P, align.X] = align3d(in.Pe,in.Xe,align.simT);
% save aligned data
if 1 % SAVE_STEPHI | SAVE_PGUHA
	[align.Cst,align.Rot] = savecalpar(align.P,config);
end

if ~Octave,
  drawscene(align.X,align.Cst',align.Rot,61,'cloud','Graphical Output Validation: Aligned data',config.cal.cams2use);

  set(gca,'CameraTarget',[0,0,0]);
  set(gca,'CameraPosition',[0,0,1]);

  figure(61), 
  % print -depsc graphevalaligned.eps
  eval(['print -depsc ', config.paths.data, 'topview.eps'])

  drawscene(align.X,align.Cst',align.Rot,62,'cloud','Graphical Output Validation: Aligned data',config.cal.cams2use);
  
  set(gca,'CameraTarget',[0,0,0.9]);
  set(gca,'CameraPosition',[2,0,0.9]);
  
  %figure(62), 
  % print -depsc graphevalaligned.eps
  %eval(['print -depsc ', config.paths.data, 'sideview.eps'])
end

return
