% estimateX ... estimate 3D points robustly
% 
% reconstructed = estimateX(loaded,IdMat,cam)
%
% data   ... data structure, see LOADDATA
% IdMat  ... current point identification matrix
% cam    ... array of camera structures, see the main script GO
%
% reconstructed.ptdIdx ... indexes->data of points used for the reconstruction 
%              .X      ... reconstructed points, see u2PX
%              .CamIdx ... indexes->data of cameras used for the reconstruction
%
% $Id: estimateX.m,v 2.0 2003/06/19 12:07:09 svoboda Exp $

function reconstructed = estimateX(data,IdMat,cam,config)

SS = config.cal.NTUPLES; % sample size
MIN_POINTS = config.cal.MIN_PTS_VAL; % minimal number of correnspondences in the sample

Ws   = data.Ws;
Pmat = data.Pmat;

CAMS   = size(IdMat,1);
FRAMES = size(IdMat,2);

% create indexes for all possible SS-tuples
if 1
  count = 1;
  if SS == 2;
	for i=1:CAMS,
	  for j=(i+1):CAMS,
		sample(count).CamIds = [i,j];
		count = count+1;
	  end
	end
  end
  if SS == 3;
	for i=1:CAMS,
	  for j=(i+1):CAMS,
		for k=(j+1):CAMS,
		  sample(count).CamIds = [i,j,k];
		  count = count+1;
		end
	  end
	end
  end
  if SS == 4;
	for i=1:CAMS,
	  for j=(i+1):CAMS,
		for k=(j+1):CAMS,
		  for l=(k+1):CAMS,
			sample(count).CamIds = [i,j,k,l];
			count = count+1;
		  end
		end
	  end
	end
  end
  if SS == 5;
	for i=1:CAMS,
	  for j=(i+1):CAMS,
		for k=(j+1):CAMS,
		  for l=(k+1):CAMS,
			for m=(l+1):CAMS,
			  sample(count).CamIds = [i,j,k,l,m];
			  count = count+1;
			end
		  end
		end
	  end
	end
  end
else
  sample(1).CamIds = [1:15];
  SS = size(sample(1).CamIds,2);
end

disp(sprintf('Computing recontruction from all %d camera %d-tuples',size(sample,2), SS));

% create triple indexes
for i=1:CAMS,
  tripleIdx{i} = [i*3-2:i*3];
end

%%%
% for all possible combination of SS-tuples of cameras
% do the linear 3D reconctruction if enough point avaialable
for i=1:size(sample,2),
  ptsIdx = find(sum(IdMat([sample(i).CamIds],:))==SS);
  if size(ptsIdx,2) > MIN_POINTS
	X = uP2X(Ws([tripleIdx{[sample(i).CamIds]}],ptsIdx), [Pmat{[sample(i).CamIds]}]);
	% compute the reprojections
	for j=1:CAMS,
	  xe = Pmat{j}*X;
	  cam(j).xe = xe./repmat(xe(3,:),3,1);
	  % these points were the input into Martinec and Pajdla filling
	  mask.rec = zeros(1,FRAMES);	% mask of points that survived validation so far
	  mask.vis = zeros(1,FRAMES); % maks of visible points
	  mask.rec(ptsIdx)  = 1;
	  mask.vis(cam(j).ptsLoaded) = 1;
	  mask.both		= mask.vis & mask.rec; % which points are visible and reconstructed for a particular camera
	  unmask.rec	= cumsum(mask.rec);
	  unmask.vis	= cumsum(mask.vis);
	  cam(j).recandvis = unmask.rec(~xor(mask.rec,mask.both) & mask.rec);
	  cam(j).visandrec = unmask.vis(~xor(mask.rec,mask.both) & mask.rec);
	  cam(j).err2d	   = sum([cam(j).xe(1:2,cam(j).recandvis) - cam(j).xgt(1:2,cam(j).visandrec)].^2);
	  cam(j).mean2Derr = mean(cam(j).err2d);
	  cam(j).std2Derr  = std(cam(j).err2d);
	end
	sample(i).mean2Derrs = [cam(:).mean2Derr];
	sample(i).std2Derrs  = sum([cam(:).std2Derr]);
	sample(i).mean2Derr = sum(sample(i).mean2Derrs);
  else
	sample(i).mean2Derr = 9e99;
	sample(i).std2Derrs	= 9e99;
  end
end

% find the best sample
[buff,idxBest] = min([sample(:).mean2Derr]+[sample(:).std2Derrs]);

% and recompute it the best values
reconstructed.ptsIdx = find(sum(IdMat(sample(idxBest).CamIds,:))==SS);
reconstructed.X		 = uP2X(Ws([tripleIdx{[sample(idxBest).CamIds]}],reconstructed.ptsIdx), [Pmat{[sample(idxBest).CamIds]}]);
reconstructed.CamIdx = sample(idxBest).CamIds;

return;

