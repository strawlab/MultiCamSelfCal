function [P,X] = align3d(inP,inX,simT);

T = [simT.s*simT.R;0 0 0];
T = [T, [simT.t(:);1]];

X = T*inX;

P = inP*inv(T);

return;
