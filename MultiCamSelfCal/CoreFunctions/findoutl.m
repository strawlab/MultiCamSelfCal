% find outliers in cameras
%
% [outliers, inliers] = findoutl(cam,inliers,INL_TOL,NUM_CAMS_FILL);
%
% $Id: findoutl.m,v 2.1 2005/05/20 11:58:23 svoboda Exp $

function [outliers, inliers] = findoutl(cam,inliers,INL_TOL,NUM_CAMS_FILL);

CAMS = size(cam,2);

idxoutMat = zeros(size(inliers.IdMat));
for i=1:CAMS,
	if (cam(i).std2Derr > cam(i).mean2Derr) | (cam(i).mean2Derr > INL_TOL)
		reprerrs = cam(i).err2d - cam(i).mean2Derr;
		idxout   = find((reprerrs > 3*cam(i).std2Derr) & reprerrs > INL_TOL);
	else
		idxout = [];
	end
	idxoutMat(i,cam(i).idlin(cam(i).visandrec(idxout))) = 1;
end
inliers.IdMat(:,sum(idxoutMat)>0) = 0;	% zero all columns with at least one outlier
inliers.idx = find(sum(inliers.IdMat)>=size(inliers.IdMat,1)-NUM_CAMS_FILL);
outliers	= sum(sum(idxoutMat)>0);

return;

