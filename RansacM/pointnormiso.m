function [u2,T] = pointnormiso(u);
% pointnormiso   Isotropic point normalization
%
% [u2,T] = pointnormiso(u);
% u ... 3xN input data homogenous
% 
% u2 ... 3xN normalized data homogenous
% T ...  3x3 transformation matrix the does the tranformation
%
% $Id: pointnormiso.m,v 1.1 2005/05/23 16:16:00 svoboda Exp $

n=size(u,2);

xmean = mean(u(1,:));
ymean = mean(u(2,:));

u2 = u;
u2(1:2,:) = u(1:2,:) - repmat([xmean;ymean],1,n);

scale = sqrt(2)/mean(sqrt(sum(u2(1:2,:).^2)));

u2(1:2,:) = scale*u2(1:2,:);

T = diag([scale,scale,1]);
T(1,3) = -scale*xmean;
T(2,3) = -scale*ymean;

return;
