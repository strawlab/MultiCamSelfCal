%balance_triplets Balance PRMM by column-wise and "triplet-of-rows"-wise 
%  scalar multiplications.
%
%  After balancing, overall weight of M will be m*n where 3m*n is size of M
%  (i.e. 3 coordinates of each image point will give together 1 in average).
%
%  Parameters:
%    opt.info_separately .. 1(default) .. display info on separate row
%                               0          .. display info in brackets
%           .verbose(1) .. whether display info

function B = balance_triplets(M, opt);

if nargin < 2, opt = []; end
if ~isfield(opt,'info_separately')
  opt.info_separately = 1; end
if ~isfield(opt,'verbose')
  opt.verbose = 1; end

if opt.verbose
  if opt.info_separately, fprintf(1,'Balancing PRMM...'); tic
  else,                       fprintf(1,'(balancing PRMM...'); tic; end; end

m=size(M,1)/3;  	%number of cameras
n=size(M,2);  		%number of points

B=M;  change=inf; diff_rows = inf; iteration = 0;
while (change > 0.01  |  diff_rows > 1  |  diff_cols > 1)  &  iteration <= 20
  Bold=B;
   
 % 1. rescale each column l so that sum w_r_l^2=1 i.e. column of unit
 % length. However, due to the missing data, the length must be smaller
 % in (linear) dependance on amount of missing data.
  diff_cols = -inf;
  for l=1:n
    rows = find(~isnan(M(1:3:end,l)));
    if length(rows) > 0
      rowsb           = k2i(rows);
      s               = sum(B(rowsb,l) .^ 2); 
      supposed_weight = length(rows);   % the less data, the slighter impact
      diff_cols       = max(abs(s-supposed_weight), diff_cols);
      B(rowsb,l)      = B(rowsb,l) ./ sqrt(s/supposed_weight);
    end
  end
  
 % 2. rescale each triplet of rows so that it's sum w_i_l^2=1 i.e. unit
 % area. However, due to the missing data, the area must be smaller in
 % (linear) dependance on amount of missing data.
  diff_rows = -inf;
  for k=1:m
    cols = find(~isnan(M(3*k,:)));
    if length(cols) > 0
      s                 = sum(sum( B(3*k-2:3*k,cols) .^ 2 ));
      supposed_weight   = length(cols);  % the less data, the slighter impact
      diff_rows         = max(abs(s-supposed_weight), diff_rows);
      B(3*k-2:3*k,cols) = B(3*k-2:3*k,cols) ./ sqrt(s/supposed_weight);
    end
  end
  
 % repeat steps 1 and 2 if W changed significantly
 % Note: It is not ensured that sums (s) would not change significantly
 %       in the (hypothetical) next step. The reason is that rescaling
 %       No. 1 rescales n columns to overall weight n whereas rescaling
 %       No. 2 rescales m triplets of rows to overall weight m.
  change = 0;
  for k=1:m
    cols = find(~isnan(M(3*k,:)));
    change   = change + sum(sum( (B   (3*k-2:3*k,cols)-...
                                  Bold(3*k-2:3*k,cols)) .^ 2 ));
  end
  %disp(sprintf('change=%f, diff_cols=%f, diff_rows=%f', ...
  %             change, diff_cols, diff_rows));
  iteration = iteration +1;
  if opt.verbose, fprintf(1,'.'); end
end


if opt.verbose
  if opt.info_separately, disp(['(' num2str(toc) ' sec)']);
  else,                       fprintf(1,[num2str(toc) ' sec)']); end; end

%disp(sprintf('change: %f, diff_rows: %f, diff_cols: %f, iterations: %d', ...
%             change, diff_rows, diff_cols, iteration));
