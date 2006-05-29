function [Xe,Pe,C,R,T,foc] = selfcalib(Ws,IdMat)

% selfcalib .... performs the self-calibration algorithm on
%                a measurement matrix
%
% [Xe,Pe,C,R,T,foc] = selfcalib(Ws)
%
% Ws ........ the 3*nxm measurement matrix
%
% Xe ........ 4xm matrix containg reconstructed calibration points
% Pe ........ 3*CAMSx4 matrix containing estimated camera matrices
% C ......... 4xn matrix containg the camera centers
% R ......... 3*CAMSx3 matrix containing estimated camera rotation matrices
% T ......... 3*n matrix containing the camera translation vectors
% foc ....... CAMSx1 vector containing the focal lengths of the cameras


POINTS = size(Ws,2);
CAMS   = size(Ws,1)/3;

if 1
  % normalize image data
  % (see Hartley, p.91)
  T = [];  % the CAMS*3x3 normalization transformations
  for i=1:CAMS
	[X_i, T_i] = isptnorm(Ws(i*3-2:i*3-1,IdMat(i,:)>0)');
	Ws(i*3-2:i*3-1,IdMat(i,:)>0) = [X_i'; ones(1,sum(IdMat(i,:)>0))];
	T = [T; T_i];
  end
else
  T = repmat(eye(3),CAMS,1);
end

% estimate projective depths
Lambda_est = estimateLambda(Ws,IdMat);
% Lambda_est = ones(CAMS,POINTS);

if 1
  % normalize estimated lambdas. 
  % it is more balancing than normalization
  % Check it again. Probably not correct?
  lambnfr = sum(Lambda_est.^2);
  Lambda_est = sqrt(CAMS)*Lambda_est./repmat(sqrt(lambnfr),CAMS,1);
  lambnfc = sum(Lambda_est'.^2);
  Lambda_est = sqrt(POINTS)*Lambda_est./repmat(sqrt(lambnfc'),1,POINTS);
end 

% no need for negative lambdas
Lambda_est = abs(Lambda_est);

% Lambda check
% employing lambdas, the Ws should have rank 4 !
if 0
  lambdaMat = [];
  for i=1:CAMS
	lambdaMat = [lambdaMat; repmat(Lambda_est(i,:),3,1)];
  end
  Ws_rankcheck = lambdaMat.*Ws;
  [svd(Ws_rankcheck),svd(Ws)]
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% compute projective shape and motion
[P,X,Lambda] = estimatePX(Ws,Lambda_est);

% undo normalization
for i=1:CAMS
    P(3*i-2:3*i,:) = inv(T(3*i-2:3*i,:))*P(3*i-2:3*i,:);
end

% Euclidian reconstruction
warn = 0;
[Pe,Xe,C,R,T,foc,warn] = euclidize(Ws,Lambda,P,X);    








