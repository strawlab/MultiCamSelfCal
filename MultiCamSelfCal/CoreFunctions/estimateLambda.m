% estimateLambda ... estimate some initial projective depth given
%                    the measurement matrix
%
% This algorithm is based on a paper by P. Sturm and B. Triggs called
% "A Factorization Based Algorithm for Multi-Image Projective Structure
%  and motion" (1996)
% Projective depths are estimated using fundamental matrices.
%
% [Lambda] = estimateLambda(Ws)
%
% Ws ...... the 3*nxm measurement matrix (the data should be normalized
%           before calling this functions)
% pair .... array of camera pairs containing Fundamental matrices and 
%           indexes of points used for their computations
%           it is the output from RANSAC validation step
%
% Lambda .. nxm matrix containing the estimated projective depths
%
% 09/2001, Dejan Radovic <dradovic@student.ethz.ch>
% 05/2002, Tomas Svoboda <svoboda@vision.ee.ethz.ch>

% $Author: svoboda $
% $Revision: 2.0 $
% $Id: estimateLambda.m,v 2.0 2003/06/19 12:06:49 svoboda Exp $
% $State: Exp $


function [Lambda] = estimateLambda(Ws,pair)
n = size(Ws,1)/3; % cameras
m = size(Ws,2);	  % frames

% estimate (n-1) fundamental matrices F_12, F_23, ..., F_(n-1)n
F = []; % the fundamental matrices
e = []; % the epipoles (as columns)
Lambda = ones(n,m); % the estimated projective depths
for i=1:n-1
  j=i+1;
  F_ij = pair(i).F;
  % compute epipole from F_ij*e_ij == 0
  [U,S,V] = svd(F_ij,0);
  % diag(S)'
  e_ij = V(:,size(V,2));
  for p=pair(i).idxin,
	q_ip = Ws(i*3-2:i*3,p);
	q_jp = Ws(j*3-2:j*3,p);
	Lambda(j,p) = Lambda(i,p)*((norm(cross(e_ij,q_ip)))^2/sum(cross(e_ij,q_ip).*(F_ij'*q_jp)));
	% Lambda(j,p) = Lambda(i,p)*(sum((F_ij'*q_jp).*cross(e_ij,q_ip))/(norm(F_ij'*q_jp))^2);
  end
end

return






