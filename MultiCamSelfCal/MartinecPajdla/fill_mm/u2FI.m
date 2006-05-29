%u2FI Estimate fundamental matrix using ortogonal LS regression
%
%  F = u2F(u) estimates F from u using NORMU
%  F = u2F(u,'nonorm') disables normalization
%
%  see also NORMU, U2FA
%
%  Returns 0 if too few points are available

function F = u2FI (u, str, A1, A2)

sampcols = find(sum(~isnan(u(1:3:end,:))) == 2);
if length(sampcols) < 8
  F = 0; return
end

if (nargin > 2) & ~strcmp(str, 'nonorm') & ~strcmp(str, 'usenorm')
   donorm = 1;
else
   donorm = 0;
end

ptNum = size(sampcols,2);

if donorm
  A1    = normu(u(1:3,sampcols));
  A2    = normu(u(4:6,sampcols));
  if isempty(A1) | isempty(A2), F = 0; return; end
  
  u1   = A1*u(1:3,sampcols);  %in u1, u2 there are only columns of sampcols
  u2   = A2*u(4:6,sampcols); 
else
  u1   = u(1:3,sampcols);     %"					   "
  u2   = u(4:6,sampcols); 
end

for i = 1:ptNum
   Z(i,:)   = reshape(u1(:,i)*u2(:,i)',1,9);
end

M       = Z'*Z;
V       = seig(M);
F = reshape(V(:,1),3,3);

%odrizneme nejmensi vlastni slozku, aby F melo hodnost 2
[uu,us,uv] = svd(F);
%[y,i]      = min (abs(diag(us)));  
i = 3;
%if us(i,i) > 1e-12, disp('rank(F)>2'); end
us(i,i)    = 0;
F          = uu*us*uv';

if donorm | strcmp(str, 'usenorm')
  F = A1'*F*A2;
end

F1=F;

F = F /norm(F,2);

if rank(F) > 2
 %disp('!!! Error: u2FI: rank(F) > 2');
 % snizime hodnost, us(3,3) je stejne 1e-16
  [uu,us,uv] = svd(F);
  us(3,3)    = 0;
  F          = uu*us*uv';
end

%seig			sorted eigenvalues
function [V,d] = seig(M)
[V,D]    = eig(M);
[d,s]    = sort(diag(D));
V        = V(:,s);
