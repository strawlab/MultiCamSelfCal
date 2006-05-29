#include <math.h>
#include "mex.h"
#include "matrix.h"

#define f1 (*F)
#define f2 (*(F+1))
#define f3 (*(F+2))
#define f4 (*(F+3))
#define f5 (*(F+4))
#define f6 (*(F+5))
#define f7 (*(F+6))
#define f8 (*(F+7))
#define f9 (*(F+8))

#define u1 (*(u))
#define u2 (*(u+1))
#define u4 (*(u+3))
#define u5 (*(u+4))

void mexFunction( int dstN, mxArray **aDstP, int aSrcN, const mxArray **aSrcP )
{
  double *F = mxGetPr(aSrcP[0]);
  double *u = mxGetPr(aSrcP[1]);
  double *p;
  double rx, ry, rwc, ryc, rxc, r;
  int len = mxGetN(aSrcP[1]);
  int i;
  
  aDstP[0] = mxCreateDoubleMatrix(1, len, mxREAL);
  p = (double *)mxGetData(aDstP[0]);

  for (i=1; i<=len; i++)
    {
      rxc = f1 * u4 + f4 * u5 + f7;
      ryc = f2 * u4 + f5 * u5 + f8;
      rwc = f3 * u4 + f6 * u5 + f9;
      r =(u1 * rxc + u2 * ryc + rwc);
      rx = f1 * u1 + f2 * u2 + f3;
      ry = f4 * u1 + f5 * u2 + f6; 

      *p = r*r / (rxc*rxc + ryc*ryc + rx*rx + ry*ry);
      p ++;
      u += 6;
    }
}
