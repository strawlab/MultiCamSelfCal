import numpy as np

import yaml

def camera_calibration_yaml_to_radfile(yamlpath, radpath, lossy_ok=False):
    with open(yamlpath,'r') as yf:
        y = yaml.load(yf)

        K = y['camera_matrix']['data']
        Knp = np.array(K)
        Knp.shape = y['camera_matrix']['rows'],y['camera_matrix']['cols']

        P = y['projection_matrix']['data']
        P = np.array(P)
        P.shape = y['projection_matrix']['rows'],y['projection_matrix']['cols']
        assert np.allclose(P[:,3], np.zeros((3,)))

        #Summary: the output of the opencv/ros camera calibration pipeline is confusing in that
        #the left hand 3x3 sub-matrix of P differ from the 3x3 camera (calibration) matrix.
        #This is in fact an 'artifact' of the calibration nodes call to
        #  cv.GetOptimalNewCameraMatrix(K, distortion_coefficients, ..., alpha)
        #with parameter alpha=0. See
        #  https://code.ros.org/svn/ros-pkg/stacks/image_pipeline/tags/image_pipeline-1.6.4/camera_calibration/src/camera_calibration/calibrator.py
        #  http://opencv.willowgarage.com/documentation/python/calib3d_camera_calibration_and_3d_reconstruction.html
        #
        #This results in a scaling and transformation computed and applied to K to give a new
        #P. The OpenCV docs describe this as:
        #  By varying this parameter the user may retrieve only sensible pixels alpha=0 , keep all
        #  the original image pixels if there is valuable information in the corners alpha=1 , or
        #  get something in between. When alpha>0 , the undistortion result will likely have some
        #  black pixels corresponding to "virtual" pixels outside of the captured distorted image.
        #  The original camera matrix, distortion coefficients, the computed new camera matrix
        #  and the newImageSize should be passed to InitUndistortRectifyMap to produce the maps for
        #  Remap.
        #
        #BUT.... what is sensible pixels? looking at
        #  http://code.opencv.org/projects/opencv/repository/revisions/d5a0088bbe3605e4fdd41cc41987d4a2b5d4715c/entry/modules/calib3d/src/calibration.cpp#L2560
        #  https://code.ros.org/trac/opencv/ticket/1199 (now fixed, see explanation)
        #shows that the behaviour has changed. Depending on your version sensible is defined so that the
        #input image is scaled to align cx,cy to imgw/2,imgh/2, or scaled and shifted to fit all
        #pixels in imgw/imgh when undistored. In both cases this is not useful in our monocular calibration case
        #
        #Furthermore, the ros camera calibration tool creates a misleading impression by accepting a
        #--size=X.Y command line argument, specified in world coordinates. In theory this could
        #be used to create a projection matrix which maps from pixels->3D coordinates, but in
        #practice the size is only considered in the stereo calibration case.
        #
        #I think it is more useful to consider the 3x4 Projection matrices (where the left-hand 3x3 sub-matrix
        #is not equal to K) useful only in the stereo case, as in this use the Projection matrixes, in combination
        #with the size argument, and in addition to the camera centres, are emitted in world coordinates (3D).
        #
        #Further Notes:
        #
        #In OpenCV nomenclature "camera_matrix" is 3x3 and pixel relative units (so, notably,
        #focal lenght is in pixels). This is K, C, (or sometimes M). Also referred to as
        #intrinsics. The clearest and best name (HZ page 154) is "camera calibration matrix".
        #
        #However, Wikipedia defines "camera matrix" as "camera (projection) matrix" which is
        #3x4. This is more general as it can encode a general transformation from pixel space, to some
        #other scaled and traslated object space.
        #
        #Therefore, in my opinion, a monocular camera calibration should (at an API) level only
        #return K and the distortion_coefficients. After a monocular calibration, transformation
        #of K -> P should be done by the consuming application (i.e. MultiCamSelfCal).
        #
        #In fact, MultiCamSelfCal should construct the Projection matrix for each cameras from
        #the camera_calibration_matrices, K, supplied, the calculated position of those cameras,
        #and the arbitarily determined scale.
        #
        #Other, future more advanced multiple-camera self-calibration techniques, may return projection
        #matrices that are correctly scaled. However this would require either
        # 1) Providing the calibrated (to world 3D coordinate system) P matrix for each camera
        #    (which would require a single camera calibration technique that included the size
        #    of the checkerboard as input)
        #or
        # 2) An object of known size detectable in the multiple-camera point cloud dataset

        #For all reasons listed above; in the opencv/ros single camera calibration world,
        #P is rather arbitarily scaled wrt. K, so ignore P.
        #if not np.allclose(Knp,P):
        #    raise ValueError('cannot do lossless conversion to MultiCamSelfCal .rad file (camera matrix and projection matrix differ))

        #if not lossy_ok and not np.allclose(Knp,P):
        #    raise ValueError('cannot do lossless conversion to MultiCamSelfCal '
        #                     '.rad file (matrices differ)')

        assert y['distortion_model']=='plumb_bob'
        dist = y['distortion_coefficients']['data']
        assert len(dist)==5
        if dist[4]!=0.0:
            raise ValueError('cannot do lossless conversion to MultiCamSelfCal '
                             '.rad file (dist. coeff. k3 was %f)' % dist[4])
        with open(radpath,'w') as bf:
            for row in range(3):
                for col in range(3):
                    i = col + row*3
                    bf.write("K%d%d = %f\n" % (row+1,col+1,K[i]))
            bf.write("\n")

            for i in range(4):
                bf.write("kc%d = %f\n" % (i+1,dist[i]))
            bf.write("\n")
