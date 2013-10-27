import os, shutil
import multicamselfcal.execute
from multicamselfcal.execute import MultiCamSelfCal
import tempfile

def _get_src_path():
    """this is a hack to get path to data"""
    mydir = os.path.split(__file__)[0]
    srcpath = os.path.abspath(os.path.join(mydir,'..','..'))
    return srcpath

def _get_data_path():
    """this is a hack to get path to data"""
    datapath = os.path.abspath(os.path.join(_get_src_path(),'strawlab','test-data'))
    return datapath

SRC_PATH = _get_src_path()
DATA_PATH = _get_data_path()
cal_dirnames = ['caldata20130726_122220', 'DATA20100906_134124' ]

def test_mcsc():
    for path in cal_dirnames:
        yield check_mcsc, path

def check_mcsc(path):
    calib_dir = os.path.join(DATA_PATH, path )
    mcscdir = os.path.join(SRC_PATH,'MultiCamSelfCal')
    mcsc = MultiCamSelfCal(calib_dir, mcscdir=mcscdir )
    target_dir = tempfile.mkdtemp(prefix='result-',dir=calib_dir)
    caldir = mcsc.execute(silent=True)
    assert os.path.exists(caldir)
