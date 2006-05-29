% mfFDs  first order geometric error (Sampson distance)
% m-version of the original c-code (mex) which were
% causing some problems

% $Author: svoboda $
% $Revision: 2.2 $
% $Id: mfFDs.m,v 2.2 2004/05/04 16:09:35 svoboda Exp $
% $State: Exp $

function err = mfFDs(F,u);

% disp('m-version of fFDs')

Fu1 = F*u(4:6,:);
Fu2 = (F'*u(1:3,:)).^2;
Fu1pow = Fu1.^2;

denom = Fu1pow(1,:)+Fu1pow(2,:)+Fu2(1,:)+Fu2(2,:);

errvec = zeros(1,size(u,2));
for i=1:size(u,2),
  xFx = u(1:3,i)'*Fu1(:,i);
  errvec(i) = xFx^2/denom(i);
end

err = errvec;
return

