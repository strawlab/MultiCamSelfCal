elseif strcmp(experiment,'1704BigBlue')
  config.paths.data		= ['/local/Calibration/'];
  config.paths.img      = [config.paths.data,'atlantic%d/'];
  config.paths.radial	= [HOME_PATH,'none'];
  config.files.imnames	= 'atlantic%d.pvi.*.';
  config.files.idxcams	= [3:18];	% related to the imnames
  config.files.imgext	= 'jpg';
  config.files.Pst		= [config.paths.data,'Pst.dat'];
  config.files.Cst		= [config.paths.data,'Cst.dat'];
  config.imgs.LEDsize	= 7; % avg diameter of a LED in pixels  
  config.imgs.LEDcolor	= 'green'; % color of the laser pointer
  config.imgs.subpix	= 1/3;
  config.cal.INL_TOL	= 1; % 
  config.cal.NUM_CAMS_FILL = 6;
  config.cal.DO_BA		= 0;

elseif strcmp(experiment,'DeRoeck01')
  config.paths.data     = ['/data/ViRoom/Calib/DeRoeck20030224/'];
  config.paths.img      = ['/data/ViRoom/Calib/DeRoeck20030224/'];
  config.paths.radial	= [HOME_PATH,'none'];
  config.files.imnames	= 'vr%0.2d_image.*.';
  config.files.idxcams	= [0:2];	% related to the imnames
  config.files.imgext	= 'jpg';
  config.files.Pst		= [config.paths.img,'Pst.dat'];
  config.files.Cst		= [config.paths.img,'Cst.dat'];
  config.imgs.LEDsize	= 7; % avg diameter of a LED in pixels  
  config.imgs.LEDcolor	= 'green'; % color of the laser pointer

elseif strcmp(experiment,'RolandBigBlue')
  config.paths.data		= ['/data/BigBlueC/20030117_BigBlueC/'];
  config.paths.img      = [config.paths.data,'atlantic%d/'];
  config.paths.radial	= [HOME_PATH,'none'];
  config.files.imnames	= 'atlantic%d.pvi.*.';
  config.files.idxcams	= [3:18];	% related to the imnames
  config.files.imgext	= 'jpg';
  config.files.Pst		= [config.paths.data,'Pst.dat'];
  config.files.Cst		= [config.paths.data,'Cst.dat'];
  config.imgs.LEDsize	= 7; % avg diameter of a LED in pixels  
  config.imgs.LEDcolor	= 'green'; % color of the laser pointer
elseif strcmp(experiment,'Roland2BigBlue')
  config.paths.data		= ['/data/BigBlueC/Roland_BigBlue_20030217/'];
  config.paths.img      = [config.paths.data,'atlantic%d/'];
  config.paths.radial	= [HOME_PATH,'none'];
  config.files.imnames	= 'atlantic%d.pvi.*.';
  config.files.idxcams	= [3:12,15:18];	% related to the imnames
  config.files.imgext	= 'jpg';
  config.files.Pst		= [config.paths.data,'Pst.dat'];
  config.files.Cst		= [config.paths.data,'Cst.dat'];
  config.imgs.LEDsize	= 7; % avg diameter of a LED in pixels  
  config.imgs.LEDcolor	= 'green'; % color of the laser pointer
elseif strcmp(experiment,'Roland3BigBlue')
  config.paths.data		= ['/data/BigBlueC/Roland_BigBlue_20030219/'];
  config.paths.img      = [config.paths.data,'atlantic%d/'];
  config.paths.radial	= [HOME_PATH,'none'];
  config.files.imnames	= 'atlantic%d.pvi.*.';
  config.files.idxcams	= [3:12,14:18];	% related to the imnames
  config.files.imgext	= 'jpg';
  config.files.Pst		= [config.paths.data,'Pst.dat'];
  config.files.Cst		= [config.paths.data,'Cst.dat'];
  config.imgs.LEDsize	= 9; % avg diameter of a LED in pixels  
  config.imgs.LEDcolor	= 'green'; % color of the laser pointer
  config.imgs.subpix	= 1;


elseif strcmp(experiment,'0801BigBlue')
  config.paths.data		= ['/home/svoboda/viroomData/BigBlueC/20030108_BigBlueC/Calib/'];
  config.paths.img      = [config.paths.data,'atlantic%d/'];
  config.paths.radial	= [HOME_PATH,'none'];
  config.files.imnames	= 'atlantic%d.pvi.*.';
  config.files.idxcams	= [3:18];	% related to the imnames
  config.files.imgext	= 'jpg';
  config.files.Pst		= [config.paths.data,'Pst.dat'];
  config.files.Cst		= [config.paths.data,'Cst.dat'];
  config.imgs.LEDsize	= 7; % avg diameter of a LED in pixels  
  config.imgs.LEDcolor	= 'green'; % color of the laser pointer
  config.cal.INL_TOL	= 3; % if UNDO_RADIAL than it may be relatively small <1 
  config.cal.NUM_CAMS_FILL = 12;
  config.cal.DO_BA		= 0;
  config.cal.UNDO_RADIAL= 1;
elseif strcmp(experiment,'1301BigBlue')
  config.paths.data		= ['/data/BigBlueC/20030113_BigBlueC/'];
  config.paths.img      = [config.paths.data,'atlantic%d/'];
  config.paths.radial	= [HOME_PATH,'none'];
  config.files.imnames	= 'atlantic%d.pvi.*.';
  config.files.idxcams	= [3:18];	% related to the imnames
  config.files.imgext	= 'jpg';
  config.files.Pst		= [config.paths.data,'Pst.dat'];
  config.files.Cst		= [config.paths.data,'Cst.dat'];
  config.imgs.LEDsize	= 7; % avg diameter of a LED in pixels  
  config.imgs.LEDcolor	= 'green'; % color of the laser pointer

elseif strcmp(experiment,'2911BigBlue')
  config.paths.data		= ['/data/BigBlueC/20021129_BigBlueC/Calib/'];
  config.paths.img      = [config.paths.data,'atlantic%d/'];
  config.paths.radial	= [HOME_PATH,'none'];
  config.files.imnames	= 'atlantic%d.pvi.*.';
  config.files.idxcams	= [3:18];	% related to the imnames
  config.files.imgext	= 'jpg';
  config.files.Pst		= [config.paths.data,'Pst.dat'];
  config.files.Cst		= [config.paths.data,'Cst.dat'];
  config.imgs.LEDsize	= 7; % avg diameter of a LED in pixels  
  config.imgs.LEDcolor	= 'green'; % color of the laser pointer
elseif strcmp(experiment,'0301BigBlue')
  config.paths.data		= ['/data/BigBlueC/20030103_BigBlueC/Calib2/'];
  config.paths.img      = [config.paths.data,'atlantic%d/'];
  config.paths.radial	= [HOME_PATH,'none'];
  config.files.imnames	= 'atlantic%d.pvi.*.';
  config.files.idxcams	= [3:18];	% related to the imnames
  config.files.imgext	= 'jpg';
  config.files.Pst		= [config.paths.data,'Pst.dat'];
  config.files.Cst		= [config.paths.data,'Cst.dat'];
  config.imgs.LEDsize	= 7; % avg diameter of a LED in pixels  
  config.imgs.LEDcolor	= 'green'; % color of the laser pointer

elseif strcmp(experiment,'2910BigBlue')
  config.paths.data		= ['/data/BigBlueC/20021029_BigBlueC/Calib/'];
  config.paths.img      = ['/data/BigBlueC/20021029_BigBlueC/Calib/'];
  config.paths.radial	= [HOME_PATH,'none'];
  config.files.imnames	= 'atlantic%d.pvi.*.';
  config.files.idxcams	= [3:18];	% related to the imnames
  config.files.imgext	= 'jpg';
  config.files.Pst		= [config.paths.img,'Pst.dat'];
  config.files.Cst		= [config.paths.img,'Cst.dat'];
  config.imgs.LEDsize	= 7; % avg diameter of a LED in pixels  
  config.imgs.LEDcolor	= 'green'; % color of the laser pointer

elseif strcmp(experiment,'2210BigBlue')
  config.paths.img      = ['/data/BigBlueC/20022210_BigBlueC/Calib1/'];
  config.paths.radial	= [HOME_PATH,'none'];
  config.files.imnames	= 'atlantic%d.pvi.*.';
  config.files.idxcams	= [3:18];	% related to the imnames
  config.files.imgext	= 'jpg';
  config.files.Pst		= [config.paths.img,'Pst.dat'];
  config.files.Cst		= [config.paths.img,'Cst.dat'];
  config.imgs.LEDsize	= 7; % avg diameter of a LED in pixels  
  config.imgs.LEDcolor	= 'green'; % color of the laser pointer
