MATLAB_PATH = '/usr/local/matlab/';

global Start_path;
Start_path = '/home.dokt/martid1/export/svoboda/Matlab';
setpaths;

screen = get(0, 'ScreenSize');
xwidth = screen(4)/2;
ywidth = screen(4)/2;
set(0, 'defaultfigureposition', [screen(3)-xwidth*1.1 5 xwidth*1.1-4 ywidth*0.9]);
clear screen xwidth ywidth

set(0,'FormatSpacing',         'compact',...
      'DefaultFigureColormap' , (0:1/63:1)'*[1 1 1],...
      'DefaultFigureMenu', 'none' );
close

flops(0);
