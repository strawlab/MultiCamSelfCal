%L2depths Compute depths of PRMM from basis L.
%
%  No known depths are exploited. These can be different because of noise
%  etc.
%
%  Parameters:
%    opt.verbose(1) .. whether display info

function [Mdepths, lambda] = L2depths(L, M, Idepths, opt)

if nargin < 4, opt = []; end
if ~isfield(opt,'verbose')
  opt.verbose = 1; end

if opt.verbose, fprintf('Computing depths...'); tic; end

Mdepths = M;

[m n] = size(M); m = m/3;
lambda(m, n) = 0;  % memory allocation

for j = 1:n
  full     = find(~isnan(M(1:3:end,j)));
  mis_rows = intersect(find(Idepths(:,j)==0),full);
  if length(mis_rows) > 0
    submatrix = spread_depths_col(M(k2i(full),j),Idepths(full,j));
        
    % We want submatrix to be in the space L -> 
    % we search for combination of columns of the base of L i.e. 
    % L(k2i(full),:)*res(1:4)-submatrix*[1 res(5:length(res))] = 0
    right = submatrix(:,1);
    A     = [ L(k2i(full),:) -(submatrix(:,2:size(submatrix,2))) ];
    if rank(A) < size(A, 2)  % depths cannot be computed => kill the data
      kill = full(~Idepths(full,j));
      Mdepths(k2i(kill),j) = NaN; lambda(kill,j) = NaN;
    else
      res   = A \ right;
      
      %test: er should be near to zero
      %er=L(k2i(full),:)*res(1:4)-submatrix*[1 res(5:length(res))']'
      
      % depth corresponding to right is/are set to 1
      i = full(find(right(1:3:end))); lambda(i,j) = 1;
      Mdepths(k2i(i),j) = M(k2i(i),j);
      
      for ii = 1:size(submatrix,2)-1
        i = full(find(submatrix(1:3:end,1+ii))); lambda(i,j) = res(4+ii);
        Mdepths(k2i(i),j) = M(k2i(i),j)*lambda(i,j); 
      end
    end
  end
end

if opt.verbose, disp(['(' num2str(toc) ' sec)']); end
