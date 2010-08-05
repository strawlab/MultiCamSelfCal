%%
% function eval_y_and_dy: (Np,1) --> (Ny,1)x(Ny,Np), [y,J]=F(p), value y and jacobian J=dF(p)/dp of the function.
%
% p ... size ((11+3)*K+3*N,1), p = [iP(1); u0(1); kappa(1); .. iP(K); u0(K); kappa(K); iX(1); .. iX(N)],
%   where Np = (11+2+raddeg)*K + 3*N
%
% Optional parameters:
%   TP{1:K} ... size (12,11), Pk(:) = P0k + TP{k}*iPk
%   TX{1:N} ... size (4,3), Xn = X0n + TX{n}*iXn
%   qivis ... size (K,N), has 1 in entries corresponding to visible image points
% y ... size (2*nnz(qivis),1), visible image observations, stacked as [q(1,1); q(2,1); .. q(2*K,N)], unobserved q are omitted
%%
% We consider the imaging model as
% u = hom(x)
% x = P*X
% P = P0 + TP*iP
% X = X0 + TX*iX
%%
function [y,J] = eval_y_and_dy(p,P0,TP,X0,TX,y,qivis,RADIAL)
%
[K,N] = size(qivis);
NR = RADIAL*3; % number of radial distortion paramters
%
% rearrange p to P, X [,radial]
for k = 1:K
  P(k2i(k),:) = P0(k2i(k),:) + reshape(TP{k}*p([1:11]+(k-1)*(11+NR)),[3 4]);
  if RADIAL
    radial(k).u0 = p([12:13]+(k-1)*(11+NR));
    radial(k).kappa = p([14]+(k-1)*(11+NR));
  end
end
X = zeros(4,N);
for n = 1:N
  X(:,n) = TX{n}*p((11+NR)*K+[1:3]+(n-1)*3);
end
X = X0 + X;
%
% compute retina points q
for k = 1:K
  x(k2i(k),:) = P(k2i(k),:)*X;
  q(k2i(k,2),:) = nhom(x(k2i(k),:));
  if RADIAL
	q(k2i(k,2),:) = raddist(q(k2i(k,2),:),radial(k).u0,radial(k).kappa);
  end
end
qq = reshape(q,[2 K*N]);
qq = qq(:,qivis);
y = qq(:)-y; % function value
%
% compute Jacobian J = dF(p)/dp
if nargout<2
  return
end
[kvis,nvis] = find(qivis);
Ji = zeros(2*length(kvis)*(11+NR+3),1); Jj = zeros(size(Ji)); Jv = zeros(size(Ji));
cnt = 0;
for l = 1:length(kvis)  % loop for all VISIBLE points in all cameras
  k = kvis(l);
  n = nvis(l);
  xl = x(k2i(k),n);
  ul = nhom(xl);

  % Compute derivatives (Jacobians). Notation: E.g., dudx = du(x)/dx, etc.
  dxdP = kron(X(:,n)',eye(3))*TP{k}; % dx(iP,iX)/diP
  dxdX = P(k2i(k),:)*TX{n}; % dx(iP,iX)/diX
  dudx = [eye(2) -ul]/xl(3);
  if RADIAL
    [dqdu,dqdu0,dqdkappa] = raddist(ul,radial(k).u0,radial(k).kappa);
  else
    dqdu = eye(2); dqdu0 = []; dqdkappa = [];
  end
  dqdP = dqdu*dudx*dxdP;  % dq(iP,iX)/diP
  dqdX = dqdu*dudx*dxdX;         % dq(iP,iX)/dX
  c = cnt+[1:2*(11+NR+3)];
  [Ji(c),Jj(c),Jv(c)] = spidx([1:2]+(l-1)*2,[[1:(11+NR)]+(k-1)*(11+NR) (11+NR)*K+[1:3]+(n-1)*3],[dqdP dqdu0 dqdkappa dqdX]);
  cnt = cnt + 2*(11+NR+3);
end
J = sparse(Ji,Jj,Jv,length(y),length(p));
return

function [i,j,v] = spidx(I,J,V)
%
i = I'*ones(1,length(J));
j = ones(length(I),1)*J;
i = i(:);
j = j(:);
v = V(:);
return

