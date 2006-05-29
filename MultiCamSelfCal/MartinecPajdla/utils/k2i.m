%k2i Compute indices of matrix rows corresponding to views k [with some step].
%
%  i = k2i(k [,step])
%  
%  If k is scalar, it is i = [1:step]+step*(k-1).
%
%  Default: step = 3
%
%  E.g., for REC.u, REC.P, REC.X use k2i(k),
%        for REC.q use k2i(k,2).

function i = k2i(k,step)

if nargin<2
  step = 3;
end

k = k(:)';
i = [1:step]'*ones(size(k)) + step*(ones(step,1)*k-1);
i = i(:);
