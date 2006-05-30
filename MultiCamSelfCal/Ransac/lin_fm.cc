#include <octave/oct.h>
#include <cmath>

DEFUN_DLD (lin_fm, args, ,
	   "[...] = lin_fm (...)\n")
{
  Matrix ovu (args(0).matrix_value());

  double *u = ovu.rep->data; // this is a naughty way to get a pointer to the data
  double *p, *s;
  int len = ovu.columns();
  int i,k,l,pos;

  Matrix output_matrix(len,9);
  p = output_matrix.rep->data; // this is a naughty way to get a pointer to the data

  printf("lin_fm\n");

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
  return octave_value(output_matrix);
}

  
