% Mdepthcol is column of JIM with depths which is spread by this
% function to a submatrix with some zeros
function submatrix = spread_depths_col(Mdepthcol,depthsIcol)

m = size(depthsIcol,1);
n = 1;

known_depths      = find(depthsIcol ~= 0);

if ~isempty(known_depths)
  rows              = k2i(known_depths);
  submatrix(rows,n) = Mdepthcol(rows); n=n+1;
end

for i=setdiff(1:m, known_depths)
  rows              = k2i(i);
  submatrix(rows,n) = Mdepthcol(rows); n=n+1;
end

