% drawcloud ... draw point cloud
%
% [fig] = drawcloud(X,fig,{color})
%
% X ... 3xn matrix containing the points
%       if X is 4xn only the first 3 rows are used
% fig . figure handle
% color color of plotting; defaults to blue
%
% fig . return the figure handle
%
% $Id: drawcloud.m,v 2.0 2003/06/19 12:07:02 svoboda Exp $

function [fig] = drawcloud(X,fig,color)
if nargin < 3
  color = 'b';	% default color
end

figure(fig), hold on
plot3(X(1,:),X(2,:),X(3,:),[color,'o'])


view([1,1,1]);
axis('equal');
grid on
rotate3d on
fig=fig;
return
