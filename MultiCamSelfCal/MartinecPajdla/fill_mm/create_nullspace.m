%create_nullspace Create null-space for scene with perspective camera.
%
%  Parameters:
%    depths .. matrix of zeros and ones meaning whether corresponding element
%              in M is scaled (i.e. multiplied by known perspective depth)

function [nullspace, result] = create_nullspace(M, depths, central, opt)

if nargin < 4, opt.trial_coef = 1;
               opt.threshold  = .01; end

I = ~isnan(M(1:3:end,:)); [m n] = size(I); show_mod = 10; use_maxtuples = 0;
if opt.verbose, fprintf(1, 'Used 4-tuples (.=%d): ', show_mod); tic; end

if central,  cols_scaled(1:n) = 0; cols_scaled(find(I(central,:) > 0)) = 1;
else, cols_scaled = []; end

num_trials = round(opt.trial_coef * n);

if opt.verbose, fprintf(1,'(Allocating memory...'); end
nullspace(size(M,1),num_trials) = 0; % Memory allocation: at least this
                                     % because at least one column is
                                     % added per one 4-tuple.
width                           = 0;
if opt.verbose, fprintf(1, ')'); end

tenth = .1;  % because of the first %
result.used = 0; result.failed = 0;
for i = 1:num_trials
  % choose a 4/max-tuple
  cols = 1:n;
  rows = 1:m;
  
  cols_chosen = []; t=1; failed = 0; 
  if central, 
    scaled_ensured = 0; 
  else 
    scaled_ensured = 1;   % trial version: no scale controling when cutting
  end
  for t = 1:4
    % choose one column, cut useless parts etc.
    [c, cols] = random_element(cols);
    cols_chosen = [cols_chosen c];

    % check just added column
    rows = intersect(rows, find(I(:,c) > 0));

    if t < 4,
      [rows, cols, scaled_ensured] = cut_useless(I, cols_scaled, ...
                                cols_chosen, rows, cols, 4-t, scaled_ensured);
    end
    
    if isempty(rows), failed = 1; break; end
  end

  if ~failed    
    % use the 4/max-tuple
    d = depths(rows,cols_chosen);
    % see ``debug code'' in the comment lower
    
    rowsbig   = k2i(rows);
    submatrix=[]; for j=1:length(cols_chosen) % 4, 
      submatrix=[ submatrix ...
                  spread_depths_col(M(rowsbig,cols_chosen(j)), d(:,j)) ]; end
    debug=1; if debug, if size(submatrix, 1)<=size(submatrix,2) & opt.verbose
        fprintf(1,'-'); end;end
    subnull = nulleps(submatrix,opt.threshold); %svd(submatrix)
    if size(subnull,2)>0  &  ( use_maxtuples | ...
       size(submatrix,1) == size(submatrix,2) + size(subnull,2))
      nulltemp            = zeros(size(M,1),size(subnull,2));
      nulltemp(rowsbig,:) = subnull; % * (length(rows)/m); % weighting
      if width+size(nulltemp,2) > size(nullspace,2) % Memory allocation:
        if opt.verbose, fprintf(1,'(Allocating memory...)'); end
        mean_added = width/i;
        nullspace(size(M,1), size(nullspace,2) ...
                  + round(mean_added * (num_trials-i))) = 0;
      end
      nullspace(:, width+1 : width+size(nulltemp,2)) = nulltemp;
      width                                          = width +size(nulltemp,2);
      result.used         = result.used +1;
      if mod(result.used, show_mod)==0 & opt.verbose, fprintf(1,'.'); end
    end
  else
    result.failed = result.failed +1;
  end
  
  if i/num_trials > .1*tenth
    if opt.verbose, fprintf(1,'%d%%', tenth*10); end
    if tenth < 1, tenth=0; end
    tenth = tenth + 1;
  end
end

if size(nullspace,2) > width,   % cut off unused allocated memory
  if opt.verbose, fprintf(1,'(Cutting unused memory...'); end
  nullspace = nullspace(:,1:width);
  if opt.verbose, fprintf(1, ')'); end
end
if opt.verbose, fprintf(1, ['(' num2str(toc) ' sec)\n']); end
result.tried = i;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% debug code
%    if size(d, 1) == 1, bla; end
%    if sum(d(1,:)==0) > 2, blabla; end
%    if use_maxtuples | ...
%          size(d,1)*3 > size(d,2) + sum(d(:)==0)... % i.e. size(submatrix,1)>
%          ...                                       % size(submatrix,2)
%          - sum(cols_scaled(cols_chosen)==0) % i.e. subtract 1 per each
%                                             % column full of zeros
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [rows, cols, scaled_ensured] = cut_useless( ... %)
    I, cols_scaled, ... % this is always same
    cols_chosen, rows, cols, demanded, scaled_ensured)

if ~scaled_ensured  
  % check scaled columns
  if length(rows) == 2, demanded_scaled = 3; demanded_rows = 2; 
  else                  demanded_scaled = 2; demanded_rows = 3; end
    cols_scaled_chosen = sum(cols_scaled(cols_chosen) > 0);
    
  % if no unscaled are allowed, they must be all cut
  if demanded == demanded_scaled - cols_scaled_chosen,
    cols           = intersect(cols, find(cols_scaled > 0));
    scaled_ensured = 1;
  end
else demanded_rows = 2; end
  
% check columns
cols = cols(find(sum(I(rows,cols)) >= demanded_rows));

% check rows
rows = rows(find(sum(I(rows,cols)') >= demanded));

function [element, rest] = random_element(set)
% Take a random element out of a set.
element = set(random_int(1, length(set)));
rest    = setdiff(set, element);

function y = random_int(from,to)
y = floor(from + (1 + to - from)*rand);

function [N,s] = nulleps(M,tol)
% Find the nullspace of M.  This is the regular nullspace, augmented by 
% vectors that aren't really in the nullspace, but have low singular
% values associated with them.  tol is the threshold on these singular values.
[u,s,v] = svd(M);
sigsvs = sum(diag(s)>tol);
N = u(:,sigsvs+1:size(u,2));
