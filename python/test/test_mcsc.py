import os
import multicamselfcal.execute
from multicamselfcal.execute import MultiCamSelfCal

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

def test_mcsc():
    calib_dir = os.path.join(DATA_PATH, 'caldata20130726_122220' )
    mcscdir = os.path.join(SRC_PATH,'MultiCamSelfCal')
    mcsc = MultiCamSelfCal(calib_dir, mcscdir=mcscdir )
    caldir = mcsc.execute(silent=True)
    assert os.path.exists(caldir)
