%
% 	Function Mnorm=normalize(M,I)
%
% normalizes M by dividing each point by its homogenous coordinate
% (these coordinates equal to ones afterwards).
%
% Parameter I can be omitted for complete scenes.

function Mnorm=normalize(M,I)

m=size(M,1)/3;
n=size(M,2);

if nargin < 2
  I=ones(m,n);
end

Mnorm(1:3*m, 1:n) = M; % There are two reasons for this. (i) Make NaN the
                       % unknown data thus the whole matrix has to be filled
                       % by NaNs. (ii) Sometimes it happens that when there
                       % is a missing data in the last column(s), the
                       % column(s) disapppears.

known      = find(I);
big_enough = known(find( abs(M(known*3)) > eps ));
if m == 1, big_enough = big_enough'; end
  
if ~isempty(big_enough)
  div_by                      = repmat(M(big_enough*3)',3,1);
  Mnorm(k2i(big_enough)) = M(k2i(big_enough)) ./ div_by(:);
end

Mnorm(setdiff(known, big_enough)*3) = 1;
