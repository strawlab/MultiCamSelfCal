function ret = dispcamstats(cam,inliers);
% DISPCAMSTATS display statistics about cameras to the command window
%
% auxiliary function for the main gocal script
% with a minor modification is may also write the statistics to a file
% I never needed it.
%
% $Id: dispcamstats.m,v 2.1 2005/05/23 16:21:50 svoboda Exp $

fprintf(1,'CamId    std       mean  #inliers \n');
for i=1:size(cam,2),
  fprintf(1,'%3d  %8.2f  %8.2f %6d \n',cam(i).camId, cam(i).std2Derr, cam(i).mean2Derr, sum(inliers.IdMat(i,:)));
end
