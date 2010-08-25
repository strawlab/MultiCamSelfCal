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
disp(strcat('reading ', cfg_filename));
fp = fopen(cfg_filename, 'r');
line_no = 0;
section = 'No Section';
config.y = 53;
config.paths.dummy = 1;
while 1
  str = fgetl(fp);
  line_no = line_no + 1;
  disp(str);
  if ~ischar(str)
    break
  end

  disp(str);
  str = strtrim(str);
  if size(str, 1) == 0
    continue
  end
  if str(1) == '#' | str(1) == '%'
    continue
  end

  disp(str);
  if str(1) == '['
    pieces = regexp(str, '\[(.*)\]', 'tokens');
    if size(pieces,1) == 0,
      error(strcat('error parsing config file line ', int2str(line_no), ', file ', cfg_filename));
    end
    section = pieces{1}{1}
    disp(strcat('got section ' , section));
  else
    pieces = regexp(str, '([^:]+):\s+(.*)', 'tokens');
    if size(pieces,1) == 0,
      error(strcat('error parsing config file line ', int2str(line_no), ', file ', cfg_filename));
    end
    pieces
    key = pieces{1}{1}
    value_str = pieces{1}{2}

    % map hyphens and spaces to underscores in 'key'
    key = strrep(strrep(key, ' ', '_'), '-', '_');

    % Parse value according to type.
    try
      % Lookup named fields (will throw exception if the field does not exist)
      info = metacfg.(section).(key);

      type = info{1};

      % Switch on 'type'
      if isstr(type)
        if strcmp(type, 'string')
	  value = value_str;
	elseif strcmp(type, 'boolean')
	  value = str2double(value_str)
	  if isnan(value)
	    error(strcat('error parsing boolean for [', section, '] key=', key));
	  end
	else
	  error('type must be string/boolean (error in metaconfiguration)');
	end
      elseif isscalar(type)
        % parse a vector of length type
        for index = [1:type]
	  [token, value_str] = strtok(value_str);
	  tmp_num = str2double(token);
	  if isnan(tmp_num)
	    error(strcat('error parsing number for [', section, '] key=', key, ': invalid number'));
	  end
	  value(index) = tmp_num;
	end
	value
      else
        error(strcat('error in metaconfiguration for ', section, ' / ', key, ': type is not a string or scalar'));
      end
    catch exception_object
      error(strcat('error parsing config file line ', int2str(line_no), ', file ', cfg_filename, ': ', exception_object.message));
    end
    output_names = info{3};
    n_output_names = size(output_names, 2);
    if n_output_names == 1
      config.(output_names{1}) = value;
    elseif n_output_names == 2
      config.(output_names{1}).(output_names{2}) = value;
    elseif n_output_names == 3
      config.(output_names{1}).(output_names{2}).(output_names{3}) = value;
    else
      error('invalid output-names in metadata');
    end
  end

end

%% Iterate through metacfg's keys and set any with default values
%for section_name = fieldnames(metacfg)
%  section = metacfg.(section_name);
%  for key_name = fieldnames(section)
%    output_names = info{3};
%    n_output_names = size(output_names, 2);
%    if isfield(section.(key_name), 'DefaultValue')
%     if n_output_names == 1
%       try
%         config.(output_names{1});
%       catch
%         config.(output_names{1}) = section.(key_name).DefaultValue;
%       end
%     elseif n_output_names == 2
%       try
%         config.(output_names{1}).(output_names{2});
%       catch
%         config.(output_names{1}).(output_names{2}) = section.(key_name).DefaultValue;
%       end
%     elseif n_output_names == 3
%       try
%         config.(output_names{1}).(output_names{2}).(output_names{3});
%       catch
%         config.(output_names{1}).(output_names{2}).(output_names{3}) = section.(key_name).DefaultValue;
%       end
%      end
%    else
%    error('invalid output-names in metadata');
%  end
%end
