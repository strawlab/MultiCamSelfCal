#include <math.h>
#include "mex.h"
#include "matrix.h"

#define a11 (*A)
#define a12 (*(A+1))
#define a13 (*(A+2))
#define a21 (*(A+3))
#define a22 (*(A+4))
#define a23 (*(A+5))
#define a31 (*(A+6))
#define a32 (*(A+7))
#define a33 (*(A+8))

#define b11 (*B)
#define b12 (*(B+1))
#define b13 (*(B+2))
#define b21 (*(B+3))
#define b22 (*(B+4))
#define b23 (*(B+5))
#define b31 (*(B+6))
#define b32 (*(B+7))
#define b33 (*(B+8))


void mexFunction( int dstN, mxArray **aDstP, int aSrcN, const mxArray **aSrcP )
{
  double *A = mxGetPr(aSrcP[0]), *B = mxGetPr(aSrcP[1]);
  double *p;
  int i;

  aDstP[0] = mxCreateDoubleMatrix(4, 1, mxREAL);
  p = mxGetPr(aDstP[0]);
  
  *p = -(b13*b22*b31) + b12*b23*b31 + b13*b21*b32 - 
    b11*b23*b32 - b12*b21*b33 + b11*b22*b33;

  *(p+1) = -(a33*b12*b21) + a32*b13*b21 + a33*b11*b22 - 
    a31*b13*b22 - a32*b11*b23 + a31*b12*b23 + 
    a23*b12*b31 - a22*b13*b31 - a13*b22*b31 + 
    3*b13*b22*b31 + a12*b23*b31 - 3*b12*b23*b31 - 
    a23*b11*b32 + a21*b13*b32 + a13*b21*b32 - 
    3*b13*b21*b32 - a11*b23*b32 + 3*b11*b23*b32 + 
    (a22*b11 - a21*b12 - a12*b21 + 3*b12*b21 + a11*b22 - 
     3*b11*b22)*b33;

  *(p+2) = -(a21*a33*b12) + a21*a32*b13 + 
    a13*a32*b21 - a12*a33*b21 + 2*a33*b12*b21 - 
    2*a32*b13*b21 - a13*a31*b22 + a11*a33*b22 - 
    2*a33*b11*b22 + 2*a31*b13*b22 + a12*a31*b23 - 
    a11*a32*b23 + 2*a32*b11*b23 - 2*a31*b12*b23 + 
    2*a13*b22*b31 - 3*b13*b22*b31 - 2*a12*b23*b31 + 
    3*b12*b23*b31 + a13*a21*b32 - 2*a21*b13*b32 - 
    2*a13*b21*b32 + 3*b13*b21*b32 + 2*a11*b23*b32 - 
    3*b11*b23*b32 + a23*
     (-(a32*b11) + a31*b12 + a12*b31 - 2*b12*b31 - 
       a11*b32 + 2*b11*b32) + 
    (-(a12*a21) + 2*a21*b12 + 2*a12*b21 - 3*b12*b21 - 
       2*a11*b22 + 3*b11*b22)*b33 + 
    a22*(a33*b11 - a31*b13 - a13*b31 + 2*b13*b31 + 
	 a11*b33 - 2*b11*b33);

   for (i=0; i < 9; i++)
      B[i] = A[i] - B[i];
 
    *(p+3) =-(b13*b22*b31) + b12*b23*b31 + b13*b21*b32 - 
    b11*b23*b32 - b12*b21*b33 + b11*b22*b33; 
 }
