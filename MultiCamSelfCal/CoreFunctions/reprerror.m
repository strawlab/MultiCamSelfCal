% reprerror   Estimate reprojection error
%
% [cam] = reprerror(cam,Pe,Xe,FRAMES,inliers);
% 
% $Id: reprerror.m,v 2.0 2003/06/19 12:06:50 svoboda Exp $

function [cam] = reprerror(cam,Pe,Xe,FRAMES,inliers);

CAMS = size(Pe,1)/3;

for i=1:CAMS,
	xe		= Pe(((3*i)-2):(3*i),:)*Xe;
	cam(i).xe	= xe./repmat(xe(3,:),3,1);
	% these points were the input into Martinec and Pajdla filling
	mask.rec = zeros(1,FRAMES);	% mask of points that survived validation so far
	mask.vis = zeros(1,FRAMES); % maks of visible points
	mask.rec(inliers.idx)  = 1;
	mask.vis(cam(i).idlin) = 1;
	mask.both			   = mask.vis & mask.rec; % which points are visible and reconstructed for a particular camera
	unmask.rec			   = cumsum(mask.rec);
	unmask.vis			   = cumsum(mask.vis);
	cam(i).recandvis = unmask.rec(~xor(mask.rec,mask.both) & mask.rec);
	cam(i).visandrec = unmask.vis(~xor(mask.rec,mask.both) & mask.rec);
	cam(i).err2d	 = sqrt(sum([cam(i).xe(1:2,cam(i).recandvis) - cam(i).xgt(1:2,cam(i).visandrec)].^2));
	cam(i).mean2Derr = mean(cam(i).err2d);
	cam(i).std2Derr  = std(cam(i).err2d);
end

return;
