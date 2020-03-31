from __future__ import print_function
import subprocess
import shlex
import threading
import os.path
import logging
logging.basicConfig()
import tempfile
import shutil

import numpy as np

from .formats import camera_calibration_yaml_to_radfile
from .visualization import create_pcd_file_from_points

LOG = logging.getLogger('mcsc')

class ThreadedCommand(threading.Thread):
    def __init__(self, cmds,cwd,stdout,stderr,stdin=None,shell=False,executable=None):
        threading.Thread.__init__(self)
        if not shell:
            cmds = shlex.split(cmds)
        self._cmds = cmds
        self._cwd = cwd
        self._stdin = stdin
        self._stdout = stdout
        self._stderr = stderr
        self._shell=shell
        self._executable=executable
        self._cb = None
        self._cbargs = tuple()

    def run(self):
        kwargs = dict(              stdin=self._stdin,
                                    stdout=self._stdout,
                                    stderr=self._stderr,
                                    shell=self._shell,
                                    executable=self._executable,
                                    cwd=self._cwd)

        logging.getLogger('mcsc.cmd').debug("running cmd %r kwargs: %r" % (
            self._cmds,kwargs))

        self._cmd = subprocess.Popen(self._cmds, **kwargs)

        self.pid = self._cmd.pid
        self.results = self._cmd.communicate(self._stdin)
        self.returncode = self._cmd.returncode
        if self._cb:
            self._cb(self, *self._cbargs)

    def set_finished_cb(self, cb, *args):
        self._cb = cb
        self._cbargs = args

_cfg_file = """[Files]
Basename: {basename}
Image-Extension: jpg

[Images]
Subpix: 0.5

[Calibration]
Num-Cameras: {num_cameras}
Num-Projectors: 0
Nonlinear-Parameters: 50    0    1    0    0    0
Nonlinear-Update: 1   0   1   0   0   0
Initial-Tolerance: {initial_tolerance}
Do-Global-Iterations: 0
Global-Iteration-Threshold: 0.5
Global-Iteration-Max: 5
Num-Cameras-Fill: {num_cameras_fill}
Do-Bundle-Adjustment: 1
Undo-Radial: {undo_radial}
Min-Points-Value: 30
N-Tuples: 3
Square-Pixels: {square_pixels}
Use-Nth-Frame: {use_nth_frame}
Align-Existing: {align_existing}
"""

def load_ascii_matrix(filename):
    fd=open(filename,mode='rb')
    lines = []
    for line in fd.readlines():
        if line[0] == "#":
            continue #comment
        lines.append(line.strip())
    return np.array([map(float,line.split()) for line in lines])

def save_ascii_matrix(arr,fd,isint=False):
    """
    write a np.ndarray with 2 dims
    """
    assert arr.ndim==2
    if arr.dtype==np.bool:
        arr = arr.astype( np.uint8 )

    close_file = False
    if type(fd) == str:
        fd = open(fd,mode='w')
        close_file = True

    for row in arr:
        row_buf = ' '.join( map(repr,row) )
        fd.write(row_buf)
        fd.write('\n')

    if close_file:
        fd.close()

class _Calibrator:
    def __init__(self, out_dirname, **kwargs):
        if out_dirname:
            out_dirname = os.path.abspath(os.path.expanduser(out_dirname))
            if not os.path.isdir(out_dirname):
                os.mkdir(out_dirname)
        else:
            out_dirname = tempfile.mkdtemp(prefix=self.__class__.__name__)

        self.octave = kwargs.get('octave','/usr/bin/octave')
        self.matlab = kwargs.get('matlab','/opt/matlab/R2011a/bin/matlab')
        self.use_matlab = kwargs.get('use_matlab', False)
        self.out_dirname = out_dirname

    def create_from_cams(self, cam_ids=[], cam_resolutions={}, cam_points={}, cam_calibrations={}, **kwargs):
        raise NotImplementedError

class MultiCamSelfCal(_Calibrator):

    INPUT = ("camera_order.txt","IdMat.dat","points.dat","Res.dat","multicamselfcal.cfg", "original_cam_centers.dat")

    def __init__(self, out_dirname, basename='basename', use_nth_frame=1, mcscdir='/opt/multicamselfcal/MultiCamSelfCal/', **kwargs):
        _Calibrator.__init__(self, out_dirname, **kwargs)
        self.mcscdir = mcscdir
        self.basename = basename
        self.use_nth_frame = use_nth_frame
        self.align_existing = False

        if not os.path.exists(os.path.join(self.mcscdir,'gocal.m')):
            LOG.warn("could not find MultiCamSelfCal gocal.m in %s" % self.mcscdir)

    def _write_cam_ids(self, cam_ids):
        with open(os.path.join(self.out_dirname,'camera_order.txt'),'w') as f:
            for i,camid in enumerate(cam_ids):
                if camid[0] == "/":
                    camid=camid[1:]
                f.write("%s\n"%camid)

    def _write_cfg(self, cam_ids, radial_distortion, square_pixels, num_cameras_fill, cam_centers, initial_tolerance):
        if num_cameras_fill < 0 or num_cameras_fill > len(cam_ids):
            num_cameras_fill = len(cam_ids)

        var = dict(
            basename = self.basename,
            num_cameras = len(cam_ids),
            num_cameras_fill = int(num_cameras_fill),
            undo_radial = int(radial_distortion),
            square_pixels = int(square_pixels),
            initial_tolerance = float(initial_tolerance),
            use_nth_frame = self.use_nth_frame,
            align_existing = 1 if len(cam_centers) else 0,
            )

        with open(os.path.join(self.out_dirname, 'multicamselfcal.cfg'), mode='w') as f:
            f.write(_cfg_file.format(**var))

        LOG.debug("calibrate cams: %s" % ','.join(cam_ids))
        LOG.debug("undo radial: %s" % radial_distortion)
        LOG.debug("num_cameras_fill: %s" % num_cameras_fill)
        LOG.debug("wrote camera calibration directory: %s" % self.out_dirname)

    def get_cmd_and_cwd(self, cfg):
        if self.use_matlab:
            cmds = '%s -nodesktop -nosplash -r "cd(\'%s\'); gocal_func(\'%s\'); exit"' % (
                        self.matlab, self.mcscdir, cfg)
            cwd = None
        else:
            cmds = '%s gocal.m --config=%s' % (
                        self.octave, cfg)
            cwd = self.mcscdir
        return cmds,cwd

    def execute(self, blocking=True, cb=None, dest=None, silent=True, copy_files=True):
        """
        if dest is specified then all files are copied there unless copy is false. If dest is not
        specified then it is in a subdir of out_dirname called result

        @returns: dest (or nothing if blocking is false). In that case cb is called when complete
        and is passed the dest argument
        """
        if not dest:
            dest = os.path.join(self.out_dirname,'result')
            if not os.path.isdir(dest):
                os.makedirs(dest)

        stdout_fname = os.path.join(dest,'STDOUT')
        stderr_fname = os.path.join(dest,'STDERR')

        LOG.info("running mcsc (result dir: %s)" % dest)

        for f in self.INPUT:
            src = os.path.join(self.out_dirname,f)
            if copy_files:
                if os.path.isfile(src):
                    shutil.copy(src, dest)
                else:
                    LOG.warn("Could not find %s" % src)
            else:
                if not os.path.isfile(src):
                    LOG.warn("Could not find %s" % src)

        if copy_files:
            for k,v in self.get_camera_names_map().items():
                src = os.path.join(self.out_dirname,v)
                if os.path.isfile(src):
                    shutil.copy(src, dest)
                else:
                    LOG.warn("Could not find %s" % src)

        cfg = os.path.abspath(os.path.join(dest, "multicamselfcal.cfg"))

        cmds,cwd = self.get_cmd_and_cwd(cfg)

        bash_path = '/bin/bash'
        if os.path.exists(bash_path) and not silent:
            shell=True
            # http://stackoverflow.com/questions/692000
            cmds = cmds + ' > >(tee %s) 2> >(tee %s >&2)'%(stdout_fname,stderr_fname)
            executable = bash_path
            stdout = stderr = None
        else:
            shell=False
            executable=None
            if not silent:
                LOG.warn('you requested not silent, but bash is required to support that.')
            stdout = open(stdout_fname,'w')
            stderr = open(stderr_fname,'w')

        cmd = ThreadedCommand(cmds,cwd=cwd,stdout=stdout,stderr=stderr,
                              shell=shell,executable=executable)
        cmd.set_finished_cb(cb,dest)
        cmd.start()

        if blocking:
            cmd.join()
            if cmd.returncode != 0:
                raise RuntimeError('MCSC failed')
            return dest

    def create_from_cams(self, cam_ids=[], cam_resolutions={}, cam_points={}, cam_calibrations={}, num_cameras_fill=-1, **kwargs):
        #num_cameras_fill = -1 means use all cameras (= len(cam_ids))

        if not cam_ids:
            cam_ids = cam_points.keys()

        #remove cameras with no points
        cams_to_remove = []
        for cam in cam_ids:
            nvalid = np.count_nonzero(np.nan_to_num(np.array(cam_points[cam])))
            if nvalid == 0:
                cams_to_remove.append(cam)
                LOG.warn("removing cam %s - no points detected" % cam)
        map(cam_ids.remove, cams_to_remove)

        self._write_cam_ids(cam_ids)

        resfd = open(os.path.join(self.out_dirname,'Res.dat'), 'w')
        foundfd = open(os.path.join(self.out_dirname,'IdMat.dat'), 'w')
        pointsfd = open(os.path.join(self.out_dirname,'points.dat'), 'w')

        for i,cam in enumerate(cam_ids):
            points = np.array(cam_points[cam])
            assert points.shape[1] == 2
            npts = points.shape[0]

            #add colum of 1s (homogenous coords, Z)
            points = np.hstack((points, np.ones((npts,1))))
            #multicamselfcal expects points rowwise (as multiple cams per file)
            points = points.T

            #detected points are those non-nan (just choose one axis, there is no
            #possible scenario where one axis is a valid coord and the other is nan
            #in my feature detection scheme
            found = points[0,:]
            #replace nans with 0 and numbers with 1
            found = np.nan_to_num(found).clip(max=1)

            res = np.array(cam_resolutions[cam])

            save_ascii_matrix(res.reshape((1,2)), resfd, isint=True)
            save_ascii_matrix(found.reshape((1,npts)), foundfd, isint=True)
            save_ascii_matrix(points, pointsfd)

            #write camera rad files if supplied
            if cam in cam_calibrations:
                url = cam_calibrations[cam]
                assert os.path.isfile(url)
                #i+1 because mcsc expects matlab numbering...
                dest = "%s/%s%d.rad" % (self.out_dirname, self.basename, i+1)
                if url.endswith('.yaml'):
                    camera_calibration_yaml_to_radfile(
                        url,
                        dest)
                elif url.endswith('.rad'):
                    shutil.copy(url,dest)
                else:
                    raise Exception("Calibration format %s not supported" % url)

        resfd.close()
        foundfd.close()
        pointsfd.close()

        undo_radial = all([cam in cam_calibrations for cam in cam_ids])
        self._write_cfg(cam_ids,
                        undo_radial,
                        True,
                        num_cameras_fill,
                        [])
        LOG.debug("dropped cams: %s" % ','.join(cams_to_remove))

    def create_calibration_directory(self, cam_ids, IdMat, points, Res, cam_calibrations=[], cam_centers=[], radial_distortion=0, square_pixels=1, num_cameras_fill=-1, initial_tolerance=10.0):
        assert len(Res) == len(cam_ids)
        if len(cam_calibrations): assert len(cam_ids) == len(cam_calibrations)
        if len(cam_centers): assert len(cam_ids) == len(cam_centers)

        LOG.debug("points.shape %r" % (points.shape,))
        LOG.debug('IdMat.shape %r' % (IdMat.shape,))
        LOG.debug('Res %r' % (Res,))

        self._write_cam_ids(cam_ids)

        if len(cam_calibrations):
            for i,url in enumerate(cam_calibrations):
                assert os.path.isfile(url)
                #i+1 because mcsc expects matlab numbering...
                dest = "%s/%s%d.rad" % (self.out_dirname, self.basename, i+1)
                if url.endswith('.yaml'):
                    camera_calibration_yaml_to_radfile(
                        url,
                        dest)
                elif url.endswith('.rad'):
                    shutil.copy(url,dest)
                else:
                    raise Exception("Calibration format %s not supported" % url)

                LOG.debug('wrote cam calibration file %s' % dest)

        if len(cam_centers):
            save_ascii_matrix(cam_centers,os.path.join(self.out_dirname,'original_cam_centers.dat'))

        save_ascii_matrix(Res, os.path.join(self.out_dirname,'Res.dat'), isint=True)
        save_ascii_matrix(IdMat, os.path.join(self.out_dirname,'IdMat.dat'), isint=True)
        save_ascii_matrix(points, os.path.join(self.out_dirname,'points.dat'))

        self._write_cfg(cam_ids, radial_distortion, square_pixels, num_cameras_fill, cam_centers, initial_tolerance)

    def get_camera_names_map(self, filetype="rad"):
        if filetype == "rad":
            tmpl = self.basename+"%d.rad"
        else:
            raise ValueError("Only rad files supported")

        result = {}
        for i,name in enumerate(MultiCamSelfCal.read_calibration_names(self.out_dirname)):
            result[name] = tmpl % (i+1)

        return result

    @staticmethod
    def reshape_calibrated_points(xe):
        return xe[0:3,:].T.tolist()

    @staticmethod
    def read_calibration_result_inliers(inlier_dirname):
        Xe = load_ascii_matrix(os.path.join(inlier_dirname,'Xe.dat'))
        Ce = load_ascii_matrix(os.path.join(inlier_dirname,'Ce.dat'))
        Re = load_ascii_matrix(os.path.join(inlier_dirname,'Re.dat'))
        return Xe,Ce,Re

    @staticmethod
    def read_calibration_names(flydra_cal_src):
        with open(os.path.join(flydra_cal_src,'camera_order.txt'),'r') as fd:
            cam_ids = fd.read().split('\n')
            if cam_ids[-1] == '': del cam_ids[-1] # remove blank line
            return cam_ids

    @staticmethod
    def save_to_pcd(dirname, fname):
        xe,ce,re = MultiCamSelfCal.read_calibration_result_inliers(dirname)
        points = MultiCamSelfCal.reshape_calibrated_points(xe)
        create_pcd_file_from_points(fname,points)

if __name__ == "__main__":
    import sys

    logging.basicConfig(level=logging.DEBUG)

    mydir = os.path.split(__file__)[0]
    SRC_PATH = os.path.abspath(os.path.join(mydir,'..','..'))

    try:
        data = os.path.abspath(os.path.expanduser(sys.argv[1]))
    except IndexError:
        data = os.path.abspath(
                    os.path.join(SRC_PATH,
                    'strawlab','test-data','DATA20100906_134124'))

    mcscdir = os.path.join(SRC_PATH,'MultiCamSelfCal')
    kwargs = {}
    if os.path.exists(mcscdir):
        # assume running from source
        kwargs['mcscdir']=mcscdir

    mcsc = MultiCamSelfCal(data, **kwargs)
    caldir = mcsc.execute(silent=False)

    print("result:",caldir)
