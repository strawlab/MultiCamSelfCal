% LocalConfig configuration file for self-calibration experiments
% 
% 
% config = configdata(experiment)
%
% experiment ... string with an experiment name

function config = configdata(experiment)

HOME_PATH = '/home/svoboda/Work/BlueCCal/';

% add paths
addpath([HOME_PATH,'MultiCamSelfCal/FindingPoints']);
addpath([HOME_PATH,'BlueCFindingPoints']);


if nargin<1,
  display('No name of the experiment specified: >>basic<< used as default')
  experiment = 'basic';
end

if strcmp(experiment,'basic')
  error;
elseif strcmp(experiment,'BlueCHoengg')
  config.paths.data		= '/local/tomas/';
  config.paths.img      = config.paths.data;
  config.files.imnames	= 'arctic%d.pvi.*.';
  config.files.idxcams	= [1:16];	% related to the imnames
  config.files.imgext	= 'jpg';
  config.imgs.LEDsize	= 7; % avg diameter of a LED in pixels  
  config.imgs.LEDcolor	= 'green'; % color of the laser pointer
  config.imgs.subpix	= 1/5;
elseif strcmp(experiment,'BlueCRZ')
  config.paths.data		= '/local/tomas/';
  config.paths.img      = config.paths.data;
  config.files.imnames	= 'atlantic%d.pvi.*.';
  config.files.idxcams	= [3:12,14:18];	% related to the imnames
  config.files.imgext	= 'jpg';
  config.imgs.LEDsize	= 7; % avg diameter of a LED in pixels  
  config.imgs.LEDcolor	= 'green'; % color of the laser pointer
  config.imgs.subpix	= 1/5;
else
  error('Configdata: wrong identifier of the data set');
end


% image resolution
try config.imgs.res; catch, config.imgs.res		  = [640,480];	end;

% scale for the subpixel accuracy
% 1/3 is a good compromise between speed and accuracy
% for high-resolution images or bigger LEDs you may try 1/1 or 1/2
try config.imgs.subpix; catch, config.imgs.subpix = 1/3; end;

% data names
try config.files.Pmats;    catch, 	config.files.Pmats	  = [config.paths.data,'Pmatrices.dat'];		end;
try config.files.points;   catch, 	config.files.points	  = [config.paths.data,'points.dat'];		end;
try config.files.IdPoints; catch,	config.files.IdPoints = [config.paths.data,'IdPoints.dat'];		end;
try config.files.Res;	   catch,	config.files.Res	  = [config.paths.data,'Res.dat'];		end;
try config.files.IdMat;	   catch, 	config.files.IdMat	  = [config.paths.data,'IdMat.dat'];			end;
try config.files.inidx;	   catch, 	config.files.inidx	  = [config.paths.data,'idxin.dat'];			end;
try config.files.avIM;	   catch, 	config.files.avIM	  = [config.paths.data,'camera%d.average.tiff'];		end;
try config.files.stdIM;	   catch, 	config.files.stdIM	  = [config.paths.data,'camera%d.std.tiff'];		end;
try config.files.CalPar;   catch, 	config.files.CalPar	  = [config.paths.data,'camera%d.cal'];			end;
try config.files.CalPmat;  catch, 	config.files.CalPmat  = [config.paths.data,'camera%d.Pmat.cal'];			end;
try config.files.StCalPar; catch, 	config.files.StCalPar = [config.paths.data,'atlantic%d.ethz.ch.cal'];	end;







