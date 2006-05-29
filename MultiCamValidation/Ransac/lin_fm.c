#include <math.h>
#include "mex.h"
#include "matrix.h"

void mexFunction( int dstN, mxArray **aDstP, int aSrcN, const mxArray **aSrcP )
{
  double *u = mxGetPr(aSrcP[0]);
  double *p, *s;
  int len = mxGetN(aSrcP[0]);
  int i,k,l,pos;
  
  aDstP[0] = mxCreateDoubleMatrix(len, 9, mxREAL );
  p = (double *)mxGetData(aDstP[0]);

  s = u;
  for (i = 0; i < len; i++)
    {
      pos = 0;
      for (k = 0; k < 3; k++)
	{
        for (l = 0; l < 3; l++)
	  {
            *(p+pos) = *(s+k+3) * (*(s+l));
	    pos += len;
	  }
        }  
      s += 6;
      p++;
    }
}

  
