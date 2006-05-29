%eucl_dist_only Return Eucledian norm of the difference between two scenes.
%
%  [e_norm, distances] = eucl_dist_only(M0, M [,I [,step]])
%
%  Parameters:
%    step      .. same as in k2i (see help k2i)
%                 default: step = 2 i.e. inhomogenous coordinates are assumed
%
%    distances .. Eucledian distances between each known elements of M0 and M

function [e_norm, distances] = eucl_dist_only(M0, M, I, step)

if nargin < 3, I = ~isnan(M0(1:2:end,:)) & ~isnan(M(1:2:end,:)); end
if nargin < 4, step = 2; end
  
if nargin >= 3
  m = size(M,1)/step;
  if size(I,1) ~= m  &  ~isempty(M)
    disp(sprintf(['!!! Warning: eucl_dist_only:' ' the height of I is' ...
                  ' bad, it should be equal to %d'], m)); keyboard;end
end

known   = find(I);
diff = (M0(k2i(known,step)) - M(k2i(known,step))) .^ 2;

% sqrt must be performed on each point separately
for s = 1:step
  B(s,:)    = diff(s:step:end)';  % x-coordinates
  B(s,:)    = diff(s:step:end)';  % y-coordinates
end
distances = sqrt(sum(B));
e_norm    = sum(distances);
