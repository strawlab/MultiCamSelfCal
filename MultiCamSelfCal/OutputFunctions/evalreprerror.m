% evalreprerror ... computes and plots the final error statistics
%
% cam = evalreprerror(cam,config)
% cam, config ... see the main GOCAL script
%
% $Id: evalreprerror.m,v 2.0 2003/06/19 12:07:03 svoboda Exp $

function cam = evalreprerror(cam,config)

disp('2D reprojection error')
disp(sprintf('All points: mean  %2.2f pixels, std is %2.2f',mean([cam.err2d]), std([cam.err2d])'));
% disp(sprintf('Inliers:    mean  %2.2f pixels, std is %2.2f',mean([cam.inerr2d]), std([cam.inerr2d])'));
if mean([cam.err2d])>1.5 | std([cam.err2d])>1.5
	disp('***************************************************')
	disp('W A R N I N G: the reprojection error is relatively high !')
end

%%%
% evaluate the reprojection error for each camera separately to detect possible problems
%%%
for i=1:size(config.cal.cams2use,2),
	cam(i).mean2Derr = mean(cam(i).err2d);
	cam(i).std2Derr  = std(cam(i).err2d);
end
% sort the values and print them to the 2D graphs

figure(30), 
clf
plot(config.cal.cams2use,[cam.mean2Derr],'bd'),
hold on, grid on,
plot(config.cal.cams2use,[cam.mean2Derr],'b-'),
plot(config.cal.cams2use,[cam.std2Derr],'rd')
plot(config.cal.cams2use,[cam.std2Derr],'r-')
xlabel('Id of the camera')
title('2D error: mean (blue), std (red)')
ylabel('pixels')

figure(31)
clf
bar(config.cal.cams2use,[cam.mean2Derr;cam.std2Derr]',1.5)
grid on
xlabel('Id of the camera')
title('2D error: mean (blue), std (red)')
ylabel('pixels')

figure(31), 
eval(['print -depsc ', config.paths.data, 'reprerrors.eps'])

figure(4), 
eval(['print -depsc ', config.paths.data, 'reconstructedsetup.eps'])

Ret = 1;
return
