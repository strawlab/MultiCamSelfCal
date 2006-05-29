%file_exists Detection, whether given file exists.
%
%  ex = file_exists(name)
%
%    name .... file name
%    ex   .... logical value, if given file exist (0/1)

function [ex] = file_exists(name);

fid = fopen(name,'r');
if fid < 0
  ex = 0;
else
  fclose(fid);
  ex = 1;
end

