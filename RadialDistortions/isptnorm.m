% isptnorm ISotropic PoinT NORMalization
%
% [xnorm,T] = isptnorm(x);
% x ... [N x dim] coordinates
%
% xnorm ... normalized coordinates
% T     ... transformation matrix used
%
% T. Svoboda, 5/2001


function [xnorm,T] = isptnorm(x);


% data dimension 
dim = size(x,2);
N	= size(x,1);

% make homogenous coordinates
x(:,dim+1) = ones(N,1);

% compute sum of square diferences
for i=1:dim,
	ssd(:,i) = (x(:,i)-mean(x(:,i))).^2;
end

scale = (sqrt(dim)*N) / (sum(sqrt(sum(ssd'))));

T = zeros(dim+1);

for i=1:dim,
	T(i,i)     = scale;
	T(i,dim+1) = -scale*mean(x(:,i));
end
T(dim+1,dim+1) = 1;

xnorm = T*x';
xnorm = xnorm';
% return nonhomogenous part of the points coordinates
xnorm = xnorm(:,1:dim);



