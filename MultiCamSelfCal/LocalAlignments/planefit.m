% planefit ... fit a plane to a point cloud
%              algebraic minimization applied
%
% n = planefit(X);
% X ... Nx3 matrix with 3D points
%
% n ... 3x1 normal of the fitted plane
%
% $Id: planefit.m,v 1.1 2003/07/03 15:34:43 svoboda Exp $

function n = planefit(X);

X = X-repmat(mean(X),size(X,1),1);

[u,s,v] =svd(X);

n = v(:,3);
n = n./norm(n);

return
