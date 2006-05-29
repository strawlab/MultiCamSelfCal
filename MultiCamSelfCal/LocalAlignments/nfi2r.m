% nfi2r   Computes rotation matrix, axis of rotation and the angle are given
%
% R = nfi2r(n,fi)
% Inputs:
% n[3x1]  ... axis of rotation (vector of direction)
% fi[rad] ... angle of rotation (counter clockwise)
% Return:
% R ... rotation matrix
%
% T. Svoboda, 3/1998, CMP Prague 
%
% $Id: nfi2r.m,v 1.1 2003/07/03 15:38:40 svoboda Exp $

% page 203 of the book:
% @BOOK{Kanatani90,
% AUTHOR             = {Kanatani, Kenichi},
% PUBLISHER          = {Springer-{V}erlag},
% TITLE              = {Group-{T}heoretical Methods in Image Understanding},
% YEAR               = {1990},
% HARDCOPY            = { CMPlib.book.BC14 },
% SIGNATURE          = {X-copy},
% ISSN_ISBN          = {3-540-51263-5},
%

function R = nfi2r(n,fi) 

n = n./norm(n,2);
cfi = cos(fi);
sfi = sin(fi);

R(1,1:3) = [ cfi+n(1)^2*(1-cfi), n(1)*n(2)*(1-cfi)-n(3)*sfi, n(1)*n(3)*(1-cfi)+n(2)*sfi ];
R(2,1:3) = [ n(1)*n(2)*(1-cfi)+n(3)*sfi, cfi+n(2)^2*(1-cfi), n(2)*n(3)*(1-cfi)-n(1)*sfi ];
R(3,1:3) = [ n(3)*n(1)*(1-cfi)-n(2)*sfi, n(3)*n(2)*(1-cfi)+n(1)*sfi, cfi+n(3)^2*(1-cfi) ];

R = R'; % due to reverse notation of Kanatani

return
