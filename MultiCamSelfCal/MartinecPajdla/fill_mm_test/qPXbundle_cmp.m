% [P,X] = qPXbundle_cmp(P0,X0,q)  Bundle adjustment.
%
% P0 ... size (3*K,4), initial camera matrices, K = #images
% X0 ... size (4,N), initial scene points, N = #points
% q ... size (2*K,N), measured image points (in inhomogeneous coordinates)
% P, X ... bundled cameras and scene points, same size as P0, X0

% (c) Tom Werner 2001

function [P,X,radial] = qPXbundle_cmp(P0,X0,q)

RADIAL = (nargin > 3); % don't estimate/estimate radial distortion 
[K,N] = size(q); K = K/2;

P0 = normP(P0);
X0 = normx(X0);

% form observation vector y
qq = reshape(q,[2 K*N]);
aux.qivis = reshape(all(~isnan(qq)),[K N]); % visible image points
qq = qq(:,aux.qivis);
y = qq(:);

% Choose matrices TP,TX, describing local coordinate systems tangent to P0(:), X0.
% Having homogeneous N-vector X, in the neighborhood of X0 it can be parameterized (minimaly)
% by inhomogeneous (N-1)-vector iX as X = X0 + TX*iX, where TX is a non-singular (N,N-1) matrix.

for n = 1:N
  [qX,dummy] = qr(X0(:,n));
  aux.TX{n} = qX(2:end,:)';
end
for k = 1:K
  [qP,dummy] = qr(reshape(P0(k2idx(k),:),[12 1])); 
  aux.TP{k} = qP(2:end,:)';
end

% form initial parameter vector p0
p0 = [];
for k = 1:K
  p0 = [p0; zeros(11,1)];
  if RADIAL
    p0 = [p0; radial(k).u0; radial(k).kappa];
  end
end
p0 = [p0; zeros(3*N,1)];

% fill auxiliary structure for evaluating F(p)
aux.P0 = P0;
aux.X0 = X0;
aux.RADIAL = RADIAL;

% Minimize || F(p) - y || over p. By Newton/Levenber-Marquardt.
p = p0;
lastFp = +Inf;
stepy = +Inf;
lam = .001;
fail_cnt = 0;
[Fp,J] = F(p,aux);
fprintf('  res (rms/max):  %.10g / %.10g\n',sqrt(mean((y-Fp).^2)),max(abs(y-Fp)));
while (stepy > 100*eps) & (fail_cnt < 20)
  D = (J'*J + lam*speye(size(J,2))) \ (J'*(y-Fp));
  FpD = F(p+D,aux);
  if sum((y-Fp).^2) > sum((y-FpD).^2)
    p = p + D;
    lam = max(lam/10,1e-9);
    stepy = max(abs(Fp-lastFp)); lastFp = Fp;
    [Fp,J] = F(p,aux);
    fail_cnt = 0;
    fprintf(['  res (rms/max), max_res_step, lam:  %.10g / %.10g   '...
             '%.10g   %g\n'],sqrt(mean((y-Fp).^2)),max(abs(y-Fp)),stepy,lam);
	%figure(3); plot(abs(y-Fp)); drawnow
  else
    lam = min(lam*10,1e5);
    fail_cnt = fail_cnt + 1;
  end
  stepy_DanielMartinec = .00005; % .005 0.1 .001
  if stepy < stepy_DanielMartinec
    disp(['!!! ended by condition stepy < ' num2str(stepy_DanielMartinec) ...
          '. Code modified by Daniel Martinec !!!']);
    break;
  end
end

% rearrange computed parameter vector p to P, X
for k = 1:K
  P(k2idx(k),:) = (P0(k2idx(k),:) + reshape(aux.TP{k}*p([1:11]+(k-1)*(11+RADIAL*3)),[3 4]));
  if RADIAL
    radial(k).u0 = p([12:13]+(k-1)*(11+RADIAL*3));
    radial(k).kappa = p([14]+(k-1)*(11+RADIAL*3));
  end
end
for n = 1:N
  X(:,n) = X0(:,n) + aux.TX{n}*p((11+RADIAL*3)*K+[1:3]+(n-1)*3);
end

return


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%
% function F: (Np,1) --> (Ny,1)x(Ny,Np), [y,J]=F(p), value y and jacobian J=dF(p)/dp of the function.
%
% p ... size ((11+3)*K+3*N,1), p = [iP(1); u0(1); kappa(1); .. iP(K); u0(K); kappa(K); iX(1); .. iX(N)],
%   where Np = (11+2+raddeg)*K + 3*N
% aux ... auxiliary structure:
% aux.raddeg, aux.P0, aux.X0 ... see above
% aux.TP{1:K} ... size (12,11), Pk(:) = P0k+ aux.TP{k}*iPk
% aux.TX{1:N} ... size (4,3), Xn = X0n + aux.TX{n}*iXn
% aux.qivis ... size (K,N), has 1 in entries corresponding to visible image points
% y ... size (2*nnz(aux.qivis),1), visible image observations, stacked as [q(1,1); q(2,1); .. q(2*K,N)], unobserved q are omitted
%%
% We consider the imaging model as
% u = e2p(x)
% x = P*X
% P = P0 + TP*iP
% X = X0 + TX*iX
%%
function [y,J] = F(p,aux)
%
[K,N] = size(aux.qivis);
NR = aux.RADIAL*3; % number of radial distortion paramters
%
% rearrange p to P, X [,radial]
for k = 1:K
  P(k2idx(k),:) = aux.P0(k2idx(k),:) + reshape(aux.TP{k}*p([1:11]+(k-1)*(11+NR)),[3 4]);
  if aux.RADIAL
    radial(k).u0 = p([12:13]+(k-1)*(11+NR));
    radial(k).kappa = p([14]+(k-1)*(11+NR));
  end
end
X = zeros(4,N);
for n = 1:N
  X(:,n) = aux.TX{n}*p((11+NR)*K+[1:3]+(n-1)*3);
end
X = aux.X0 + X;
%
% compute retina points q
for k = 1:K
  x(k2idx(k),:) = P(k2idx(k),:)*X;
  q(k2idx(k,2),:) = p2e(x(k2idx(k),:));
  if aux.RADIAL
	q(k2idx(k,2),:) = raddist(q(k2idx(k,2),:),radial(k).u0,radial(k).kappa);
  end
end
qq = reshape(q,[2 K*N]);
qq = qq(:,aux.qivis);
y = qq(:); % function value
%
% compute Jacobian J = dF(p)/dp
if nargout<2, return, end
[kvis,nvis] = find(aux.qivis);
Ji = zeros(2*length(kvis)*(11+NR+3),1); Jj = zeros(size(Ji)); Jv = zeros(size(Ji));
cnt = 0;
for l = 1:length(kvis)  % loop for all VISIBLE points in all cameras
  k = kvis(l);
  n = nvis(l);
  xl = x(k2idx(k),n);
  ul = p2e(xl);
  
  % Compute derivatives (Jacobians). Notation: E.g., dudx = du(x)/dx, etc.
  dxdP = kron(X(:,n)',eye(3))*aux.TP{k}; % dx(iP,iX)/diP
  dxdX = P(k2idx(k),:)*aux.TX{n}; % dx(iP,iX)/diX
  dudx = [eye(2) -ul]/xl(3);
  if aux.RADIAL
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
J = sparse(Ji,Jj,Jv);
return


function [i,j,v] = spidx(I,J,V)
%
i = I'*ones(1,length(J));
j = ones(length(I),1)*J;
i = i(:);
j = j(:);
v = V(:);
return


function P = normP(P)
for k = 1:size(P,1)/3
  Pk = P(k2idx(k),:);
  P(k2idx(k),:) = Pk/sqrt(sum(sum(Pk.*Pk)));
end
return


function x = normx(x)
x = x./(ones(size(x,1),1)*sqrt(sum(x.*x)));
return