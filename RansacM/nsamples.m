% nsamples  calculate the number of samples yet needed
%
% N = nsamples(no_i,ptNum,s,conf)
% no_i ... current number of inliers
% ptNum ... total number of points
% s ... sample size
% conf ... confidence value
% 
% $Id: nsamples.m,v 1.1 2005/05/23 16:15:59 svoboda Exp $

function N = nsamples(no_i,ptNum,s,conf)

outl = 1-no_i/ptNum;
N	 = log(1-conf) / log(1-(1-outl)^s+eps);

return;