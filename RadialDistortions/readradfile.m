% readradfiles    reads the BlueC *.rad files
%
% *.rad files contain paprameters of the radial distortion
% [K,kc] = readradfiles(name)
% name ... name of the *.rad file with its full path
%
% K ... 3x3 calibration matrix
% kc ... 4x1 vector of distortion parameters
%
% $Id: readradfile.m,v 2.0 2003/06/19 12:07:16 svoboda Exp $
function [K,kc] = readradfiles(name);

fid = fopen(name,'r');
if fid<0
  error(sprintf('Could not open %s. Missing rad files?',name'))
end
  
for i=1:3,
  for j=1:3,
	buff = fgetl(fid);
	K(i,j) = str2num(buff(7:end));
  end
end

buff = fgetl(fid);
for i=1:4,
  buff = fgetl(fid);
  kc(i) = str2num(buff(7:end));
end

fclose(fid);

return;

	
