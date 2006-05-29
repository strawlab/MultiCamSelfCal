function errs = Fsampson(F,u);
% FSAMPSON ... first order geometrical error (Sampson Distance)
% errs = Fsampson(F,u);
% F ... 3x3 Fundamental matrix
% u ... 6xN point pairs homogenous
% 
% errs ... 1xN error for each point pair
% 
% $Id: Fsampson.m,v 1.1 2005/05/23 16:15:59 svoboda Exp $

N = size(u,2);

u1 = u(1:3,:);
u2 = u(4:6,:);

errs = zeros(1,N);
for i=1:N
  Fu1 = F*u1(:,i);
  Fu2 = F'*u1(:,i);
  errs(i) = (u2(:,i)'*F*u1(:,i))^2 / (sum([Fu1(1:2)'.^2,Fu2(1:2)'.^2]));
end
