%subseq_longest Find the longest continuous subsequences in columns of MM.
%
%  Put the initial image of the longest continuous subsequence of known
%  points in column ``p'' to ``b(p)''.
%
%  [b, len] = subseq_longest(I)
%
%    Parameters:
%      len  ... len(p) is length of the longest continuous
%               subsequence of known points in column ``p''

function [b, len] = subseq_longest(I)

[m n]      = size(I);

b(n)       = 0;  % memory allocation
len(n) = 0;  % "               "

for p = 1:n
  seq(1:m) = 0;
  l        = 1;
  for i = 1:m
    if I(i,p)
      seq(l) = seq(l) +1;
    else
      l      = i+1;
    end
  end
  len(p)     = max(seq);
  best       = find(seq == len(p));
  b(p)       = best(1);
end

%b(:) = 1;  % debug