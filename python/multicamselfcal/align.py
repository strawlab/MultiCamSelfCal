import numpy as np

def estsimt(X1,X2):
    # from estsimt.m in MultiCameSelfCal

    # ESTimate SIMilarity Transformation
    #
    # [s,R,T] = estsimt(X1,X2)
    #
    # X1,X2 ... 3xN matrices with corresponding 3D points
    #
    # X2 = s*R*X1 + T
    # s ... scalar scale
    # R ... 3x3 rotation matrix
    # T ... 3x1 translation vector
    #
    # This is done according to the paper:
    # "Least-Squares Fitting of Two 3-D Point Sets"
    # by K.S. Arun, T. S. Huang and S. D. Blostein

    N = X1.shape[1]
    if N != X2.shape[1]:
        raise ValueError('both X1 and X2 must have same number of points')

    X1cent = np.mean(X1,axis=1)
    X2cent = np.mean(X2,axis=1)
    # normalize coordinate systems for both set of points
    x1 = X1 - X1cent[:,np.newaxis]
    x2 = X2 - X2cent[:,np.newaxis]

    # mutual distances
    d1 = x1[:,1:]-x1[:,:-1]
    d2 = x2[:,1:]-x2[:,:-1]
    ds1 = np.sqrt( np.sum( d1**2, axis=0) )
    ds2 = np.sqrt( np.sum( d2**2, axis=0) )

    scales = ds2/ds1
    s = np.median( scales )

    # undo scale
    x1s = s*x1

    # finding rotation
    H = np.zeros((3,3))
    for i in range(N):
        tmp1 = x1s[:,i,np.newaxis]
        tmp2 = x2[np.newaxis,:,i]
        tmp = np.dot(tmp1,tmp2)
        H += tmp

    U,S,Vt = np.linalg.svd(H)
    V = Vt.T
    X = np.dot(V,U.T)
    R=X

    T = X2cent - s*np.dot(R,X1cent)
    return s,R,T

def build_xform(s,R,t):
    T = np.zeros((4,4),dtype=np.float)
    T[:3,:3] = R
    T = s*T
    T[:3,3] = t
    T[3,3]=1.0
    return T

def align_points( s,R,T, X ):
    T = build_xform(s,R,T)
    if X.shape[0]==3:
        # make homogeneous
        Xnew = np.ndarray((4,X.shape[1]),dtype=X.dtype)
        Xnew[3,:].fill(1)
        Xnew[:3,:] = X
        X = Xnew
    X = np.dot(T,X)
    return X

def align_pmat( s,R,T, P ):
    T = build_xform(s,R,T)
    P = np.dot(P,np.linalg.inv(T))
    return P

def align_pmat2( M, P ):
    P = np.dot(P,np.linalg.inv(M))
    return P
