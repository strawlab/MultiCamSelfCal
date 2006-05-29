%fill_prmm Compute the null-space and fill PRMM.
%
%   Parameters:

function [P,X, u1,u2, lambda, info] = fill_prmm(M, Idepths, central, ...
                                                opt, info)

[NULLSPACE, result] = create_nullspace(M, Idepths, central, ...
                                       opt.create_nullspace);

info.create_nullspace             = opt.create_nullspace;
info.sequence{end}.tried          = result.tried;
info.sequence{end}.tried_perc     = result.tried/comb(size(M,2), 4) *100;
info.sequence{end}.used           = result.used;
info.sequence{end}.used_perc      = result.used/result.tried *100;
info.sequence{end}.failed         = result.failed;
info.sequence{end}.size_nullspace = size(NULLSPACE);

if opt.verbose
  disp(sprintf('Tried/used: %d/%d (%.1e %%/ %2.1f %%)', result.tried, ...
               result.used, info.sequence{end}.tried_perc, ...
               info.sequence{end}.used_perc));
  disp(sprintf('%d x %d'' is size of the nullspace', size(NULLSPACE,2), ...
               size(NULLSPACE,1))); end

[m,n] = size(M); m = m/3;

if size(NULLSPACE) == [0 0]
  P = []; X = []; u1 = 1:m; u2 = 1:n; lambda=[];
else
  r = 4;
  [L, S] = nullspace2L(NULLSPACE, r, opt);
  clear NULLSPACE;
  
  if isempty(opt.create_nullspace), threshold = .01;
  else, threshold = opt.create_nullspace.threshold; end
  if svd_suff_data(S, r, threshold)
    if opt.verbose
      dS = diag(S); %disp(diag(S));
      fprintf(1,'Smallest 2r singular values:%s.\n', sprintf(' %f', ...
                                                  dS(end-2*r:end))); end
    [Mdepths, lambda] = L2depths(L, M, Idepths, opt); info.Mdepths = Mdepths;
    [P,X, u1b,u2] = approximate(Mdepths, r, L, opt);
    u1 = union(ceil(u1b/3),[]); killb = setdiff(k2i(u1),u1b); 
    if ~isempty(killb), r1b = setdiff(1:3*m,u1b); kill = killb;
      for ib = killb(1:end-1), lower = find(killb > ib); 
        if kill(lower(1)-1) < kill(lower(1)) - 1,
          kill(lower) = kill(lower) -1; end; end
      P = P(setdiff(1:length(r1b),kill),:);end
    lambda = lambda(setdiff(1:m,u1),setdiff(1:n,u2)); % to fit P*X
  else P=[]; X=[]; u1=1:m; u2=1:n; lambda=[]; end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [L,S] = nullspace2L(NULLSPACE, r, opt)
% Compute the basis of MM (L) from the null-space.

if opt.verbose, fprintf(1,'Computing the basis...'); tic; end
if size(NULLSPACE,2) < 10*size(NULLSPACE,1) % orig:[A,S,U] = svd(NULLSPACE',0);
  [U,S,V]             = svd(NULLSPACE);
else 
  [U,SS]              = eig(NULLSPACE*NULLSPACE');
  dSS                 = diag(SS); l = length(dSS);
  [sortdSS(l:-1:1),I] = sort(dSS); I(l:-1:1) = I;  U = U(:,I);
  sortdSS             = max(sortdSS,zeros(1,l)); sortdSS=sqrt(sortdSS);
  for i=1:l, S(i,i) = sortdSS(i); end
end
L = U(:,end+1-r:end);
if opt.verbose, disp(['(' num2str(toc) ' sec)']); end

function r = comb(n,k)

% returns combination number n over k

r=1;
for i=1:k
  r=r*(n-i+1)/i;
end

function y = svd_suff_data(S,r, threshold)

% S is the singular value part of the svd of the nullspaces of the column
% r-tuples.  We'll want to be able to take the r least significant columns
% of U.  This is right because the columns of U should span the whole space
% that M's columns might span.  That is, M is FxP.  The columns of U should
% span the F-dimensional Euclidean space, since U is FxF.  However, we want 
% to make sure that the F-r-1'th singular value of S isn't tiny.  If it is,
% our answer is totally unreliable, because the nullspaces of the column 
% r-tuples don't have sufficient rank.  If this happens, it means that the 
% intersection of the column cross-product spaces is bigger than r-dimensional,
% and randomly choosing an r-dimensional subspace of that isn't likely to
% give the right answer.

Snumcols = size(S,2);
Snumrows = size(S,1);
if (Snumrows == 0 | Snumcols + r < Snumrows | Snumrows <= r)
  y = 0;
else
  y = S(Snumrows-r,Snumrows-r) > threshold;
end
