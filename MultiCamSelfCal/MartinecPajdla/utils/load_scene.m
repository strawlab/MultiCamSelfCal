%load_scene Load data of a real scene.
%
%   function [M,I] = load_scene([show[, load_all_images]])
%
%   global scene.ID ... contains the number of the scene to load

function [M,I] = load_scene(show, load_all_images)

if nargin < 1, show = 0; end
 if nargin < 2, load_all_images = 0; end

global scene Matlab_data;

if scene.ID == 1 % artificial cubes
  if ~isfield(scene,'to_print')
    scene.to_print = 0; end % 0..little markers + thin lines,
                            % 1..big markers + thick lines
  if ~isfield(scene,'load') | ~isfield(scene.load,'m')
    scene.load.m = 5; end
  if ~isfield(scene.load,'predef')
    scene.load.predef = 0; end % 2 .. cubes like in the master thesis
  if ~isfield(scene.load,'emptyness')
    scene.load.emptyness = 0.05; end
  [M,I,P0,X0,scene.lp,polys] = ...
      create_cubes(2,scene.load.m,scene.load.predef,scene.load.emptyness,[],0);
  M(k2idx(find(~I))) = NaN; return
end

if 1, dir = [ Matlab_data 'cmp/' ];   % data in my directory
else  dir = '/data/3DR/Projrec/'; end

scene.data_type = 'cmp';                                % data from Cmp
scene.detection = 'manual';
switch scene.ID
 case 2,    scene.name =                              'House';
  file='Domek/domek.cor'; %'OK.cor';
                                    picDir='Domek'; %'tif';
 case 3,    scene.name =                              'Corridor';
  file='Coridor-Cake/coridorC.cor'; picDir='Coridor-Cake'; 
 case 4,    scene.name =                              'Church';
  file='Plec/Plec.cor';             picDir='Plec';
 case 5,    scene.name =                              'Kampa';
  file='Kampa/Kampa.cor';           picDir='Kampa';
 case 6,    scene.name =                              'Cubes';
  file='Kostky/Kostky.cor';         picDir='Kostky';
 case 7,    scene.name =                              'puzzle';
  file='adam/hlavolam.cor';         picDir='adam';
  
 otherwise                                              % data from Oxford:
  scene.data_type = 'oxford';
  scene.detection = 'Harris'' operator';
  dir = [ Matlab_data 'oxford/' ];
  decimals=3;
  switch scene.ID
   case 101,      scene.name =                        'House (Oxford)';
    file='house'; last_index=9;  picDir='house/';
   case 102,  scene.name =                            'Corridor (Oxford)';
    file='bt';    last_index=10; picDir='corridor/';
   
   otherwise                                              % data from Oxford:
    scene.data_type = 'oxford_';
    switch scene.ID
     case 170,  scene.name =                            'Dinosaur (Oxford)';
      file='viff';  last_index=36; picDir='dinosaur/';
    
     otherwise
      scene.data_type = 'leuven';
      scene.detection = 'Harris'' operator';
      dir = [ Matlab_data 'leuven/' ];
      decimals=3; first_index = 0; ext='';
      switch scene.ID
       case 201,      scene.name =                        'Castle (Leuven)';
        file='viff'; last_index=21;  picDir='Castle/';
       case 202,      scene.name =                        'Temple (Leuven)';
        file='temple'; first_index=2; last_index=6;
        decimals=2; ext='.pgm'; picDir='Temple/';
       otherwise
        scene.data_type = 'boujou';
        scene.detection = 'boujou';
        dir = [ Matlab_data 'boujou/' ];
        switch scene.ID
         case 301,      scene.name =                        'Road in Forest';
          file='road'; last_index=1; picDir='Road_in_Forest/';
         case 302,      scene.name =                        'Corridor (CMP)';
          file='corridorvideo'; last_index=1; picDir='Corridor_CMP/';
         case 303,      scene.name =                        'Fish eye round';
          file='fish_ray4in_im'; last_index=1; picDir='Fish_eye_round/fish_ray_4_in/';
          decimals=4;
         otherwise
          disp(sprintf('Error: undefined scene with ID %d.', scene.ID));
          M = []; I = []; return;
        end
      end
    end
  end
end

switch scene.data_type
 case 'cmp'
  if ~exist('CORR'), load ([dir file],'-mat');
    CORR = CORR_EXCHANGE;
    CORR.d.picturesDir=[dir picDir];
  end
  x              = CORR.d.corr(:,:,1)';
  y              = CORR.d.corr(:,:,2)';
  [m n]          = size(x);
  I              = x~=0;
  M(1:3:3*m,1:n) = x;
  M(2:3:3*m,1:n) = y;
  M(3:3:3*m,1:n) = ones(size(I));

  % kill unknown data
  M(k2i(find(~I))) = NaN;
 case 'oxford'
  [M,I]      = oxford2mm([dir picDir file], last_index);
  M          = e2p(M);  % add ones as homogenous coordinates
  [m n]      = size(I);
 case 'oxford_'
  [M,I]      = oxford_2mm([dir picDir file]);
  M          = e2p(M);  % add ones as homogenous coordinates
  [m n]      = size(I);
 case 'leuven'
  scene.mm_file = [ dir picDir kill_spaces(scene.name) '.mat' ];
  convert = 1; to_file = 0;
  if 1 %scene.ID == 201  % `Leuven's castle' is too big to compute always again
    to_file = 1;
    convert = ~file_exists(scene.mm_file); % whether file doesn't exist
  end
  if convert
    [M,I]      = leuven2mm([dir picDir], file, last_index, first_index, ...
                           decimals, ext);
    if to_file
      disp([ 'Saving to precompiled file ' scene.mm_file '...' ]);
      a=[ 'save ' scene.mm_file ' M I']; eval(a); end
  else
    disp([ 'Loading from precompiled file ' scene.mm_file '...' ]);
    a=[ 'load ' scene.mm_file ' M I']; eval(a);
  end
  M          = e2p(M);  % add ones as homogenous coordinates
  [m n]      = size(I);
 
 case 'boujou'
  [M,I]      = boujou2mm([dir picDir file '.txt']);
  fprintf(1,'Converting from Eucledian to projective coordinates...'); tic;
  M          = e2p(M);  % add ones as homogenous coordinates
  disp(['(' num2str(toc) ' sec)']);
  [m n]      = size(I);
end


% take out some points and pictures
  % take out some pictures
  if scene.ID==3, % take out the first picture
    I=I([2:8],:); M=M([2*3-2:3*8],:); m=m-1; 
  end
    
  % take out points which are just in two images or less
  if 1 %scene.ID==3, 
    out  = find(sum(I)<=1); %<=2
    stay = setdiff(1:n,out);  M     = M(:,stay);
    I    = I(:,stay);         [m n] = size(I); 
  end
  
  % take out points which are not in the first image
  %if scene.ID==2, stay=find(I(1,:) == 1); M=M(:,stay); I=I(:,stay); end


if strcmp(scene.data_type, 'cmp'),
  decimals = ceil(log10(m + .1));
end
format = sprintf('%%0%dd',decimals);

% load images
changed = 0;
if show  |  load_all_images, to_load = m; else to_load = 1; end
if ~isfield(scene,'img') | size(scene.img,2)~=to_load,scene.img{to_load}=[];end
for k=1:to_load
  switch scene.data_type
   case 'cmp'
    nos       = sprintf(format,k);
    InputFile = strcat(CORR.d.picturesDir,filesep,CORR.d.filePrefix,...
                       nos,'.', CORR.d.fileExt);
   case 'oxford'
    InputFile = [[dir picDir file] '.' num2str(k-1,format) '.png' ]; % '.pgm' 
                                                 % doesn't work in Matlab
   case 'oxford_'
    InputFile = [[dir picDir file] '.' num2str(k-1,format) '.png' ]; % '.ppm' 
                                                 % doesn't work in Matlab
   case 'leuven'
    InputFile = [[dir picDir file] '.' num2str(k-1+first_index,format) ...
                                      '.png' ]; % '.pgm' doesn't work in Matlab
   case 'boujou'
    InputFile = [[dir picDir file] '.' num2str(k-1+first_index,format) ...
                                      '.jpg' ];
   otherwise
    disp('Unknown data type');
  end

  if isempty(scene.img{k})  |  ~isfield(scene.img{k}, 'file') ...
        |  ~strcmp(scene.img{k}.file, InputFile)
    disp(sprintf('Loading %s...', InputFile));
    scene.img{k}.file = InputFile;
    scene.img{k}.data = imread(InputFile);
    
    scene.image_size = size(scene.img{1}.data);
    if scene.ID == 2 % Domek
      % pictures are too big therefore some smaller ones are taken
      scene.image_size_show = scene.image_size;
      scene.image_size(1:2) = [ 2003 2952 ];
    end
    
    changed=1;
  end
end

tiles_y=4; if m/tiles_y > 2, tiles_x = 6; else tiles_x = 4; end
global tiles; tiles_set(tiles_x, tiles_y);

if show  &  changed    % show
  for k=1:m
    fig = figure(10+k);
    [x y] = tiles2xy(k); subfig(tiles.y, tiles.x, y*tiles.x+x+1, fig);
    cla; image(scene.img{k}.data); hold on;
    drawpointsI(M([k*3-2,k*3-1],:),[1;1]*I(k,:));
  end
end
