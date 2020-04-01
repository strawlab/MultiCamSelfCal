function [align] = align_existing_camera_centers(in,config)

Cst = in.Cst;
Rot = in.Rot;

Cam = load([config.paths.data,'original_cam_centers.dat'],'-ASCII');

Octave = exist('OCTAVE_VERSION', 'builtin') ~= 0;
if ~Octave,
  drawscene(in.Xe,Cst',Rot,41,'cloud','Graphical Output Validation: View from top or bottom (no sRt)',config.cal.cams2use);
end

[align.simT.s, align.simT.R, align.simT.t]  = estsimt([Cst'],[Cam']);
[align.P, align.X] = align3d(in.Pe,in.Xe,align.simT);
% save aligned data
[align.Cst,align.Rot] = savecalpar(align.P,config);

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

  figure(62),
  % print -depsc graphevalaligned.eps
  eval(['print -depsc ', config.paths.data, 'sideview.eps'])
end

return
