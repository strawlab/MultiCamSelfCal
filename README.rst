Multi Camera Self Calibration toolbox
-------------------------------------

To run a quick test with Octave 3.2::

  cd MultiCamSelfCal
  octave gocal.m

The output on the console should be something like::

  Filling of missing points is running ...
  Repr. error in proj. space (no fact./fact.) is ...  0.162177 0.159349
  ************************************************************
  Number of detected outliers:   0
  About cameras (Id, 2D reprojection error, #inliers):
  CamId    std       mean  #inliers
    1      0.15      0.15    890
    2      0.16      0.15    890
    3      0.18      0.18    889
  ***************************************************************
  **************************************************************
  Refinement by using Bundle Adjustment
  Repr. error in proj. space (no fact./fact./BA) is ...  0.159534 0.159349 0.145579
  2D reprojection error
  All points: mean  0.15 pixels, std is 0.14
