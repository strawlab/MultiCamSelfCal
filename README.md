# Multi Camera Self Calibration toolbox

[![build](https://github.com/strawlab/multicamselfcal/workflows/build/badge.svg?branch=main)](https://github.com/strawlab/multicamselfcal/actions?query=branch%3Amain)

The is an updated version of the Multi Camera Self Calibration toolbox
by Svoboda et al.

**Links:**

* This version of the code lives on [github](https://github.com/strawlab/MultiCamSelfCal).

* The [original website](http://cmp.felk.cvut.cz/~svoboda/SelfCal/)
  remains a good source of information. (This version of the code is
  being made publicly available with the permission of Tomas Svoboda.)

* We have an [online discussion group](http://groups.google.com/group/multicamselfcal).

If you use this library, please cite:

Svoboda T, Martinec D, Pajdla T. (2005) A convenient multi-camera
self-calibration for virtual environments. *PRESENCE: Teleoperators and
Virtual Environments*. 14(4):407-422.
[link](http://citeseerx.ist.psu.edu/viewdoc/summary?doi=10.1.1.1.2564>)

## Changes from the original version

At a high level, the changes are all in the usage, and not in the
algorithmic domain. Those I remember are:

* Various small changes to get to work using Octave

* Disable plotting when running using Octave

* Implementation of new configuration file format that lives alongside
  the calibration data rather than in the source code files

* Inclusion of some sample data and tests

* Inclusion of a python interface to run the MultiCamSelfCal application

* Improved the interface for maximally aligning a new calibration to existing
  camera centers. See Align-Existing config option, and
  the original_cam_centers.dat input file.

The original readme file is in `MultiCamSelfCal/README.txt`

## Quick test

To test if everything is working for you, do the following:

    cd MultiCamSelfCal
    octave gocal.m --config=../strawlab/test-data/DATA20100906_134124/no-global-iterations.cfg

This will run most of the algorithm on some sample data. Your computer
should churn for a few minutes and finally should end with some lines
indicating a successful calibration (with mean reprojection error 0.62
pixels):

```
GNU Octave, version 3.2.3
Copyright (C) 2009 John W. Eaton and others.
This is free software; see the source code for copying conditions.
There is ABSOLUTELY NO WARRANTY; not even for MERCHANTABILITY or
FITNESS FOR A PARTICULAR PURPOSE.  For details, type `warranty'.

Octave was configured for "x86_64-pc-linux-gnu".

Additional information about Octave is available at http://www.octave.org.

Please contribute if you find this software useful.
For more information, visit http://www.octave.org/help-wanted.html

Report bugs to <bug@octave.org> (but first, please read
http://www.octave.org/bugs.html to learn how to write a helpful report).

For information about changes from previous versions, type `news'.

arg = --config=../strawlab/test-data/DATA20100906_134124/no-global-iterations.cfg
config_dir = /home/astraw/astraw-git-root/flydra/MultiCamSelfCal/MultiCamSelfCal/../strawlab/test-data/DATA20100906_134124/
Multi-Camera Self-Calibration, Tomas Svoboda et al., 07/2003
************************************************************
Experiment name: strawlab_test
warning: The calibration file config.files.CalPmat does not exist
warning: No P mat available
warning: The calibration file config.files.CalPmat does not exist
warning: No P mat available
warning: The calibration file config.files.CalPmat does not exist
warning: No P mat available
warning: The calibration file config.files.CalPmat does not exist
warning: No P mat available
warning: No Pmat available

********** After 0 iteration *******************************************
RANSAC validation step running with tolerance threshold: 10.00 ...
RANSAC: 2 samples, 523 inliers out of 523 points
RANSAC: 1 samples, 523 inliers out of 523 points
RANSAC: 2 samples, 432 inliers out of 434 points
RANSAC: 1 samples, 362 inliers out of 362 points
522 points/frames have survived validations so far
Filling of missing points is running ...
Repr. error in proj. space (no fact./fact.) is ...  0.708677 0.688062
************************************************************
Number of detected outliers:   0
About cameras (Id, 2D reprojection error, #inliers):
CamId    std       mean  #inliers
  1      0.62      0.69    432
  2      0.81      0.70    523
  3      0.83      0.78    523
  4      0.49      0.53    362
***************************************************************
**************************************************************
Refinement by using Bundle Adjustment
Repr. error in proj. space (no fact./fact./BA) is ...  0.714557 0.686345 0.620358
2D reprojection error
All points: mean  0.62 pixels, std is 0.61
```
## Python wrapper

John Stowers wrote an API to let this code be directly called from Python.

To install:

    pip install multicamselfcal

To install from the git repository:

    pip install -e .

To test:

    pytest
