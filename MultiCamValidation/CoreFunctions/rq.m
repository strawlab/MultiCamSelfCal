%RQ       Pajdla: Returns a 3x3 upper triangular R and a unitary Q so that X = R*Q
%
%       function [R,Q] = rq(X)
%
%       X       = input matrix,
%       Q       = unitary matrix
%       R       = upper triangular matrix
%
%       See also QR.

%       Author:         Tomas Pajdla, Tomas.Pajdla@esat.kuleuven.ac.be 
%                                           pajdla@vision.felk.cvut.cz
%                       05/28/94 ESAT-MI2, KU Leuven
%       Documentation:                            
%       Language:       Matlab 4.1, (c) MathWorks                        
%
function [R,Q] = rq(X)
 
 [Qt,Rt] = qr(X');
 Rt = Rt';
 Qt = Qt';
 
 Qu(1,:) = cross(Rt(2,:),Rt(3,:));
 Qu(1,:) = Qu(1,:)/norm(Qu(1,:));
 
 Qu(2,:) = cross(Qu(1,:),Rt(3,:));
 Qu(2,:) = Qu(2,:)/norm(Qu(2,:));
 
 Qu(3,:) = cross(Qu(1,:),Qu(2,:));

 R  = Rt  * Qu';
 Q  = Qu * Qt;
 
