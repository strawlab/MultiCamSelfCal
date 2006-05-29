%
% 	Function Mnorm=normalize_cut(M,I)
%
% normalizes homogenous coordinates and cuts the last coordinate
% (which then equals to 1).

function Mnorm=normalize_cut(M,I)

m=size(M,1)/3;

if nargin < 2, Mnorm=normalize(M);
else           Mnorm=normalize(M,I); end

Mnorm=Mnorm(union((1:m)*3-2,(1:m)*3-1),:);

return
