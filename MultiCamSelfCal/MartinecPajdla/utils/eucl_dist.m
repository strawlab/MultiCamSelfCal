%eucl_dist Return Eucledian norm of the difference between two scenes.
%
%  er = eucl_dist(M0, M [,I])
%
%  Note: Perspective cameras are assumed.

function er = eucl_dist(M0, M, I)

if nargin < 3, I = ~isnan(M0(1:3:end,:)) & ~isnan(M(1:3:end,:)); end

er = eucl_dist_only(normalize_cut(M0), normalize_cut(M), I);
