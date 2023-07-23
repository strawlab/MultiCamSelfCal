from __future__ import print_function
from multicamselfcal.align import estsimt, align_points, align_pmat
import numpy as np

def test_align():
    orig_points = np.array([
        [3.36748406,  1.61036404,  3.55147255],
        [3.58702265,  0.06676394,  3.64695356],
        [0.28452026, -0.11188296,  3.78947735],
        [0.25482713,  1.57828256,  3.6900808],

        [3.54938525,  1.74057692,  5.13329681],
        [3.6855626 ,  0.10335229,  5.26344841],
        [0.25025385, -0.06146044,  5.57085135],
        [0.20742481,  1.71073272,  5.41823085],
        ]).T

    ft2inch = 12.0
    inch2cm = 2.54
    cm2m = 0.01
    ft2m = ft2inch * inch2cm * cm2m

    x1,y1,z1=0,0,0
    x2,y2,z2=np.array([10,5,5])*ft2m

    new_points = np.array([
        [x2, y2, z2],
        [x2, y1, z2],
        [x1, y1, z2],
        [x1, y2, z2],

        [x2, y2, z1],
        [x2, y1, z1],
        [x1, y1, z1],
        [x1, y2, z1],
        ]).T

    print(orig_points.T)
    print(new_points.T)

    s,R,t = estsimt(orig_points,new_points)
    print('s=%s'%repr(s))
    print('R=%s'%repr(R.tolist()))
    print('t=%s'%repr(t.tolist()))
    Xnew = align_points( s,R,t, orig_points )

    # measure distance between elements
    mean_absdiff = np.mean( abs(Xnew[:3]-new_points).flatten() )
    assert mean_absdiff < 0.05

    pmat_orig = np.array([[1,2,3,4],
                          [5,6,7,8],
                          [9,10,11,12]],dtype=float)
    print('Xnew.T')
    print(Xnew.T)

    pmat_new = align_pmat( s,R,t, pmat_orig )
    print('pmat_new')
    print(pmat_new)

    ## print('s',s)
    ## print('R')
    ## print(R)
    ## print('T')
    ## print(T)

