% estimatePX ... estimate the projective shape and motion
%
% [P,X,Lambda] = estimatePX(Ws, Lambda)
%
% Ws ....... 3*nxm measurement matrix
% Lambda ... nxm matrix containg some initial projective depths
%            (see also: ESTIMATELAMBDA)
%
% P ........ 3*nx4 matrix containing the projective motion
% X ........ 4xm matrix containing the projective shape
% Lambda ... the new estimation of the projective depths

function [P,X,Lambda] = estimatePX(Ws, Lambda)
n = size(Ws,1)/3;
m = size(Ws,2);

% compute 1st updated Ws
for i = 1:n
    for j = 1:m
	Ws_updated(3*i-2, j) = Ws(3*i-2, j) * Lambda(i, j);
	Ws_updated(3*i-1, j) = Ws(3*i-1, j) * Lambda(i, j);
	Ws_updated(3*i,   j) = Ws(3*i,   j) * Lambda(i, j);
    end
end

Lambda_new = Lambda;
iterations = 0;
errs = 1e10*[99.9,99];
tol	 = 1e-3;
while (errs(iterations+1)-errs(iterations+2)>tol),
    [U,D,V] = svd(Ws_updated);
    % the following loop is not needed since these elements of D
    % are not considered in further computations
    for i = 5:size(D,2)
	D(i, i) = 0;
    end
    
    % projective shape X and motion P
    P = U*D(1:size(U,2),1:4);
    X = V(:,1:4)';
    % U*D*V' == P*X
    
    % correct projective depths
    normfact = sum(P(3:3:(3*n),:)'.^2);
    Lambda_old = Lambda_new;
    Lambda_new = P(3:3:(3*n),:)./repmat(sqrt(normfact'),1,4)*X;
    
    % normalize lambdas
    lambnfr = sum(Lambda_new.^2);
    Lambda_new = sqrt(n)*Lambda_new./repmat(sqrt(lambnfr),n,1);
    lambnfc = sum(Lambda_new'.^2);
    Lambda_new = sqrt(m)*Lambda_new./repmat(sqrt(lambnfc'),1,m);
    
    for i = 1:n
	for j = 1:m
	    Ws_updated(3*i-2, j) = Ws(3*i-2, j) * Lambda_new(i, j);
	    Ws_updated(3*i-1, j) = Ws(3*i-1, j) * Lambda_new(i, j);
	    Ws_updated(3*i,   j) = Ws(3*i,   j) * Lambda_new(i, j);
	end
    end
    iterations = iterations + 1;
    errs = [errs,sum(sum(abs(Lambda_old-Lambda_new)))];
    % errs(iterations+2)
end
%iterations

[U,D,V] = svd(Ws_updated);
% compute new projective shape and motion
P = U*D(1:size(U,2),1:4);
X = V(:,1:4)';
X = X./repmat(X(4,:),4,1);
Lambda = Lambda_new;



