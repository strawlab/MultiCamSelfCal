def create_pcd_file_from_points(fname, points, npts=None):
    HEADER = \
    "# .PCD v.7 - Point Cloud Data file format\n"\
    "VERSION .7\n"\
    "FIELDS x y z\n"\
    "SIZE 4 4 4\n"\
    "TYPE F F F\n"\
    "COUNT 1 1 1\n"\
    "WIDTH %(npoints)d\n"\
    "HEIGHT 1\n"\
    "VIEWPOINT 0 0 0 1 0 0 0\n"\
    "POINTS %(npoints)d\n"\
    "DATA ascii\n"

    ok = False
    if len(points):
        if len(points[0]) == 3:
            ok = True
    if not ok:
        raise ValueError("Points must be a list of (x,y,z) tuples")

    with open(fname, 'w') as fd:
        fd.write(HEADER % {"npoints":len(points)})
        for pt in points:
            fd.write("%f %f %f\n" % tuple(pt))
