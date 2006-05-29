%normu Normalize image points to be used for LS estimation.
%   A = normu(u) finds normalization matrix A so that mean(A*u)=0 and
%   mean(||A*u||)=sqrt(2). (see Hartley: In Defence of 8-point Algorithm,
%   ICCV`95).
%
%   Parameters:
%      u ... Size (2,N) or (3,N). Points to normalize.
%      A ... Size (3,3). Normalization matrix.

function A = normu(u)

if size(u,1)==3, u = p2e(u); end

m        = mean(u')'; % <=> mean (u,2)
u        = u - m*ones(1,size(u,2));
distu    = sqrt(sum(u.*u));
r        = mean(distu)/sqrt(2);
if ~r, A = []; return; end     % one of degenarate configurations
A        = diag([1/r 1/r 1]);
A(1:2,3) = -m/r;
