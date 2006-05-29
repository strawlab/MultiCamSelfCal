% $Author: svoboda $
% $Revision: 2.2 $
% $Id: README.txt,v 2.2 2005/05/24 09:15:30 svoboda Exp $
% $State: Exp $

WWW:
http://cmp.felk.cvut.cz/~svoboda/SelfCal/
look at the home page to get the newest information, latest sources,
publications, sample data etc.

Authors: 
- Tomas Svoboda, svoboda@cmp.felk.cvut.cz, (design of the package,
most of the codes), corresponding author

- Daniel Martinec and Tomas Pajdla, {martid1,pajdla}@cmp.felk.cvut.cz
(filling points)

- Ondrej Chum, chum@fel.cvut.cz (RANSAC implementation)

- Tomas Werner, werner@cmp.felk.cvut.cz (Projective Bundle Adjustment)

- Jean-Yves Bouguet, jean-yves.bouguet@intel.com, (part of the Radial
  distortion computation)

Just a short how-to for multicamera selfcalibration:
----------------------------------------
svoboda@vision.ee.ethz.ch, 08/2002
updated 12/2002, 01/2003, 02/2003, 03/2003, 06/2003, 07/2003

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% For BlueC users
%%% Very short how-to for them who know 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

(the steps denoted by * are typically needed to be performed just once
for each user)

- Capture *.pvi files

- convert *.pvi files to sequences of images

* Go to */BlueCCal/BlueCFindingPoints and check all the three files
  there. They have some local settings which has to be set for each
  user differently.

- run ./findpointsBlueC 
  This script starts finding process on each of the cluster machine

- collect the data stored locally on the cluster machines.

* Edit configdata.m and expname.m in */BlueCCal/CommonCfgAndIO

- Go to */BlueCCal/MultiCamSelfCal, run matlab

From now on in matlab window:
-  >> gocal
   Wait for the results. It may take several minutes if you have many
   cameras and many points.

   Wait ...., and you are done if you are lucky ;-)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Information relevant to the BlueC project 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

The CamSelfCal code is in /home/svoboda/Work/BlueCCal
The auxiliary scripts and acquisition SW are in /home/svoboda/Work/BlueCAcquire

You will also need to set some local variables.
############################################################################
# blue-c
if ( -f /opt/modules/modules/init/tcsh) then
        source /opt/modules/modules/init/tcsh
        if ( -d ${HOME}/lib/modulefiles ) then
                module use ${HOME}/lib/modulefiles
        endif

		# module add blue-c/linux-gcc3.2   # needed for 3DVideoRecorder
        module add blue-c/linux            # needed for the ClientTester

		setenv LD_LIBRARY_PATH $ACE_ROOT/ace/:/home/lamboray/lib/:$LD_LIBRARY_PATH
        setenv LD_LIBRARY_PATH /pub/blue-c_lib/BCL/version_1.0/lib/linux-gcc3.2/:$LD_LIBRARY_PATH
		# additional library I had to add
        setenv LD_LIBRARY_PATH /pub/blue-c/development/pwes/lamboray/3DVideoRecorder/lib/:$LD_LIBRARY_PATH
        setenv LD_LIBRARY_PATH /pub/blue-c_lib/BCL/version_1.0/lib/linux-gcc3.2/old/:$LD_LIBRARY_PATH
endif

# Set local variabled for the auxiliary scripts
# machine name
set machine_basename = `echo $HOST | sed 's/[0-9]//g'`
setenv BlueC_MNAME "$machine_basename"
# local directory on the machines where the data is stored
setenv BlueC_LOCALDIR "/local/tomas"
# image base name
setenv BlueC_IMNAME "$machine_basename"
# basepath for binaries and auxiliary scripts
setenv BlueC_BASEPATH "/home/svoboda/Work/BlueCAcquire"
###
# full indexes and working machine to process the data
# need to be set differently for atlantics and arctics
if ( $machine_basename == "atlantic" ) then
        # setenv BlueC_INDEXES `(seq 3 18)`
        setenv BlueC_INDEXES "3 4 5 6 7 8 9 10 11 12 14 15 16 17 18"
        setenv BlueC_WORKMACHINE "${machine_basename}2"
else if ($machine_basename == "arctic") then
        setenv BlueC_INDEXES `(seq 1 16)`
        # setenv BlueC_INDEXES "1 2 3 4 5 6 7 8 9 10 11 12 13 15 16"
        setenv BlueC_WORKMACHINE "${machine_basename}19"
endif
############################################################################


The scripts are in Perl or C-shell and are very simple and not very
robust. They use "convert" and "montage" tools from "ImageMagick"
package whis a standard part of most Linux distributions. 

BlueC acquisition software is mostly written by Edouard Carlo Lamboray,
lamboray@inf.ethz.ch.

Run the administration script "firewire" written by Stephan Wuermlin,
wuermlin@inf.ethz.ch, if the 3DVideoRecorder does not work. 
Try: 
>> firewire stop 
>> firewire reload 
>> firewire chmod 
This should help.

Config files "configdata.m" and "expname.m" are in the sub-directory
Cfg. The configdata contains necessary paths to the data and the
expname determines the relevant subset of config data. 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

1) Image acqusition

- Check if the video.cfg is OK. The shuter should be usualy at 590. It
  very depends on the laser. The triggering should MUST be 1!

- Switch off the triggering signal.

- Start "./3DVideoRecorder -u -s -b 0 -n #number_of_images" to capture
  sequences on each machine with camera attached to. The
  3DVideoRecorder expects the config files in ../Cfg/
  directory. #number_of_images should be between 300-700. More images
  gives more robustness however, their processing takes accordingly
  longer. The processing time is linear in terms of images.

- Switch the triggering signal on and ...

- Wave laser pointer. Try to fill the whole working volume. Try to
  keep the laser pointer visible to as many cameras as
  possible. Especially is necessary to fill the volume close to the
  cave floor. 

- The 3DVideoRecorder stores big *.pvi files in /local/ directory on
  each of the machine then ...

- Run the "collectdata" to extract, transform and collect
  images. Check if the paths are specified correctly.

- You can use "createMontages" script to create 4x4 composed
  images. Check the image quality and the VISIBILITY of points.

- Change the config.files.idxcams accordingly if some cameras are
  missing.

2) Computing images statitistics and finding laser projections in
   images.

The codes are in the sub-directory FindingPoints

Important note: To run the image processing in parallel we need: be
able to run "matlab" in each of the machines and have ssh access
without password (http://www.cs.umd.edu/~arun/misc/ssh.html). 


Alternatively, you can run the script im2points in one matlab, which
is also much more certain if you are not sure what you are doing. It
runs accordingly longer, 16 cameras, 500 images each needs about 30
minutes at PIII @ 1GHz (it also depends on the required
precision). The computation time is linear in terms of cameras and
images.


- Edit configdata.m and put correct paths and all config constants you
  want here.

- Important! Set the correct experiment name into expname.m. 

- Run "im2pmultiproc.pl", check if it uses the right *.pm config. This
  perl script will create some temporary files in the working
  directory. Also it needs access rights.

- Warning! If you stop "im2pmultiproc.pl" by Ctrl^C, the matlab
  processes will be still running. They have to be yet killed
  manually.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

3) Selfcalibration

- Run "gocal" in Matlab. Again, be sure to have correct name of
  the experiment in "expname.m"

- Check the graphical output. Some inside check points are
  applied. Nevertheless, it may happen that the reprojection error is
  small and the results spoiled. The graphical outputs has to be
  checked especially if only few points used for the
  computation. Check the detected points in the graphical windows. The
  points should ideally span the whole area of images. Some "holes"
  may indicate bad camera setting or a bad movement of the calibrator.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

4) What to do if the SelfCalibration crashes

- the computation itself is rather robust. However, it may crash if
  some cameras have really strange points.

- Check visually the detected points by typing 
  "figure(100), imshow(IdMat.loaded)" 
  in the main Matlab command window. The frameIds are on the x-axis,
  the cameraIds on the y-axis. Detected points are white, otherwise
  black. The whiter image the better. Black lines signalize some
  camera problems.

- To check the quality and mainly the reliability of the point
  detection you can use the script "showpoints". It plots graphical
  information to the images.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Explanation of the configuration variables
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
../CommonCfgAndIO/configdata.m

- config.paths.data = ['/scratch/WorkingCalib/']; 
  
  The main working directory containg all data. Some data may be in
  subdirectories.


- config.files.basename = 'arctic';

  Basename for all. This basename will be the main common identifier
  in all exported files.


- config.paths.img = [config.paths.data,config.files.basename,'%d/'];
  
  Basename for image sub-directories.


- config.files.imnames	= [config.files.basename,'%d.pvi.*.'];

  Basename for images.


- config.files.idxcams	= [1:10,12:16];	% related to the imnames

  Numbers that index the image sub-directories and names of various
  data files. These indexes must correspond to what is on the disk. 

- config.imgs.LEDsize	= 7; % avg diameter of a LED in pixels  

  Parameter used in the finding procedure. When unsure, better to make
  it slightly larger. Rather robust value. "7" works well for both of
  the BlueC installations.


- config.imgs.LEDcolor	= 'green'; % color of the laser pointer

  Used in the finding points. Color of the laser pointer used. 


- config.imgs.LEDthr	= 100;

  Optional parameter for the finding points procedure. Default value
  (hidden) is 70. Sometimes, it may help to resolve problems with
  misdetection. The higher value the brighter points accepted as valid
  projections. Useful only in really special cases.

- config.imgs.subpix	= 1/5;

  Used in the finding points. Required subpixels accuracy. Values
  1/3-1/5 give quite nice results. Higher values like 1 or 1/2
  increase the speed of the finding procedure significantly which may
  be useful in some fast try-and-test experiments


- config.cal.INL_TOL	= 7; 

  Rather important value. Initial tolerance value for epipolar
  geometry verification. It influences both the pair-wise point
  validation through the epipolar geometry computation and the
  iterative refinement at the end. It should correpond to the expected
  radial distortion in the cameras. This value is iteratively
  decreased during the optimization process. 


- config.cal.NUM_CAMS_FILL = 10;

  How many camera may be filled by "artificial" points. This value
  should depend to expected visibility of the calibration
  points. Higher values are typically needed if the laser pointer is
  not optimally visible in many cameras. Typically, the higher value
  the slower run of the complete procedure. On the other hand, in case
  of bad visibility, the high value may improve the robustness. From
  the principle, this value can be maximally #CAMS-3. If a higher
  value is set, automatic correction is applied. 


- config.cal.DO_BA		= 0;

  Do the Bundle Adjustment of the projective reconstruction a the end
  of the all iterations. It is quite slow for many points and
  cameras. It may improve the overall accuracy. Often not need at all.  

- config.cal.START_BA	= 1; 

  Optional parameters. When set, it does the Projective Bundle
  Adjustment in each step in the final interation for removing
  outliers. It may improves the performance for bad data sets. The
  whole process it than accordingly slower.


- config.cal.UNDO_RADIAL= 1; 

  Undo the radial distortion by using the paramaters from the CalTech
  camera calibration toolbox?  


- config.cal.UNDO_HEIKK	= 0; 

  Undo the radial distortion by using the parameters from the Jann
  Heikkila calibration toolbox?


- config.cal.NTUPLES	= 3; % currently, support for [2-5] implemented

  How many cameras are to be used for on sample of the reconstruction?
  It turned out that "3" is optimal for most of the cases. "2" is
  faster however, sometimes less robust. "4-5" more robust but slower. 


- config.cal.MIN_PTS_VAL = 30;

  Used in the MultiCamera validation. How many points must be
  simultaneously visible in config.cal.NTUPLES cameras to do the
  reconstruction step? In fact, not an important value. It might be
  useful if more points are required. This value must not be higher
  than the total number of frames acquired for the particular
  experiment. In practice, it should be below 1/2 if the theoretical
  maximal value.


- config.cal.cams2use	= [1:10,13:16];
  
  Which cameras are to be used in the particular
  experiments. Sometimes it is useful not to use all cameras specified
  in config.files.idxcams. If not set, all cameras will be used.


- config.cal.nonlinpar	= [70,0,1,0,0,0];

  Default initial settings for the estimation of the nonlinear distortion
  (1) ... camera view angle
  (2) ... estimate principal point?
  (3:4) ... estimate parameters of the radial distortion?
  (5:6) ... estimate parameters of the tangential distortion?

  It is better to start with the default settings and leave the other
  parameters to be estimated during the global optimization 


- config.cal.NL_UPDATE	= [1,1,1,1,1,1];

  Which nonlinear parameteres would you like to update during the
  global optimization. If you have noisy data with many outliers you
  may want to stabilize the optimization by fixing some
  parameteres. It also depends on what parameters are you actually
  using for undoing distortions.


- config.cal.DO_GLOBAL_ITER = 1;

  Would you like to perform global optimization? If you already have
  good parameters of the non-linear distortion you may want to disable
  this.


- config.cal.GLOBAL_ITER_THR = 0.3;

  Rather important value. This is one of the stopping condition for
  the global optimization. The process ends if the maximum of the 
  reprojection error (average in each of the cameras) is lower than
  this threshold. Do not be too optimistic. The precision of the
  complete camera model can be hardly better than the precision of the
  finding points.
 

- config.cal.GLOBAL_ITER_MAX = 10;

  If the threshold above is set too optimistic, the optimization may
  start to oscilate without actually reaching the desired
  precision. The 10 iteration should be really enough for all
  cases. If not than the data are simply worse than you think.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Strategy
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Having the images on a local disk speeds up the finiding procedeure
significantly.


You have to proceed the whole optimization process if you calibrate
the system for the first time or if you change the camera
linses. More often, however only the camera positions or orientations
change. You may then re-use the distortion parameters to speed up the
optimization process. Be sure you have the *.rad files in the working
directory and run the process with "conig.cal.UNDO_RADIAL=1" and
"config.cal.nonlinpar = [70,1,1,1,1,1]" config variables.

Set "config.cal.DO_BA=1" if you have enough time and really insist on
the highest possible precision. Actually, this is mosty not need at
all. It typically improves the final numbers but not that much the
real camera models. 

Setting "config.cal.START_BA = 1" might help resolve problems with
really bad data (many outliers, bad sychronization etc.) The
projective Bundle Adjustment is then performed in each step. It is
really needed in only very special cases. It serves more as last
rescue if everything else fails. Do not expect too much :-)
