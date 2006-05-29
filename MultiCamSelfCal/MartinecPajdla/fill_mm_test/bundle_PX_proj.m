% [P,X] = bundle_PX_proj(P0,X0,u,imsize [,opt])  Projective bundle adjustment.
%
% P0 ... double(3*K,4), joint camera matrix
% X0 ... double(4,N), scene points
% u ... double(2*K,N), joint image point matrix with nonhomogeneous image points
% imsize ... double(2,K), image sizes: imsize(:,k) is size of image k
% P, X ... bundled reconstruction
%
% P0, X0 and u need not be preconditioned - preconditioning is done inside
% this function.
%
% opt.verbose (default 1) .. whether display info
%    .verbose_short(default 0) .. whether short info

function [P,X] = bundle_PX_proj(P0,X0,q,imsize, opt)

if nargin < 5 | isempty(opt) | ~isfield(opt,'verbose')
  opt.verbose = 1; end
if ~isfield(opt,'verbose_short')
  opt.verbose_short = 0; end

RADIAL = 0; % Commented by DM (nargin > 4); % don't estimate/estimate radial distortion 
[K,N] = size(q); K = K/2;

% precondition
for k = 1:K
  H{k} = vgg_conditioner_from_image(imsize(:,k));
  P0(k2i(k),:) = H{k}*P0(k2i(k),:);
  q(k2i(k,2),:) = nhom(H{k}*hom(q(k2i(k,2),:)));
end

P0 = normP(P0);
X0 = normx(X0);

% form observation vector y
qq = reshape(q,[2 K*N]);
qivis = reshape(all(~isnan(qq)),[K N]); % visible image points
qq = qq(:,qivis);
y = qq(:);


% Compute matrices TP,TX, describing local coordinate systems tangent to P0(:), X0.
% Having homogeneous N-vector X, in the neighborhood of X0 it can be parameterized (minimaly)
% by inhomogeneous (N-1)-vector iX as X = X0 + TX*iX, where TX is a non-singular (N,N-1) matrix.

for n = 1:N
  [qX,dummy] = qr(X0(:,n));
  TX{n} = qX(2:end,:)';
end
for k = 1:K
  [qP,dummy] = qr(reshape(P0(k2i(k),:),[12 1])); 
  TP{k} = qP(2:end,:)';
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

p = levmarq('F',...%@F,    % commented by DM (perhaps Matlab version conflict)
    p0,opt,P0,TP,X0,TX,y,qivis,RADIAL);

% rearrange computed parameter vector p to P, X
for k = 1:K
  P(k2i(k),:) = inv(H{k})*(P0(k2i(k),:) + reshape(TP{k}*p([1:11]+(k-1)*(11+RADIAL*3)),[3 4]));
  if RADIAL
    radial(k).u0 = p([12:13]+(k-1)*(11+RADIAL*3));
    radial(k).kappa = p([14]+(k-1)*(11+RADIAL*3));
  end
end
for n = 1:N
  X(:,n) = X0(:,n) + TX{n}*p((11+RADIAL*3)*K+[1:3]+(n-1)*3);
end

if opt.verbose_short, fprintf(')'); end
return


%%
% function F: (Np,1) --> (Ny,1)x(Ny,Np), [y,J]=F(p), value y and jacobian J=dF(p)/dp of the function.
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
function [y,J] = F(p,P0,TP,X0,TX,y,qivis,RADIAL)
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


%%%%%%%%%% local functions %%%%%%%%%%%

% p = levmarq(F,p,opt,varargin) Minimize || F(p,varargin{:}) || over p. By
% Levenber-Marquardt.
%
% F ... handle to function [y,J] = F(p,varargin{:}), yielding value
%       y=F(p,varargin{:}) and jacobian J. aux is typically a structure
%       passing auxiliary arguments to F.
% p ... initial parameter vector
% opt ... options structure with possible fields :-
%   - verbose ... printing residuals
%   - res_scale ... residual scale, the prined residuals are multiplied by
%   ressc before printing; useful if normalization were done before calling
%   levmarq
%   - max_niter ... maximum number of iterations
%   - max_stepy ... maximal step of residual value (after multiplying by
%     res_scale) for termination
%   - lam_init ... initial value of lambda

function p = levmarq(F,p,opt,varargin)

% handle options
if ~isfield(opt,'verbose'), opt.verbose = 0; end
if ~isfield(opt,'res_scale'), opt.res_scale = 1; end
if ~isfield(opt,'max_niter'), opt.max_niter = 10000; end
if ~isfield(opt,'max_stepy'), max_stepy_undef = 1; opt.max_stepy = 100*eps*opt.res_scale; end
if ~isfield(opt,'lam_init'), opt.lam_init = 1e-4; end

%OLDWARN = warning('off');  % commented by DM (perhaps Matlab version conflict)

% Minimize || F(p) || over p. By Newton/Levenber-Marquardt.
lastFp = +Inf;
stepy = +Inf;
lam = opt.lam_init;
nfail = 0;
niter = 0;
[Fp,J] = feval(F,p,varargin{:});
if issparse(J)
  eyeJ = speye(size(J,2)); 
else
  eyeJ = eye(size(J,2));
end

% print out initial residuals
if opt.verbose | opt.verbose_short
  if ~opt.verbose_short
    fprintf('                %14.10g [rms] %14.10g [max]\n',...
            opt.res_scale*sqrt(mean((Fp).^2)),opt.res_scale*max(abs(Fp)));
  else
    fprintf('(rms/max/stepmax: %g/%g/', ...
            opt.res_scale*sqrt(mean((Fp).^2)),opt.res_scale*max(abs(Fp))); end
end

while (nfail < 20) & (stepy*opt.res_scale > opt.max_stepy) & (niter < opt.max_niter)

  D = -(J'*J + lam*eyeJ) \ (J'*Fp);
  if any( isnan(D) | abs(D)==inf )
    p = p*nan;
    return
  end
  FpD = feval(F,p+D,varargin{:});
  
  if sum((Fp).^2) > sum((FpD).^2) % success
    p = p + D;
    lam = max(lam/10,1e-15);
    stepy = max(abs(Fp-lastFp));
    lastFp = Fp;
    [Fp,J] = feval(F,p,varargin{:});
    nfail = 0;
    niter = niter + 1;
  else % failure
    lam = min(lam*10,1e5);
    nfail = nfail + 1;
  end

  % if success, print out residuals
  if (opt.verbose | opt.verbose_short) & nfail==0
    if ~opt.verbose_short
      fprintf(' %7.2g [lam]: %14.10g [rms] %14.10g [max] %10.5g [stepmax]\n',lam,opt.res_scale*sqrt(mean((Fp).^2)),opt.res_scale*max(abs(Fp)),opt.res_scale*stepy); 
    else fprintf(' %g/%g/%g', sqrt(mean((Fp).^2)),opt.res_scale*max(abs(Fp)),opt.res_scale*stepy); end
  end
end

if ~exist('max_stepy_undef') & stepy*opt.res_scale <= opt.max_stepy
  fprintf('\n!!! finished because of high opt.max_stepy(=%f)', opt.max_stepy); end

%warning(OLDWARN);    % commented by DM (perhaps Matlab version conflict)
return


function [C,invC] = vgg_conditioner_from_image(c,r)
%
% function [C,invC] = vgg_conditioner_from_image(image_width, image_height)
%
%   Makes a similarity metric for conditioning image points.
%
%   Also can be called as vgg_conditioner_from_image([image_width image_height])
%
%   invC is inv(C), obtained more efficiently inside the function.

if nargin<2
  r = c(2);
  c = c(1);
end

f = (c+r)/2;
C = [1/f 0 -c/(2*f) ;
     0 1/f -r/(2*f) ;
     0 0 1];

if nargout > 1
  invC = [f 0 c/2 ;
          0 f r/2 ;
          0 0 1];
end


function x = nhom(x)
%nhom  Projective to euclidean coordinates.
%     x = nhom(x_) Computes euclidean coordinates by dividing 
%     all rows but last by the last row.
%       x_ ... Size (dim+1,N) Projective coordinates.
%       x ... Size (dim,N). Euclidean coordinates.
%       (N can be arbitrary.)
if isempty(x)
  x = []; 
  return; 
end
d = size(x,1) - 1;
x = x(1:d,:)./(ones(d,1)*x(end,:));
return


function x = hom(x)
%hom  Euclidean to projective coordinates.
%     x_ = hom(x) Adds the last row of ones.
%       x ... Size (dim,N). Euclidean coordinates.
%       x_ ... Size (dim+1,N) Projective coordinates.
%       (N can be arbitrary.)

if isempty(x), return, end
x(end+1,:) = 1;
return


% normP  Normalize joint camera matrix so that norm(P(k2i(k),:),'fro') = 1 for each k.

function P = normP(P)

for k = 1:size(P,1)/3
  Pk = P(k2i(k),:);
  P(k2i(k),:) = Pk/sqrt(sum(sum(Pk.*Pk)));
end

return


% x = normx(x)  Normalize MxN matrix so that norm of each its column is 1.

function x = normx(x)

if ~isempty(x)
  x = x./(ones(size(x,1),1)*sqrt(sum(x.*x)));
end

return


function i = k2i(k,step)

%i = k2i(k [,step])
% Computes indices of matrix rows corresponding to views k. If k is a scalar,
% it is    i = [1:step]+step*(k-1).
% implicit: step = 3   
% E.g., for REC.u, REC.P, REC.X use k2i(k),
%       for REC.q use k2i(k,2).

if nargin<2
  step = 3;
end

k = k(:)';
i = [1:step]'*ones(size(k)) + step*(ones(step,1)*k-1);
i = i(:);
return