% drawobject ... draws a (calibration) object of a specific type
%
% [fig] = drawobject(X, ctype, fig, {color})
%
% X ...... 3xn matrix containg the object's corner points
%          if X is 4xn only the first 3 rows are used
% ctype .. a string specifying the type of the object
%          according to the type the appropriate drawing functions is called
%          supported types are:
%          'cube'    - a cube
%          'octagon' - a planar octagon
%          'cloud'   - a point cloud
% fig .... figure handle
% color .. color of plotting; defaults to blue
%
% fig .... returns the figure handle
%
% $Id: drawobject.m,v 2.0 2003/06/19 12:07:02 svoboda Exp $

function [fig] = drawobject(X,ctype,fig,color)

if nargin < 4
  color = 'b';	% default color
end

switch ctype
case 'cube',
    drawcube(X,fig,color);
case 'octagon',
    drawoctagon(X,fig,color);
case 'cloud',
    drawcloud(X,fig,color);
otherwise,
    error('unknown object type: ', ctype)
end

return
