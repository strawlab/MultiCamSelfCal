function [align] = strawlab_test(in,config)

Cst = in.Cst;
Rot = in.Rot;

Octave = exist('OCTAVE_VERSION', 'builtin') ~= 0;
if ~Octave,
  drawscene(in.Xe,Cst',Rot,41,'cloud','Graphical Output Validation: View from top or bottom (no sRt)',config.cal.cams2use);
end

% These locations are meaningless, and this file is just here for the
% cases when you actually want to do this alignment in MATLAB/Octave.

cam(1).C = [-4600 -100 2200]';
cam(2).C = [-4600 3100 2200]';
cam(3).C = [340 -100 2350]';

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
