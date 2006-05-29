%FDs	error trem for fundamentel m. - squares of Sampson's distances
%function Ds = FDs(F,u)
%where u are corespondences and F is fundamental matrix

function Ds = FDs(F,u)
rx1  = (F(:,1)' * u(1:3,:)).^2;
ry1  = (F(:,2)' * u(1:3,:)).^2;
rx2  = (F(1,:)  * u(4:6,:)).^2;
ry2  = (F(2,:)  * u(4:6,:)).^2;
r    = Fr(F,u);
Ds   = r ./ (rx1 + ry1 + rx2 + ry2);
