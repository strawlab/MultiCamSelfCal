% FindInl    find inliers in joint image matrix
%			 by pairwise epipolar geometry
% 
% function IdMatIn = findinl(Ws,IdMat,tol)
% Ws ... 3MxN joint image matrix
% IdMat ... MxN ... 0 -> no point detected
%                   1 -> point detected
% tol ... [pixels] tolerance for the epipolar geometry
%         the point are accpted as outliers only if they 
%         are closer to the epipolar line than tol

% $Author: svoboda $
% $Revision: 2.1 $
% $Id: findinl.m,v 2.1 2003/07/30 10:28:29 svoboda Exp $
% $State: Exp $

function IdMatIn = findinl(Ws,IdMat,tol)

NoCams = size(IdMat,1); 

% fill the array of structures not_used denoted as 0
% allocate the array of structures for used
for i=1:NoCams,
  not_used(i).pts = sum(IdMat(i,:));
  used(i).pts	  = -1;
end

% allocate IdMat for outliers
IdMatIn = zeros(size(IdMat));

while (sum([not_used.pts])>1-NoCams),
  [buff, id.cam_max]  = max([not_used.pts]);
  used	   = add(used, id.cam_max, not_used(id.cam_max).pts);
  not_used = remove(not_used, id.cam_max);
  Mask	   = repmat(IdMat(id.cam_max,:),NoCams,1);
  Corresp  = Mask & IdMat;
  Corresp(id.cam_max,:) = 0;
  [buff, id.cam_to_pair] = max(sum(Corresp')); % find the camera with most correspondences
  idx.corr_to_pair = find(sum(IdMat([id.cam_max,id.cam_to_pair],:))==2);
  % used	   = add(used, id.cam_to_pair, not_used(id.cam_to_pair).pts);
  % not_used = remove(not_used, id.cam_to_pair);
  if size(idx.corr_to_pair,2)<8,
	error('Not enough points to compute epipolar geometry in RANSAC validation')
  end
  Wspair   = [];
  Wspair   = Ws(id.cam_max*3-2:id.cam_max*3, idx.corr_to_pair);
  Wspair   = [Wspair; Ws(id.cam_to_pair*3-2:id.cam_to_pair*3, idx.corr_to_pair)];
  % id
  [F, inls] = rEG(Wspair,tol,tol,0.99);
  IdMatIn(id.cam_max, idx.corr_to_pair(inls)) = 1;
  IdMat(id.cam_max, :)						  = 0;
  IdMat(id.cam_max, idx.corr_to_pair(inls))	  = 1;
end

function list = add(list, id, value)
list(id).pts = value;
return

function list = remove(list, id)
list(id).pts = -1;
return
