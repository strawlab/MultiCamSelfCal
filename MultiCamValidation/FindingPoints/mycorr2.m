% mycorr2 modified version of the 2D correlation
%         for the use with im2col and col2im
%         see GETPOINT
% 
%
% $Id: mycorr2.m,v 2.0 2003/06/19 12:07:11 svoboda Exp $

% Note: It written in order to gain speed. The clarity of the code suffers accordingly

function R = mycorr2(X,G,Gn,Gn2)

% Gn  = G-mean(G);
% Gn2 = sqrt(sum(Gn.^2));

mX	= repmat(mean(X),size(X,1),1);
mXn = X - mX;
smX	= sum(mXn.^2); 

numerator = (mXn'*Gn)';
denominator = smX*Gn2;

R = numerator./denominator;

return