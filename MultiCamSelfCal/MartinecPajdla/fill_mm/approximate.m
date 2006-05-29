%approximate Compute r-rank approximation of MM using null-space.
%
%  The approximated matrix is P*X.

function [P,X, u1,u2] = approximate(M, r, P, opt)

[m n]   = size(M);
rows    = find(mean(abs(P')) > opt.tol); %find(sum(P'))';
nonrows = setdiff(1:m, rows);

if opt.verbose, fprintf(1,'Immersing columns of MM into the basis...'); tic;end
[Mapp, noncols, X] = approx_matrix(M(rows,:), P(rows,:),r, opt);
if opt.verbose, disp(['(' num2str(toc) ' sec)']); end

% The rows of NULLSPACE now contain all the nullspaces of the crossproduct
% spaces.  Use the nullspace to approximate M, taking r least principal
% components.
cols = setdiffJ(1:n, noncols);
if length(cols) < r; % it will not be able to extend the matrix correctly
  u1 = 1:m; u2 = 1:n;
else
  if isempty(nonrows), u1 = []; r1 = 1:m; else
    if opt.verbose,
      disp('Filling rows of MM which have not been computed yet...'); end
    [Mapp1, u1, Pnonrows] = extend_matrix(M(:,cols), Mapp(:,cols), ...
                                          X(:,cols), rows, nonrows, r,opt.tol);
    Mapp = []; Mapp(:,cols) = Mapp1;
    if length(u1) < length(nonrows), P(setdiff(nonrows,u1),:) = Pnonrows; end
    r1 = union(rows, setdiff(nonrows,u1)); P = P(r1,:);
  end
  if isempty(noncols), u2 = []; else
    if opt.verbose
      disp('Filling columns of MM which have not been computed yet...'); end
    [Mapp_tr, u2, Xnoncols_tr] = extend_matrix(M(r1,:)', Mapp(r1,cols)', P',...
                                               cols, noncols, r, opt.tol);
    Mapp2 = Mapp_tr'; Xnoncols = Xnoncols_tr';
    if length(u2) < length(noncols), X(:,setdiff(noncols,u2)) = Xnoncols; end
    X = X(:, union(cols, setdiff(noncols, u2)));
    if sum(~sum(X)), keyboard; end
  end
% These extensions are necessary because the nullspace might not allow us to
% compute every row of the approximating rank r linear space, and then this
% linear space might not allow us to fill in some columns, if they are
% missing too much data.
end
if sum(~sum(X)), keyboard; end


%approx_matrix Immerse columns of MM into the basis.

function [Mapp, misscols, X] = approx_matrix(M, P, r, opt)

[m n] = size(M); misscols = [];
Mapp(m, n) = NaN; X(r,n) = NaN; % memory allocation

if ~isempty(P)
% P has r columns, which span the r-D space that gives the best linear
% surface to approximate M.
  for j = 1:n
    rows = find(~isnan(M(:,j)));
    if rank(P(rows,:), opt.tol) == r
      X(:,j) = P(rows,:)\M(rows,j); Mapp(:,j) = P*X(:,j);
    else
      misscols = [misscols, j];
    end
  end
end


%extend_matrix Fill rows of MM which have not been computed yet.
%
%  [E, unrecovered] = extend_matrix(M,INC,subM, rows, nonrows, r)
%
%  Parameters:
%    rows ... rows of M which have been used to find the solution
%    subM ... is a fit to just these rows
%    nonrows ... indicate rows of that still need to be fit
%
%  Output parameters:
%    Pnonrows ... in terms of unrecovered rows

function [E, unrecovered, Pnonrows] = extend_matrix(M, subM, X, rows, ...
                                                  nonrows, r, tol)

E(size(M,1),size(M,2)) = NaN;
E(rows,:) = subM; unrecovered = []; row = 0; Pnonrows = [];
for i = nonrows
  cols = find(~isnan(M(i,:)));
  if rank(X(:,cols)) == r
    if max(abs(M(i,cols)/X(:,cols) * X)) > 1/tol
      unrecovered = [unrecovered i];      
    else, row = row + 1; 
      Pnonrows(row,:) = M(i,cols)/X(:,cols); E(i,:) = Pnonrows(row,:)*X;
    end
  else
    unrecovered = [unrecovered i];
  end
end


function c = setdiffJ(a,b)  %J as Jacobs so that matlab's setdiff isn't damaged
c = [];
for i = a
  if ~member(i,b)
     c = [c,i];
  end
end


%member(e,s) Return 1 if element e is a member of set s. Otherwise return 0.

function c = member(e,s)
c = 0;
for i = s
  if i == e
     c = 1;
     break
  end
end
