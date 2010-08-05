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
