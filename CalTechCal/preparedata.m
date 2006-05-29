% preparedata
%
% reads BlueC *.rad file and transform data
% for the CalTech Camera calibration toolbox

function [X,x] = preparedata(filename);

datamat = load(filename,'-ASCII');
X = datamat(:,1:3)'; % 3D points
x = datamat(:,5:6)'; % 2D projections

return;
