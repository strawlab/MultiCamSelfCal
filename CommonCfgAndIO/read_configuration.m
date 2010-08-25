% Read a configuration file like:
%    [Paths]
%    Data: /home/svoboda/viroomData/oscar/oscar_2c1p/   #config.paths.data
%    Camera-Filename: cam%d                             #config.paths.img[2]
%
%    [Files]
%    Image-Name-Prefix: oscar2c1p_                      #config.files.imnames
%    Basename: oscar                                    #config.files.basename
%    Num-Cameras: 2                                     #config.files.idxcams?
%    Num-Projectors: 2                                  #config.files.idxproj?
%    Projector-Data: files.txt
%    Image-Extension: jpg
%    
%    [Images]
%    LED_Size: 25
%    LED_Color: green
%    Subpix: 0.333333333
%    Camera_Resolution: 1392 1024
%    Projector_Resolution: 1024 768


function [config] = read_configuration(filename)

if nargsin == 1
  filename = ...
end

% Do generic parsing based on metaconfiguration
config = parse_generic_configuration(get_metaconfiguration(), filename);

% Do non-generic transformations.
% (These transformations are done to minimize our impact on outside code)
config.paths.img = [config.paths.data, config.paths.camera_filename];
config.files.projdata= [config.paths.data,config.paths.projdatafile]; % contains the projector data
% TODO: config.files.idxcams, config.files.idxproj, config.files.cams2use

%  --- get_metaconfiguration ---
% 
% Returns an structure describing each named fields that must be producted by parsing the file.
function metacfg = get_metaconfiguration();

metacfg.Paths.Data =
  { 'string',
    'Base directory for all data files',
    { 'paths', 'data' },
    { 'slash_terminated' }
  };
metacfg.Paths.Camera_Dirname =
  { 'string',
    'Template for camera directory (use %d for camera number)',
    { 'paths', 'camera_dirname' },
    { 'slash_terminated' }
  };
metacfg.Files.Image_Name_Prefix =
  { 'string',
    'Template for camera directory (use %d for camera number)',
    { 'files', 'image_name_prefix' },
    { }
  };
metacfg.Files.Image_Extension =
  { 'string',
    'Each for image filenames',
    { 'files', 'imgext' },
    { }
  };
metacfg.Files.Projector_Data_Filename =
  { 'string',
    'File of projector data (within data dir)',
    { 'files', 'projdatafile' },
    { }
  };
metacfg.Images.LED_Size =
  { '1',
    'average diameter of a LED in pixels',
    { 'imgs', 'LEDsize' },
    { }
  };
metacfg.Images.LED_Color =
  { 'string',
    'color of the laser pointer',
    { 'imgs', 'LEDcolor' },
    { }
  };
metacfg.Images.Subpix =
  { 1,
    'scale of the required subpixel accuracy',
    { 'imgs', 'subpix' },
    { }
  };
metacfg.Images.Camera_Resolution =
  { 2,
    'camera image resolution',
    { 'imgs', 'res' },
    { }
  };
metacfg.Images.Projector_Resolution =
  { 2,
    'projector resolution',
    { 'imgs', 'projres' },
    { }
  };
metacfg.Calibration.Do_Global_Iterations =
  { 'boolean',
    'do global iterations',
    { 'cal', 'DO_GLOBAL_ITER' },
    { }
  };
metacfg.Calibration.Global_Iteration_Max =
  { 1,
    'global iteration maximum',
    { 'cal', 'GLOBAL_ITER_MAX' },
    { }
  };
metacfg.Calibration.Global_Iteration_Threshold =
  { 1,
    'global iteration threshold',
    { 'cal', 'GLOBAL_ITER_THR' },
    { }
  };
metacfg.Calibration.Nonlinear_Parameters =
  { 6,
    'non-linear parameters (cite?)',
    { 'cal', 'nonlinpar' },
    { }
  };
metacfg.Calibration.Nonlinear_Update =
  { 6,
    'non-linear update (cite?)',
    { 'cal', 'NL_UPDATE' },
    { }
  };
metacfg.Calibration.Initial_Tolerance =
  { 1,
    'initial tolerance',
    { 'cal', 'INL_TOL' },
    { }
  };
metacfg.Calibration.Num_Cameras_Fill =
  { 1,
    'num cameras fill',
    { 'cal', 'NUM_CAMS_FILL' },
    { }
  };
metacfg.Calibration.Do_BA =
  { 1,
    'do Bundle Adjustment (slow)',
    { 'cal', 'DO_BA' },
    { }
  };
metacfg.Calibration.Undo_Radial =
  { 'boolean',
    'undo radial distortion',
    { 'cal', 'UNDO_RADIAL' },
    { }
  };
metacfg.Calibration.Min_Points_Value =
  { 1,
    'min points value',
    { 'cal', 'MIN_PTS_VAL' },
    { }
  };
metacfg.Calibration.N_Tuples =
  { 1,
    'N Tuples',
    { 'cal', 'NTUPLES' },
    { }
  };
metacfg.Calibration.Square_Pixels =
  { 1,
    'Square Pixels',
    { 'cal', 'SQUARE_PIX' },
    { }
  };
