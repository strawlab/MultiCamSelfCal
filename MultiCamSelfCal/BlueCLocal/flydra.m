function [align] = flydra(in,config)

Cst = in.Cst;
Rot = in.Rot;

Octave = exist('OCTAVE_VERSION', 'builtin') ~= 0;
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

%cam(1).C = [1853.5325, 228.1160, 971.5365]';
%cam(2).C = [1202.0386, 199.5437, 953.7752]';
%cam(3).C = [1183.3920, 41.6797, 537.2034]';
%cam(4).C = [-406.8365, 229.6378, 1073.0449]';
%cam(5).C = [460.2840, -60.0974, 778.1218]';

% touch-up Aug 22, 2005 (touch-up from A applied to B)

%cam(1).C = cam(1).C - [130.0*0.83, 0., 110.0*0.83]';
%cam(2).C = cam(2).C - [130.0*0.83, 0., 110.0*0.83]';
%cam(3).C = cam(3).C - [130.0*0.83, 0., 110.0*0.83]';
%cam(4).C = cam(4).C - [130.0*0.83, 0., 110.0*0.83]';
%cam(5).C = cam(5).C - [130.0*0.83, 0., 110.0*0.83]';

% touch-up Jan 27, 2006 ( hacked-in estimate )

%cam(1).C = cam(1).C - [130.0*0.83+20.0, 0., 110.0*0.83]';
%cam(2).C = cam(2).C - [130.0*0.83+10.0, 0., 110.0*0.83]';
%cam(3).C = cam(3).C - [130.0*0.83+10.0, 0., 110.0*0.83]';
%cam(4).C = cam(4).C - [130.0*0.83, 0., 110.0*0.83]';
%cam(5).C = cam(5).C - [130.0*0.83, 0., 110.0*0.83]';

% new Feb 14, 2006

%cam(1).C = [1760, 190, 850]';
%cam(2).C = [1060, 260, 785]';
%cam(3).C = [1070, 70, 470 ]';
%cam(4).C = [-380, 230, 873]';
%cam(5).C = [380, -10, 670]';

% moved cam 2006 03 07 19:45

%cam(1).C = [1760, 190, 850]';
%cam(2).C = [1060, 260, 785]';
%cam(3).C = [1070, 190, 510 ]';
%cam(4).C = [-380, 230, 873]';
%cam(5).C = [380, 120, 670]';

if 1,

% 2006 03 31

%cam(1).C = [640, -105, 170]';
%cam(2).C = [1220, 172, 912]';
%cam(3).C = [475, 172, 580 ]';
%cam(4).C = [-350, 172, 932]';
%cam(5).C = [320, -105, 170]';

% 2006 04 03e

%cam(3).C = [380, 240, 530 ]';

% 2006 04 04a

%cam(4).C = [-115, 220, 800]';
end

% 2006 09 14

%cam(1).C = [685, 220, 775]';
%cam(2).C = [1220, 172, 912]';
%cam(3).C = [380, 240, 530 ]';
%cam(4).C = [-115, 220, 800]';
%cam(5).C = [180, 240, 740]';

%% 2006 10 23 (from DLT)
%cam(1).C = [ 651.7963301   169.95615265  749.51356735]';
%cam(2).C = [ 1090.40810501   190.82014771   866.8980674 ]';
%cam(3).C = [ 327.41874025  237.43022637  539.80942371]';
%cam(4).C = [-241.364468    194.27934314  767.35249515]';
%cam(5).C = [ 147.20028399  171.45774441  725.08522715]';

% 2006 12 19 riverside hummingbirds
% estimates from DLT
%cam(1).C = [976.22314128 -2289.85157108   489.78104927]';
%cam(2).C = [-17278.94752856   1794.85211148  15855.51116479]';
%cam(3).C = [ 2266.45466953  2590.2964507    -74.53159994]';
%cam(4).C = [-329.01069449  796.46308431  624.04191004]';

% hand measurements
%ft2mm = 12*25.4;
%cam(1).C = [ 1350 -1580 540]';
%cam(2).C = [ -450 770 (750+5*ft2mm) ]';
%cam(3).C = [ 1500 -1600 2250]';
%cam(4).C = [-280 820 570]';

% 2006 12 01 DLT in flydra WT
cam(1).C = [867.37446261  198.97798549  832.51824736]';
cam(2).C = [1194.97461953 206.718389208 898.66723201]';
cam(3).C = [459.669418616 168.068949056 713.890827]';
cam(4).C = [-186.0833207 207.892635698 775.298571621]';
cam(5).C = [115.230367611 202.584140956 904.723766629]';

% 2007 10 03 DLT in flydra WT
cam(1).C = [ 985.827871     182.49267738  1134.97921258]';
cam(2).C = [362.27817754   189.63204145  1134.23310277]';
cam(3).C = [721.10852967  167.31210242  932.32564817]';
cam(4).C = [-330.47764957   168.38518854  1014.81801646]';
cam(5).C = [1774.53765317   144.79725152   928.10954671]';

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
