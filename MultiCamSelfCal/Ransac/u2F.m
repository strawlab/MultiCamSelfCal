%u2F    estimates fundamental matrix using ortogonal LS regression
%	F = u2F(u) estimates F from u using NORMU
%  F = u2F(u,'nonorm') disables normalization
%	see also NORMU, U2FA


function F = u2F (u, str)

if (nargin > 1) & strcmp(str, 'nonorm')
   donorm = 0;
else
   donorm = 1;
end

ptNum = size(u,2);

if donorm
   A1    = normu(u(1:3,:));
   A2    = normu(u(4:6,:));
   
   u1   = A1*u(1:3,:); 
   u2   = A2*u(4:6,:); 
end

for i = 1:ptNum
   Z(i,:)   = reshape(u1(:,i)*u2(:,i)',1,9);
end

M       = Z'*Z;
V       = seig(M);
F = reshape(V(:,1),3,3);

[uu,us,uv] = svd(F);
[y,i]      = min (abs(diag(us)));  
us(i,i)    = 0;
F          = uu*us*uv';

if donorm
   F = A1'*F*A2;
end

F = F /norm(F,2);
