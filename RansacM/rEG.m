function [F, inls] = rEG(u,th,th4,conf,ss)
% REG  robust estimation of the epipolar geometry via RANSAC
%
% [H, inls] = rRG(u,th,{th4=th,conf=0.99,ss=8})
% u ... 6xN pairs homogenous coordinates
% th ... inlier tolerance in pixels
% th4 ... currently not used
% conf ... confidence, the higher -> more samples
% ss ... sample size
%
% F ... 3x3 fundamental matrix
% inls ... 1xN logical 1->inlier. 0->outlier
%
% $Id: rEG.m,v 1.1 2005/05/23 16:16:00 svoboda Exp $


MAX_SAM = 100000;  % maimal number of random samples

len = size(u,2);

% parsing the inputs
if nargin < 3
  th4 = th;
end

if nargin < 4
  conf = 0.99;
end

if nargin < 5
  ss = 8;	   % sample size
end

len = size(u,2);
ptr = 1:len;
max_i = 5;
max_sam = MAX_SAM;
 
no_sam = 0;
no_mod = 0;
 
th = 2*th^2;

while no_sam < max_sam   
  for pos = 1:ss
      idx = pos + ceil(rand * (len-pos));
      ptr([pos, idx]) = ptr([idx, pos]);
  end;
  
  no_sam = no_sam +1;
  
  sF = u2Fdlt(u(:,ptr(1:ss)),0);
  errs = Fsampson(sF,u);
  v	   = errs < th;
  no_i = sum(v);
  
  if max_i < no_i
	inls = v;
	F	 = sF;
	max_i = no_i;
	max_sam = min([max_sam,nsamples(max_i, len, ss, conf)]);
  end
end

%%%
% refine the F by using all detected outliers and with point normalization
F = u2Fdlt(u(:,inls),1);

if no_sam == MAX_SAM
  warning(sprintf('RANSAC - termination forced after %d samples expected number of samples is %d',  no_sam, exp_sam));
else
  disp(sprintf('RANSAC: %d samples, %d inliers out of %d points',no_sam,sum(inls),len))
end;

return;