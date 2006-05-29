function F = u2Fdlt(u,do_norm)
% u2Fdlt      linear estimation of the Fundamental matrix
%             from point correspondences
%
% H = u2Fdlt(u,{do_norm=1})
% u ... {4|6}xN corresponding coordinates
% do_norm .. do isotropic normalization of points?
%
% F ... 3x3 fundamental matrix
%
% $Id: u2Fdlt.m,v 1.1 2005/05/23 16:16:01 svoboda Exp $

NoPoints = size(u,2);

if nargin < 2
  do_norm=1;
end

u = u';

% parse the input parameters
if NoPoints<8 
  error('Too few correspondences')
end

if size(u,2) == 4,
  % make the homogenous coordinates
  u = [u(:,1:2), ones(size(u(:,1))), u(:,3:4), ones(size(u(:,1)))];
end

u1 = u(:,1:3);
u2 = u(:,4:6);

if do_norm
  [u1,T1] = pointnormiso(u1');
  u1 = u1';
  [u2,T2] = pointnormiso(u2');
  u2 = u2';
end

% create the data matrix
A = zeros(NoPoints,9);
for i=1:NoPoints                             % create equations
 for j=1:3
  for k=1:3
   A(i,(j-1)*3+k)=u2(i,j)*u1(i,k);   
  end
 end
end

[U,S,V]  = svd(A);
f        = V(:,size(V,2));
F        = reshape(f,3,3)';

if do_norm
  F = inv(T2)*F*T1;
end

return;
