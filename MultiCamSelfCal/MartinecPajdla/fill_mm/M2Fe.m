%M2Fe Estimate epipolar geometry of MM in sequence or using the central image.
%
%  [F,e,rows,nonrows] = M2Fe(M, central)
%
%     Parametres:
%       central ... If zero, the concept of sequence is used otherwise the
%                   concept of the central image is used with central
%                   image number ``central''.

function [F,ep,rows,nonrows] = M2Fe(M, central)

m = size(M,1)/3; nonrows = []; F = []; ep = [];

if central, rows = [1:central-1, central+1:m];
else,       rows = [2:m]; end

%estimate the fundamental matrices and epipoles with the method of [Har95]
for k = rows
  if central, j = central;
  else,       j = k-1; end
  G = u2FI([M(3*k-2:3*k,:);M(3*j-2:3*j,:)], 'donorm');
  if G==0
    rows    = setdiff(rows,k); 
    nonrows = [nonrows k];
  else
    %ep=null(G');  %it must be transposed otherwise it's the second epipole
    % sometimes returns empty matrix => compute it "by hand" by svd
    [u,s,v] = svd(G);
    epip = u(:,3);
    
    F(k,j,1:3,1:3) = G;
    ep(k,j,1:3) = epip;
  end
end

if central, rows = union(rows, central);
else rows = [1 rows]; end
  
if ~isempty(nonrows) & ~central  % find the longest continuous subsequence
  I_(rows,1) = 1;
  [b, len] = subseq_longest(I_);
  rows = b:b+len-1;
  nonrows = setdiff(1:m, rows);
end
