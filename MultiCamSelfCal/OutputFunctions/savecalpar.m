% SaveCalPar   save calibration parameters in different formats
% 
% [Cst,Rot] = savecalpar(P,config)
% P ... 3*CAM x 4 matrix containing result of selfcalibration, see EUCLIDIZE
% config ... configuration structure, see CONFIGDATA
%
%
% Cst ... CAMSx3   matrix containing the camera centers (in world coord.)
% Rot ... 3*CAMSx3 matrix containing camera rotation matrices

% $Author: svoboda $
% $Revision: 2.0 $
% $Id: savecalpar.m,v 2.0 2003/06/19 12:07:03 svoboda Exp $
% $State: Exp $


function [Cst,Rot] = savecalpar(P,config)

idxused = config.cal.cams2use;

CAMS = size(P,1)/3;

Cst = zeros(CAMS,3);
Pst = zeros(3*CAMS,3);
Rot = [];
for i=1:CAMS,
  % do not save P matrices in separate files
  if 1
	Pmat = P(i*3-2:i*3,:);
	save(sprintf(config.files.CalPmat,idxused(i)),'Pmat','-ASCII');
  end
  sc = norm(P(i*3,1:3));
  % first normalize the Projection matrices to get normalized pixel points
  P(i*3-2:i*3,:) = P(i*3-2:i*3,:)./sc;
  % decompose the matrix by using rq decomposition  
  [K,R] = rq(P(i*3-2:i*3,1:3));
  tvec= inv(K)*P(i*3-2:i*3,4);			% translation vector
  C	  = -R'*tvec;						% camera center
  % Stephi calib params
  Pstephi		   = R'*inv(K);		
  Pst(i*3-2:i*3,:) = Pstephi;
  Cst(i,:)		   = C';		
  % Stephi requires to save the pars in more "wordy" form
  fid = fopen(sprintf(config.files.StCalPar,idxused(i)),'wt');
  if ~fid
	error('SaveCalPar: The camera cal file cannot be opened');
  else
	fprintf(fid,'C1 = %f \n', C(1));
	fprintf(fid,'C2 = %f \n', C(2));
	fprintf(fid,'C3 = %f \n', C(3));
	fprintf(fid,'\n');
	fprintf(fid,'P11 = %f \n', Pstephi(1,1));
	fprintf(fid,'P12 = %f \n', Pstephi(1,2));
	fprintf(fid,'P13 = %f \n', Pstephi(1,3));
	fprintf(fid,'P21 = %f \n', Pstephi(2,1));
	fprintf(fid,'P22 = %f \n', Pstephi(2,2));
	fprintf(fid,'P23 = %f \n', Pstephi(2,3));
	fprintf(fid,'P31 = %f \n', Pstephi(3,1));
	fprintf(fid,'P32 = %f \n', Pstephi(3,2));
	fprintf(fid,'P33 = %f \n', Pstephi(3,3));
	fclose(fid);
  end
  Rot	 = [Rot;R];
  % Prithwijit requires to save the pars in more "wordy" form
  if 0 % do not save in the Prithwijit format
	fid = fopen(sprintf(config.files.CalPar,idxused(i)),'wt');
	if ~fid
	  error('SaveCalPar: The camera cal file cannot be opened');
	else
	  fprintf(fid,'R11 = %f \n',R(1,1));
	  fprintf(fid,'R12 = %f \n',R(1,2));
	  fprintf(fid,'R13 = %f \n',R(1,3));
	  fprintf(fid,'R21 = %f \n',R(2,1));
	  fprintf(fid,'R22 = %f \n',R(2,2));
	  fprintf(fid,'R23 = %f \n',R(2,3));
	  fprintf(fid,'R31 = %f \n',R(3,1));
	  fprintf(fid,'R32 = %f \n',R(3,2));
	  fprintf(fid,'R33 = %f \n',R(3,3));
	  fprintf(fid,'\n');
	  fprintf(fid,'t11 = %f \n',tvec(1));
	  fprintf(fid,'t21 = %f \n',tvec(2));
	  fprintf(fid,'t31 = %f \n',tvec(3));
	  fprintf(fid,'\n');
	  fprintf(fid,'K11 = %f \n',K(1,1));
	  fprintf(fid,'K12 = %f \n',K(1,2));
	  fprintf(fid,'K13 = %f \n',K(1,3));
	  fprintf(fid,'K21 = %f \n',K(2,1));
	  fprintf(fid,'K22 = %f \n',K(2,2));
	  fprintf(fid,'K23 = %f \n',K(2,3));
	  fprintf(fid,'K31 = %f \n',K(3,1));
	  fprintf(fid,'K32 = %f \n',K(3,2));
	  fprintf(fid,'K33 = %f \n',K(3,3));
	  fprintf(fid,'\n');
	  fclose(fid);
	end
  end
end

% save Stehpi params
save(config.files.Pst,'Pst','-ASCII');
save(config.files.Cst,'Cst','-ASCII');
