%fill_mm_sub Proj. reconstruction of a normed sub-scene.
%
%   When the central image concept is used, the information which image is
%   the central image is passed to this function as input.
%
%   Parameters:
%
%      Mfull .. complete known parts of the problem, used here for the best
%               estimate of the fundamental matrices

function [P,X, lambda, u1,u2, info] = fill_mm_sub(Mfull, M, central,opt,info)

I = ~isnan(M(1:3:end,:));
[m n] = size(I);
if isempty(central), central = 0; end

P=[]; X=[]; lambda=[]; u1=1:m; u2=1:n;

%estimate the fundamental matrices and epipoles with the method of [Har95]
 [F,ep,rows,nonrows] = M2Fe(Mfull, central);

 if ~isempty(nonrows), 
   disp(sprintf('Used local images:%s.', sprintf(' %d', rows))); end
 if length(rows) < 2, return; end
 
%determine scale faktors lambda_i_p
 if ~central, rows_central = 0; else rows_central = find(rows == central); end
 [lambda, Ilamb] = depth_estimation(M(k2i(rows),:),F,ep,rows, ...
                                    rows_central);
 
     % prepare info.show_prmm - for show_prmm function
     info.show_prmm.I = I;
     info.show_prmm.Idepths = zeros(m,n); info.show_prmm.Idepths(rows,:)=Ilamb;

%build the rescaled measurement matrix B
 for i = 1:length(rows), B(k2i(i),:) = M(k2i(i),:).*([1;1;1]*lambda(i,:)); end

%balance W by column-wise and "triplet-of-rows"-wise scalar multiplications
 B = balance_triplets(B, opt);
 
%fit holes in JIM by Jacobs' algorithm
 [P,X, u1,u2, lambda1, info] = fill_prmm(B, Ilamb, central,opt,info);
  
r1 = setdiff(1:length(rows),u1); r2 = setdiff(1:n,u2);
 
lambda = lambda(r1,r2);  % to fit P*X
if ~isempty(lambda1), 
  new = find(~Ilamb(r1,r2) & I(r1,r2)); lambda(new) = lambda1(new); end

error = eucl_dist_only(B(k2i(r1), r2), P*X, ~isnan(B(3*r1,r2)), 3);
if opt.verbose, disp(sprintf('Error balanced: %f', error)); end

u1 = union(nonrows, rows(u1));