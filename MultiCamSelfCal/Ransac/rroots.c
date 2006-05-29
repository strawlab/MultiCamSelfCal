#include <math.h>
#define rr_a (*po)
#define rr_d (*(po + 3))
#define eps (2.2204e-016)

#include "mex.h"
#include "matrix.h"


void mexFunction( int dstN, mxArray **aDstP, int aSrcN, const mxArray **aSrcP )
{

  double *po = mxGetPr(aSrcP[0]);

  double b,c, b2, bt, v, pit, e, *r;
  double p, q, D, A, cosphi, phit, R, _2R;

  b = *(po + 1) / rr_a;
  c = *(po + 2) / rr_a;
  b2 = b*b;
  bt = b/3;

  p = (3*c - b2)/ 9;
  q = ((2 * b2 * b)/27 - b*c/3 + rr_d/rr_a) / 2;

  D = q*q + p*p*p;

  if (D > 0)
  {
    aDstP[0] = mxCreateDoubleMatrix( 1, 1, mxREAL );
    r = mxGetPr(aDstP[0]);

    A = sqrt(D) - q;
    if (A > 0)
    {
      v = pow(A,1.0/3);
      *r = v - p/v - bt;
    } else
    {
      v = pow(-A,1.0/3);
      *r = p/v - v - bt;
    }
  } else
  {
 /*    if (p > -eps)
      {
         printf("%.17f\n", p);
        aDstP[0] = mxCreateDoubleMatrix( 1, 1, mxREAL );
        r = mxGetPr(aDstP[0]);
        *r = pow(q,1.0/3) - bt;
      } 
      else */
      {

       aDstP[0] = mxCreateDoubleMatrix( 3, 1, mxREAL );
       r = mxGetPr(aDstP[0]);
       if (q > 0) e = 1; else e = -1;
       R = e * sqrt(-p);
       _2R = R *2;
       cosphi = q / (R*R*R);
       if (cosphi > 1) cosphi = 1; else
         if (cosphi < -1) cosphi = -1;
       phit = acos(cosphi) /3;
       pit = 3.14159265358979/3;
  
       r[0] = -_2R * cos(phit) -bt;
       r[1] =  _2R * cos(pit - phit) -bt;
       r[2] =  _2R * cos(pit + phit) -bt;
      }
  }
}
