function [str, varargout] = sprintf_winsafe(format, varargin)

convert_flag = 0;
if strcmp(filesep, '\')
    format = strrep(format, filesep, '/');
    convert_flag = 1;
end

[str, err] = sprintf(format, varargin{:});

if convert_flag == 1
    str = strrep(str, '/', filesep);
end

if nargout > 1
    varargout{1} = err;
end

end