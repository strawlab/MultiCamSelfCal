%% Export calibration data (corners + 3D coordinates) to
%% text files (in Willson-Heikkila's format or Zhang's format)

%% Thanks to Michael Goesele (from the Max-Planck-Institut) for the original suggestion
%% of adding this export function to the toolbox.


if ~exist('n_ima'),
   fprintf(1,'ERROR: No calibration data to export\n');
   
else

	check_active_images;

% 	check_extracted_images;

	check_active_images;
   
   % fprintf(1,'Tool that exports calibration data to Willson-Heikkila, Zhang formats or blue-c formats\n');
   
   qformat = 3;
   
   if 0
	 while (qformat ~=0)&(qformat ~=1)&(qformat ~=2)&(qformat ~=3),
	   
	   fprintf(1,'Three possible formats of export: 0=Willson and Heikkila, 1=Zhang, 2=blue-c, complete, 3=blue-c, intrinsic\n')
	   qformat = input('Format of export (enter 0, 1, 2, or 3): ');
	   
	   if isempty(qformat)
		 qformat = -1;
	   end;
	   
	   if (qformat ~=0)&(qformat ~=1)&(qformat ~=2)&(qformat ~=3),
		 
		 fprintf(1,'Invalid entry. Try again.\n')
		 
	   end;
	   
	 end;
   end
   
   if qformat == 0
      
		fprintf(1,'\nExport of calibration data to text files (Willson and Heikkila''s format)\n');
		outputfile = input('File basename: ','s');
	
		for kk = ind_active,
   	
   		eval(['X_kk = X_' num2str(kk) ';']);
      	eval(['x_kk = x_' num2str(kk) ';']);
         
         Xx = [X_kk ; x_kk]';
         
			file_name = [outputfile num2str(kk)];
	
			disp(['Exporting calibration data (3D world + 2D image coordinates) of image ' num2str(kk) ' to file ' file_name '...']);
         
         eval(['save ' file_name ' Xx -ASCII']);
      
     	end;
        
    elseif qformat == 1
      
      fprintf(1,'\nExport of calibration data to text files (Zhang''s format)\n');
      modelfile = input('File basename for the 3D world coordinates: ','s');
      datafile = input('File basename for the 2D image coordinates: ','s');
      
      for kk = ind_active,
         
   		eval(['X_kk = X_' num2str(kk) ';']);
         eval(['x_kk = x_' num2str(kk) ';']);
         
         if ~exist(['n_sq_x_' num2str(kk)]),
            n_sq_x = 1;
            n_sq_y = size(X_kk,2);
         else
            eval(['n_sq_x = n_sq_x_' num2str(kk) ';']);
         	eval(['n_sq_y = n_sq_y_' num2str(kk) ';']);
         end;
         
 	      X = reshape(X_kk(1,:)',n_sq_x+1,n_sq_y+1)';
 	      Y = reshape(X_kk(2,:)',n_sq_x+1,n_sq_y+1)';
         XY = reshape([X;Y],n_sq_y+1,2*(n_sq_x+1));
          
         x = reshape(x_kk(1,:)',n_sq_x+1,n_sq_y+1)';
 	      y = reshape(x_kk(2,:)',n_sq_x+1,n_sq_y+1)';
         xy = reshape([x;y],n_sq_y+1,2*(n_sq_x+1));
         
         disp(['Exporting calibration data of image ' num2str(kk) ' to files ' modelfile num2str(kk) '.txt and ' datafile num2str(kk) '.txt...']);

         eval(['save ' modelfile num2str(kk) '.txt XY -ASCII']);
         eval(['save ' datafile num2str(kk) '.txt xy -ASCII']);
     end;
     
   elseif qformat == 2
     
     fprintf(1,'\nExport of complete calibration data to blue-c configuration file\n');
     % outputfile = input('File basename: ', 's');
     configfile = [outputfile '.cal'];
     disp(['Writing ' configfile]);
     
     fid = fopen(configfile, 'w');
     fprintf(fid, 'R11 = %.16f\n', Rc_ext(1,1));
     fprintf(fid, 'R12 = %.16f\n', Rc_ext(1,2));
     fprintf(fid, 'R13 = %.16f\n', Rc_ext(1,3));
     fprintf(fid, 'R21 = %.16f\n', Rc_ext(2,1));
     fprintf(fid, 'R22 = %.16f\n', Rc_ext(2,2));
     fprintf(fid, 'R23 = %.16f\n', Rc_ext(2,3));
     fprintf(fid, 'R31 = %.16f\n', Rc_ext(3,1));
     fprintf(fid, 'R32 = %.16f\n', Rc_ext(3,2));
     fprintf(fid, 'R33 = %.16f\n\n', Rc_ext(3,3));
     
     fprintf(fid, 't11 = %.16f\n', Tc_ext(1,1));
     fprintf(fid, 't21 = %.16f\n', Tc_ext(2,1));
     fprintf(fid, 't31 = %.16f\n\n', Tc_ext(3,1));
     
     fprintf(fid, 'K11 = %.16f\n', KK(1,1));
     fprintf(fid, 'K12 = %.16f\n', KK(1,2));
     fprintf(fid, 'K13 = %.16f\n', KK(1,3));
     fprintf(fid, 'K21 = %.16f\n', KK(2,1));
     fprintf(fid, 'K22 = %.16f\n', KK(2,2));
     fprintf(fid, 'K23 = %.16f\n', KK(2,3));
     fprintf(fid, 'K31 = %.16f\n', KK(3,1));
     fprintf(fid, 'K32 = %.16f\n', KK(3,2));
     fprintf(fid, 'K33 = %.16f\n\n', KK(3,3));
     
     fprintf(fid, 'kc1 = %.16f\n', kc(1));
     fprintf(fid, 'kc2 = %.16f\n', kc(2));
     fprintf(fid, 'kc3 = %.16f\n', kc(3));
     fprintf(fid, 'kc4 = %.16f\n', kc(4));

     status = fclose(fid);
     
   else
       
     fprintf(1,'\nExport of intrinsic calibration data to blue-c configuration file\n');
     % outputfile = input('File basename: ', 's');
     configfile = outputfile;
     disp(['Writing ' configfile]);
     
     fid = fopen(configfile, 'w');
     
     fprintf(fid, 'K11 = %.16f\n', KK(1,1));
     fprintf(fid, 'K12 = %.16f\n', KK(1,2));
     fprintf(fid, 'K13 = %.16f\n', KK(1,3));
     fprintf(fid, 'K21 = %.16f\n', KK(2,1));
     fprintf(fid, 'K22 = %.16f\n', KK(2,2));
     fprintf(fid, 'K23 = %.16f\n', KK(2,3));
     fprintf(fid, 'K31 = %.16f\n', KK(3,1));
     fprintf(fid, 'K32 = %.16f\n', KK(3,2));
     fprintf(fid, 'K33 = %.16f\n\n', KK(3,3));
     
     fprintf(fid, 'kc1 = %.16f\n', kc(1));
     fprintf(fid, 'kc2 = %.16f\n', kc(2));
     fprintf(fid, 'kc3 = %.16f\n', kc(3));
     fprintf(fid, 'kc4 = %.16f\n', kc(4));

     status = fclose(fid);
      
end;

fprintf(1,'done\n');
   
end;
