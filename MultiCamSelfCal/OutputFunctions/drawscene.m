function drawscene(X,C,R,fig,ctypehint,scenetitle,camsId)

% drawscene ... plots calibration points, cameras and their viewing axes
%
% drawscene(X,C,R,fig,ctypehint,scenetitle)
%
% X ............ 4xPOINTS matrix containg POINTS object points
% C ............ 3xCAMS matrix containing the camera centers (in world coord.)
% R ............ 3*CAMSx3 matrix containing camera rotation matrices
%                (needed for drawing the viewing axes)
% fig .......... figure handle (defaults to 1)
% ctypehint .... calibration object type of X (defaults to 'cloud')
% scenetitle ... title of the plot (defaults to '')
% camsIs ....... 1xCAMS vector with cameas Id (default is 1:CAMS

% $Author: svoboda $
% $Revision: 2.0 $
% $Id: drawscene.m,v 2.0 2003/06/19 12:07:03 svoboda Exp $
% $State: Exp $

POINTS = size(X,2);
CAMS   = size(C,2);

if nargin < 7
  camsId = [1:CAMS];
end

if (nargin < 3)
  error('not enough input arguments');
end
if (nargin < 5)
  scenetitle = '';
end
if (nargin < 4)
  ctypehint = 'cloud';
end

figure(fig); clf
title(scenetitle)
grid on
axis equal

% plot camera positions (blue)
drawcloud(C,fig,'b');

% plot calibration object (red)
drawobject(X,ctypehint,fig,'r');

% Mean of all points
centroid = mean(X(1:3,:)');

% plot viewing axes
for i=1:CAMS
  axis_dir = -R(3*i,:); % 3rd row of i-th rotation matrix
  axis_len = 0.6*norm(C(1:3,i)-centroid');  
  endpoint = C(1:3,i)+axis_len*axis_dir';
  line([C(1,i),endpoint(1)],[C(2,i),endpoint(2)],[C(3,i),endpoint(3)]);
  text(C(1,i),C(2,i),C(3,i),sprintf('%4d',camsId(i)),'Color','k');
end


