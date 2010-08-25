% --- read_generic_configuration ---
%
% Parse a "keyfile" type configuration, meaning it's divided into [Sections],
% and within each section is a bunch of key-value pairs.
% Metacfg is a multi-level structure that looks line this:
%     metacfg.Calibration.Undo_Radial =
%        { 'boolean',
%          'undo radial distortion',
%          { 'cal', 'UNDO_RADIAL' },
%          { }
%        };
function config = read_generic_configuration(metacfg, cfg_filename);
fp = fopen(cfg_filename, 'r');
line_no = 0;
section = 'No Section';
while 1
  line = fgetl(fp);
  line_no = line_no + 1;
  if ~ischar(rec)
    break
  end

  line = strtrim(line);
  if size(line, 1) == 0 | line[0] == '#' || line[0] == '%'
    continue
  end

  if line(0) == '['
    pieces = regexp(line, '\[(.*)\]', 'tokens');
    if size(pieces,1) == 0,
      error('error parsing config file line ' int2str(line_no) ', file ' cfg_filename);
    end
    section = pieces(1)(1);
  else
    pieces = regexp(line, '([^:]+):\s+(.*)', 'tokens');
    if size(pieces,1) == 0,
      error('error parsing config file line ' int2str(line_no) ', file ' cfg_filename);
    end
    key = pieces{1}{1};
    value = pieces{1}{2};

    % map hyphens and spaces to underscores in 'key'
    key = strrep(strrep(key, ' ', '_'), '-', '_');

    % Parse value according to type.
    try
      % Lookup named fields (will throw exception if the field does not exist)
      info = metacfg.(section).(key);

      % Switch on 'type'
      if isstr(info.type)
        if strcmp(info.type, 'string')
	  ...
	elseif strcmp(info.type, 'boolean')
	  ...
	else
	  error('type must be string/boolean (error in metaconfiguration)');
	end
      elseif isscalar(info.type)
        % parse a vector of length info.type
	...
      else
        error('error in metaconfiguration for ' section ' / ' key ': type is not a string or scalar');
      end
    catch exception_object
      error('error parsing config file line ' int2str(line_no) ', file ' cfg_filename ': ' exception_object.message);
    end
  end

  % Iterate through metacfg's keys and set any with default values
  ...
end

