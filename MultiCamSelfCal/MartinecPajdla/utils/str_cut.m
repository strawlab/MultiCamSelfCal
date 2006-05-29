%str_cut Cut off last piece according to a delimeter from a string.
%
%   [ head, tail ] = str_cut(s, delim)

function [ head, tail ] = str_cut(s, delim)

if nargin < 2, delim = '/'; end

idcs = findstr(s,delim);
if isempty(idcs),
  head = s; 
  tail = [];
else
  head = s(1:idcs(end));
  tail = s(length(head)+1:end);
end