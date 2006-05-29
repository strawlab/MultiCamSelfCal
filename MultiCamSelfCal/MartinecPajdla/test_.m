global scene;
scene.ID = 2;
M = load_scene; if isempty(M), return; end;

options.no_factorization = 0;
options.create_nullspace.trial_coef = 10;
[ P,X, u1,u2, info ] = fill_mm(M, options);
