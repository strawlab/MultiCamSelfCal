Multi Camera Self Calibration toolbox
=====================================

The is an updated version of the Multi Camera Self Calibration toolbox
by Svoboda et al. This version of the code lives at
https://github.com/strawlab/MultiCamSelfCal . The original website is
online at http://cmp.felk.cvut.cz/~svoboda/SelfCal/ . This version of
the code is being made publicly available with the permission of Tomas
Svoboda.

Changes from the original version
---------------------------------

At a high level, the changes are all in the usage, and not in the
algorithmic domain. Those I remember are:

* Various small changes to get to work using Octave

* Disable plotting when running using Octave

* Implementation of new configuration file format that lives alongside
  the calibration data rather than in the source code files

* Inclusion of some sample data and tests

The version history should make all of the changes clear.

The original readme file is in MultiCamSelfCal/README.txt

If you use this library, please cite::

  Svoboda T, Martinec D, Pajdla T. (2005) A convenient multi-camera
  self-calibration for virtual environments. PRESENCE: Teleoperators
  and Virtual Environments. 14(4):407-422.
