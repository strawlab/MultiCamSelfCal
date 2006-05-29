%SHOWIMG  Pajdla: Shows scaled images in the gray palette
%
%
%	function f = showimg(m,f)
%
%	m = image matrix  
%	f = figure handle
%
%       See also:  IMAGE, IMAGESC, COLORMEN.

%	Author: 	Tomas Pajdla, Tomas.Pajdla@esat.kuleuven.ac.be 
%					    pajdla@vision.felk.cvut.cz
%			03/06/95 ESAT-MI2, KU Leuven
%	Documentation:                 	 	  
%	Language: 	Matlab 4.2, (c) MathWorks  			 
%
function f = showimg(m,f);

if (nargin==2)
 figure(f);
else 
 f=figure;
%  colormen;
 colormap('gray');
end
 
imagesc(m);
axis('image');

return
