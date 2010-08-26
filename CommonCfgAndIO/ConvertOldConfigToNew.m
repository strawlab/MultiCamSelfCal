%  CUT-N-PASTE
config = configdata(argv()(1));

disp('[Paths]');
disp(strcat('Data: ', config.paths.data));
if isfield(config.paths, 'img')
  disp(strcat('Camera-Images: ', config.paths.img));
end

disp('[Files]');
if isfield(config.files, 'basename')
  disp(strcat('Basename: ', config.files.basename));
end
if isfield(config.files, 'imnames')
  disp(strcat('Image-Name-Prefix: ', config.files.imnames));
end
if isfield(config.files, 'imgext')
  disp(strcat('Image-Extension: ', config.files.imgext));
end

disp('[Images]');
if isfield(config.imgs, 'LEDsize')
  disp(strcat('LED-Size: ', num2str(config.imgs.LEDsize)));
end
if isfield(config.imgs, 'LEDcolor')
  disp(strcat('LED-Color: \'', config.imgs.LEDcolor, '\''));
end
if isfield(config.imgs, 'LEDthr')
  disp(strcat('LED-Threshold: ', num2str(config.imgs.LEDthr)));
end
disp(strcat('Subpix: ', num2str(config.imgs.subpix)));

disp('[Calibration]');
disp(strcat('Nonlinear-Parameters: ', num2str(config.cal.nonlinpar)));
disp(strcat('Nonlinear-Update: ', num2str(config.cal.NL_UPDATE)));
disp(strcat('Initial-Tolerance: ', num2str(config.cal.INL_TOL)));
disp(strcat('Do-Global-Iterations: ', num2str(config.cal.DO_GLOBAL_ITER)));
disp(strcat('Global-Iteration-Threshold: ', num2str(config.cal.GLOBAL_ITER_THR)));
disp(strcat('Global-Iteration-Max: ', num2str(config.cal.GLOBAL_ITER_MAX)));
disp(strcat('Num-Cameras-Fill: ', num2str(config.cal.NUM_CAMS_FILL)));
disp(strcat('Do-Bundle-Adjustment: ', num2str(config.cal.DO_BA)));
disp(strcat('Undo-Radial: ', num2str(config.cal.UNDO_RADIAL)));
disp(strcat('Min-Points-Value: ', num2str(config.cal.MIN_PTS_VAL)));
disp(strcat('N-Tuples: ', num2str(config.cal.NTUPLES)));
disp(strcat('Square-Pixels: ', num2str(config.cal.SQUARE_PIX)));
disp(strcat('Use-Nth-Frame: ',num2str(config.cal.USE_NTH_FRAME)));
