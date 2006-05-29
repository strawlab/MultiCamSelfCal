% euclidize ... perform euclidian reconstruction
%               under assumption of unknown focal lengths, const. principal points = 0,
%               and aspect ratio = 1
%
% [Pe,Xe,C,Rot] = euclidize(Ws,Lambda,P,X,config)
%
% n is the number of cameras and m is the number of points
%
% Ws ....... 3*nxm measurement matrix
% Lambda ... nxm matrix containing the projective depths
% P ........ 3*nx4 projective motion matrix
% X ........ 4xm projective shape matrix
% config ... see the CONFIGDATA
%            .cal.pp and .cal.SQUARE_PIX are expected
%
% Pe ....... 3*nx4 euclidian motion matrix
% Xe ....... 4xm euclidian shape matrix
% C ........ 4xn matrix containg the camera centers
% Rot ...... 3*nx3 matrix containing the camera rotation matrices

% $Author: svoboda $
% $Revision: 2.1 $
% $Id: euclidize.m,v 2.1 2003/07/09 14:40:48 svoboda Exp $
% $State: Exp $

function [Pe,Xe,C,Rot] = euclidize(Ws,Lambda,P,X,config)
n = size(Ws,1)/3; % number of cameras
m = size(Ws,2);	  % number of points

% compute B
a = []; b = []; c = [];
for i = 1:n
  a = [a; sum(Ws(3*i-2,:).*Lambda(i,:))];
  b = [b; sum(Ws(3*i-1,:).*Lambda(i,:))];
  c = [c; sum(Lambda(i,:))];
end
TempA = -P(3:3:3*n, :);
TempB = -P(3:3:3*n, :);
for i = 1:n
  TempA(i, :) = TempA(i, :)*a(i)/c(i);
  TempB(i, :) = TempB(i, :)*b(i)/c(i);
end
TempA = TempA + P(1:3:3*n, :);
TempB = TempB + P(2:3:3*n, :);
Temp = [TempA; TempB];
[U,S,V] = svd(Temp,0);
B = V(:,4); % least square solution (of Temp*B == 0)

% compute A
%
% M * M^T == P * Q *P^T, thus
%
% ( m_x )                  ( P1 )
% ( m_y )*(m_x m_y m_z) == ( P2 ) * Q * (P1 P2 P3)   (let Pi denote the i-th row of P), thus
% ( m_z )                  ( P3 )
%
% ( |m_x|^2  m_x*m_y  m_x*m_z )    ( P1*Q*P1^T P1*Q*P2^T P1*Q*P3^T )
% (  .       |m_y|^2  m_y*m_z ) == ( .         P2*Q*P2^T P2*Q*P3^T )
% (  .       .......  |m_z|^2 )    ( .         ......... P3*Q*P3^T )
%
Temp = []; b = [];
for i = 1:n
  P1 = P(3*i-2,:); % 1st row of i-th camera
  P2 = P(3*i-1,:); % 2nd row of i-th camera
  P3 = P(3*i,  :); % 3rd row of i-th camera
  u = P1; v = P2;
  Temp = [Temp; u(1)*v(1) u(1)*v(2)+u(2)*v(1) u(3)*v(1)+u(1)*v(3) u(1)*v(4)+u(4)*v(1) u(2)*v(2) u(2)*v(3)+u(3)*v(2) u(2)*v(4)+u(4)*v(2) u(3)*v(3) u(4)*v(3)+u(3)*v(4) u(4)*v(4)];
  if config.cal.SQUARE_PIX
	  Temp = [Temp; u(1)^2-v(1)^2 2*u(1)*u(2)-2*v(1)*v(2) 2*u(1)*u(3)-2*v(1)*v(3) 2*u(1)*u(4)-2*v(1)*v(4) u(2)^2-v(2)^2 2*u(2)*u(3)-2*v(2)*v(3) 2*u(2)*u(4)-2*v(2)*v(4) u(3)^2-v(3)^2 2*u(3)*u(4)-2*v(3)*v(4) u(4)^2-v(4)^2];
  end
  u = P1; v = P3;
  Temp = [Temp; u(1)*v(1) u(1)*v(2)+u(2)*v(1) u(3)*v(1)+u(1)*v(3) u(1)*v(4)+u(4)*v(1) u(2)*v(2) u(2)*v(3)+u(3)*v(2) u(2)*v(4)+u(4)*v(2) u(3)*v(3) u(4)*v(3)+u(3)*v(4) u(4)*v(4)];
  u = P2; v = P3;
  Temp = [Temp; u(1)*v(1) u(1)*v(2)+u(2)*v(1) u(3)*v(1)+u(1)*v(3) u(1)*v(4)+u(4)*v(1) u(2)*v(2) u(2)*v(3)+u(3)*v(2) u(2)*v(4)+u(4)*v(2) u(3)*v(3) u(4)*v(3)+u(3)*v(4) u(4)*v(4)];
end
% one additional equation only if needed
if n<4 & ~config.cal.SQUARE_PIX
	u = P(3,:);
	Temp = [Temp; u(1)^2 2*u(1)*u(2) 2*u(1)*u(3) 2*u(1)*u(4) u(2)^2 2*u(2)*u(3) 2*u(2)*u(4) u(3)^2 2*u(3)*u(4) u(4)^2];
	b = [zeros(size(Temp(1:end-1,1)));1];
	% TLS solution of Temp*q=b
	[U,S,V] = svd([Temp,b],0);
	q = -(1/V(11,end))*V(1:10,end);
else
	[U,S,V] = svd(Temp,0);
	q = -V(:,size(V,2));
end

Q = [
    q(1) q(2) q(3) q(4)
    q(2) q(5) q(6) q(7)
    q(3) q(6) q(8) q(9)
    q(4) q(7) q(9) q(10)
];
% test which solution to take for q (-V or V)
% diagonal entries of M_M should be positive
M_M = P(1:3,:)*Q*P(1:3,:)';
if (M_M(1,1)<=0)
    q = -q; % V(:,size(V,2));
    Q = [
    q(1) q(2) q(3) q(4)
    q(2) q(5) q(6) q(7)
    q(3) q(6) q(8) q(9)
    q(4) q(7) q(9) q(10)
    ];
end

[U,S,V] = svd(Q,0);
A = U(:,1:3)*sqrt(S(1:3,1:3));

H = [A, B];

% euclidian motion and shape
Pe = P*H;
Xe = inv(H)*X;

% normalize coordiates
Xe = Xe./repmat(Xe(4,:),4,1);

PeRT = [];
Rot	 = [];
if 1
  Rot = [];
  for i=1:n,
	sc = norm(Pe(i*3,1:3),'fro');
	% first normalize the Projection matrices to get normalized pixel points
	Pe(i*3-2:i*3,:) = Pe(i*3-2:i*3,:)./sc;
	% correct it of points behind the camera
	xe = Pe(i*3-2:i*3,:)*Xe;
	if sum(xe(3,:)<0),
	  Pe(i*3-2:i*3,:) = -Pe(i*3-2:i*3,:);
	end

	% decompose the matrix by using rq decomposition  
	[K,R] = rq(Pe(i*3-2:i*3,1:3));
	Cc	= -R'*inv(K)*Pe(i*3-2:i*3,4);% camera center
	% Stephi calib params
	Pst(i*3-2:i*3,:) = R'*inv(K);
	Cst(i,:)		   = Cc';
	% modify the Kalibaration matrix to get consistent 
	% euclidean motion Pe
	K(1,3) = K(1,3)-config.cal.pp(i,1);
	K(2,3) = K(2,3)-config.cal.pp(i,2);
	PeRT = [PeRT; K*[R,-R*Cc]];
	Rot	 = [Rot;R];
  end
  Pe = PeRT;
  C = Cst';
end





















