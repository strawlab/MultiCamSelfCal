function e = p2e (u)
e = u(1:2,:) ./ ([1;1] * u(3,:));
return