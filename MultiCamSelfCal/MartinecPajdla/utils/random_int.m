%random_int Returns random integer is specified range.
%
%  y = random_int(from, to)

function y = random_int(from, to)

y = floor(from + (1 + to - from)*rand);