%seig			sorted eigenvalues
function [V,d] = seig(M)
[V,D]    = eig(M);
[d,s]    = sort(diag(D));
V        = V(:,s);
