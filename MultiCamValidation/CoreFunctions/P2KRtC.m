% [K,R,t,C] = P2KRtC(P)
% decompose the euclidean 3x4 projection matrix P into the
% 
% K ... 3x3 upper triangular calibration matrix
% R ... 3x3 rotation matrix
% t ... 3x1 translation vector
% C ... 3x1 position od the camera center
%
% $Id: P2KRtC.m,v 2.0 2003/06/19 12:07:08 svoboda Exp $

function [K,R,t,C] = P2KRtC(P)

P = P./norm(P(3,1:3));

[K,R] = rq(P(:,1:3));
t = inv(K)*P(:,4);
C = -R'*t;

return;
