function [F, inls] = rEG(u, th, th7, conf)

%rEG     Robust computation of epipolar geometry based on RANSAC
%
% [F, inls] = rEG(u, th, th7, conf)
% u    point correspondences (6xn), where n is the number of corrs.
% th   threshold value for the Sampson's distance (see FDs)
% th7  threshold for inliers to iterate on F (default = th)
% conf confidence level of self-termination  (default = .95)

MAX_SAM = 100000;
iter_amount = .5;

if nargin < 3
  th7 = th;
end;

if nargin < 4
  conf = .95;
end;

len = size(u,2);
ptr = 1:len;
max_i = 8;
max_sam = MAX_SAM;
 
no_sam = 0;
no_mod = 0;
 
while no_sam < max_sam 
  for pos = 1:7
      idx = pos + ceil(rand * (len-pos));
      ptr([pos, idx]) = ptr([idx, pos]);
  end;
  
  no_sam = no_sam +1;
 
  aFs = fu2F7(u(:,ptr(1:7))); 
  
  for i = 1:size(aFs,3)
      no_mod = no_mod +1;
      aF = aFs(:,:,i);
	  Ds = mfFDs(aF,u);
	  % Ds = fFDs(aF,u);
      v  = Ds < th;
      v7 = Ds < th7;
      no_i  = sum(v);
      
      if max_i < no_i
        inls = v;
        F = aF;
        max_i = no_i;
        max_sam = min([max_sam,nsamples(max_i, len, 7, conf)]);
      end  

      if sum(v7) >= 8 + iter_amount*(max_i - 8)
	aF = u2F(u(:,v7));
        Ds = mfFDs(aF,u);
		% Ds = fFDs(aF,u);
        v  = Ds < th;
	no_i = sum(v);
        if max_i < no_i
          inls = v;
          F = aF;
          max_i = no_i;
	  exp_sam = nsamples(max_i, len, 7, .95); 
          max_sam = min([max_sam,exp_sam]);
        end  
      end
  end
end

if no_sam == MAX_SAM
  warning(sprintf('RANSAC - termination forced after %d samples expected number of samples is %d',  no_sam, exp_sam));
end;


      
      
      





