% emacs, this is -*-Matlab-*- mode
%
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
function [K,kc] = readradfile_mb(name)

load(name, 'kc', 'alpha_c', 'fc', 'cc')
K = [fc(1), alpha_c*fc(1), cc(1);
     0,     fc(2),         cc(2);
     0,         0,             0];
kc = kc';
return;


