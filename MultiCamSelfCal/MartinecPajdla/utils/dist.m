%dist Return distance between image points in homog. coor. in specified metric.
%
%  d = dist(M1, M2, metric)
%
%  Parameters:
%    metric .. x- and y-coordinates are associated with a single image point
%              1 .. square root of sum of squares of x- and y-coordinates
%              2 .. std of x- and y-coordinates
%                   <=> equivalent to noise type 2 in noise_add

function d = dist(M1, M2, metric)

if nargin < 3, metric = 2; end

switch metric,
 case 1, I = ~isnan(M1(1:3:end,:)) &~isnan(M2(1:3:end,:));
  d = eucl_dist(M1, M2, I) / sum(sum(I));
 case 2, D = normalize_cut(M1) - normalize_cut(M2); 
  i = find(~isnan(D(1:2:end)));
  d = std([D(2*i-1) D(2*i)]);
 otherwise, error('dist: unknown metric');
end
