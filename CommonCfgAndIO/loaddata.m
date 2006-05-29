% loaddata ... load the input data
%
% loaded = loaddata(config)
% 
% config ... configuration structure, see the CONFIGDATA
% 
%                  M cameras and N frames
% loaded.Ws    ... 3M x N joint image matrix
%       .IdMat ... M x N point identification matrix
%       .Res   ... M x 2 image resolutions
%       .Pmat  ... {1xM} cell array of the projection matrices
% 
%       see the FindingPoint and MulticamSelfCalib for more details
% 
% $Id: loaddata.m,v 2.2 2005/05/23 16:23:35 svoboda Exp $

function loaded = loaddata(config)

USED_MULTIPROC = 0;		% was the multipropcessing used?
						% if yes then multiple IdMat.dat and points.dat have to be loaded
						% setting to 1 it forces to read the multiprocessor data against the 
						% monoprocessor see the IM2POINTS, IM2PMULTIPROC.PL

%%%
% read the data structures
if ~USED_MULTIPROC
  try,
	Ws	   = load(config.files.points);	% distorted points as found by Im2Points
	IdMat  = load(config.files.IdMat);	% see function im2points for detailed comments	
	%%%
	% try,load the file with Images resolutions which is on of the output files
	% from finding LEDs procedure or take the pre-defined resolutions specified in the configdata
	try, Res = load(config.files.Res); catch,  Res   = repmat(config.imgs.res,size(IdMat,1),1); end
  catch
    warning('Data from mono-processor version not found, trying the multi-proc ones ...') 
	USED_MULTIPROC=1;
  end
end

if USED_MULTIPROC
  pointsfiles = dir([config.files.points,'.*']);
  IdMatfiles  = dir([config.files.IdMat,'.*']);
  Resfiles	  = dir([config.files.Res,'.*']);
  pp = [];
  for i=1:size(pointsfiles,1),
	W{i} = load([config.paths.data,pointsfiles(i).name],'-ASCII');
	pp	 = [pp,size(W{i},2)];
	IdM{i} = load([config.paths.data,IdMatfiles(i).name],'-ASCII');
	try, Rs{i}  = load([config.paths.data,Resfiles(i).name],'-ASCII'); catch, Rs{i} = repmat(config.imgs.res,size(IdM{i},1),1); end
  end
  % throw away some point to preserve consistency
  [minpp,minidx] = min(pp);
  if minpp == 0
	error('loaddata: Problem in loading input data. Check CONFIGDATA, EXPNAME settings');
  end
  % merge the matrices
  Ws = [];
  IdMat = [];
  Res = [];
  for i=1:size(pointsfiles,1),
	Ws = [Ws; W{i}(:,1:minpp)];
	IdMat = [IdMat; IdM{i}(:,1:minpp)];
	Res	 = [Res; Rs{i}];
  end
  if isempty(Ws) | isempty(IdMat) 
	error('Error in loading parallel data. Did you really use multi-processor version of finding points');
  end
end

% oscar data hack. The projectors are handled as the cameras
try,config.files.idxcams = [config.files.idxcams,config.files.idxproj]; catch, config.files.idxcams; end

if size(Ws,1)/3 ~= size(config.files.idxcams,2)
	error('Problem in loading points data. Less or more data than expected found')
end


%%% read the P matrices
count = 1;
for i=config.cal.cams2use,
  try,P = load(sprintf(config.files.CalPmat,i),'-ASCII'); catch, warning(sprintf('The calibration file config.files.CalPmat does not exist',i)); end;
  try,Pmat{count} = P; catch, warning('No P mat available'); end;
  count = count+1;
end

idx2use = zeros(size(config.cal.cams2use));
for i=1:size(config.cal.cams2use,2),
	idx2use(i) = find(config.cal.cams2use(i) == config.files.idxcams);
end
	
idx2use3 = [];
for i=1:size(idx2use,2),
  idx2use3 = [idx2use3, [idx2use(i)*3-2:idx2use(i)*3]];
end

%%%
% fill the loaded structure
loaded.Ws    = Ws(idx2use3,:);
loaded.IdMat = IdMat(idx2use,:);
loaded.Res	 = Res(idx2use,:);

try,loaded.Pmat	 = Pmat; catch, warning('No Pmat available'); end;

return;
