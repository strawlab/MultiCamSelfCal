%combfirst Returns the first combination in order of shifting the least left
%number to the right.
%
%  function com=combfirst(n, k)
%
%n and k has the meaning of combination number.
function com=combfirst(n, k)

com=find(1 == ones(1,k-1));
com=[com k-1];

return