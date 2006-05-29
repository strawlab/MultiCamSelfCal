%fill_mm_bundle Proj. reconstruction from MM [with bundle adjustment].
%
%  Call fill_mm [and bundle adjustment].
%
%  [ P,X, u1,u2, info ] = fill_mm_bundle(M [,opt])
%
%  Parameters:
%    M .. measurement matrix (MM) with homogeneous image points with NaNs
%         standing for the unknown elements in all three coordinates
%    imsize .. double(2,m), image sizes: imsize(:,i) is size of image i
%                           m .. No. of cameras
%    opt .. options with default values in ():
%           .no_BA(0) .. whether refine using bundle adjustment
%           .verbose(1) .. whether display info
%           .verbose_short .. see opt in bundle_PX_proj
%           ... other options see in fill_mm
%
%  Return parameters:
%    info.R_lin .. linear estimation of filled M
%    ... other parameters see in fill_mm

function [ P,X, u1,u2, info ] = fill_mm_bundle(M, imsize, opt)

if nargin < 3, opt = []; end
if ~isfield(opt, 'no_BA')
  opt.no_BA = 0; end
if ~isfield(opt, 'verbose'),
  opt.verbose = 1; end
  
[P,X, u1,u2, info] = fill_mm(M, opt);

info.R_lin = P*X;

if ~opt.no_BA & length(u1) < size(M,1)/3 & length(u2) < size(M,2)
  if opt.verbose, fprintf(1, 'Bundle adjustment...\n'); tic; end
  
  [m,n] = size(M); m = m/3; r1 = setdiff(1:m,u1); r2 = setdiff(1:n,u2);
  [P,X] = bundle_PX_proj(P,X, normalize_cut(M(k2i(r1),r2)), imsize, opt);
  % old bundler: 
  %[P,X] = qPXbundle_cmp(P,X, normalize_cut(M(k2i(r1),r2)));
  
  if opt.verbose, disp(['(' num2str(toc) ' sec)']); end
  info.err.BA = dist(M(k2i(r1),r2), P*X, info.opt.metric);
  if opt.verbose, fprintf('Error (after BA): %f\n', info.err.BA);
  else, fprintf(' %f\n', info.err.BA); end
else, if ~opt.verbose, fprintf('\n'); end; end
