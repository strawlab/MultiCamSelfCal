function p=imcorr(sys,par,dp)
%IMCORR corrects image coordinates, which are contaminated by radial
%and tangential distortion.
%
%Usage:
%   p=imcorr(name,par2,dp)
%
%where
%   name = string that is specific to the camera and the framegrabber.
%          This string must be defined in configc.m
%   par2 = camera intrinsic parameters for correcting the coordinates.
%          these parameters are computed by using invmodel.m.
%   dp   = distorted image coordinates in pixels (n x 2 matrix)
%   p    = corrected image coordinates 

%   Version 3.0  10-17-00
%   Janne Heikkila, University of Oulu, Finland

NDX=sys(1); NDY=sys(2); Sx=sys(3); Sy=sys(4);
Asp=par(1); Foc=par(2);
Cpx=par(3); Cpy=par(4);
Rad1=par(5); Rad2=par(6);
Tan1=par(7); Tan2=par(8);


dx=(dp(:,1)-Cpx)*Sx/NDX/Asp;
dy=(dp(:,2)-Cpy)*Sy/NDY;

r2=dx.*dx+dy.*dy;
delta=Rad1*r2+Rad2*r2.*r2;

cx=dx.*(1+delta)+2*Tan1*dx.*dy+Tan2*(r2+2*dx.*dx); 
cy=dy.*(1+delta)+Tan1*(r2+2*dy.*dy)+2*Tan2*dx.*dy; 

p=NDX*Asp*cx/Sx+Cpx;
p(:,2)=NDY*cy/Sy+Cpy;
