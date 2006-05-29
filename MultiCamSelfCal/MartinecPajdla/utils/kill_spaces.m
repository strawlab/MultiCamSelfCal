%kill_spaces Remove all spaces from given string.

function r = kill_spaces(s)

r = s(setdiff(1:length(s),findstr(s,' ')));
