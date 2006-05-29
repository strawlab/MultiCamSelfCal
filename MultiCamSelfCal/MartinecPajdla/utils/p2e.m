function x = p2e(x_)

%P2E  Projective to euclidean coordinates.
%     x = p2e(x_) Computes euclidean coordinates by dividing 
%     all rows but last by the last row.
%       x_ ... Size (dim+1,N) Projective coordinates.
%       x ... Size (dim,N). Euclidean coordinates.
%       (N can be arbitrary.)

if isempty(x_)
  x = []; 
  return; 
end
dim = size(x_,1) - 1;
x = x_(1:dim,:) ./ (ones(dim,1)*x_(dim+1,:));
