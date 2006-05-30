#include <octave/oct.h>
#include <cmath>

#define a11 A(0,0)
#define a12 A(0,1)
#define a13 A(0,3)
#define a21 A(1,0)
#define a22 A(1,1)
#define a23 A(1,2)
#define a31 A(2,0)
#define a32 A(2,1)
#define a33 A(2,2)

#define b11 B(0,0)
#define b12 B(0,1)
#define b13 B(0,2)
#define b21 B(1,0)
#define b22 B(1,1)
#define b23 B(1,2)
#define b31 B(2,0)
#define b32 B(2,1)
#define b33 B(2,2)

DEFUN_DLD (fslcm, args, ,
	   "[...] = fslcm (...)\n")
{
  Matrix A (args(0).matrix_value());
  Matrix B (args(1).matrix_value());

  ColumnVector p (4);

  printf("fslcm\n");
  
  p(0) = -(b13*b22*b31) + b12*b23*b31 + b13*b21*b32 - 
    b11*b23*b32 - b12*b21*b33 + b11*b22*b33;

  p(1) = -(a33*b12*b21) + a32*b13*b21 + a33*b11*b22 - 
    a31*b13*b22 - a32*b11*b23 + a31*b12*b23 + 
    a23*b12*b31 - a22*b13*b31 - a13*b22*b31 + 
    3*b13*b22*b31 + a12*b23*b31 - 3*b12*b23*b31 - 
    a23*b11*b32 + a21*b13*b32 + a13*b21*b32 - 
    3*b13*b21*b32 - a11*b23*b32 + 3*b11*b23*b32 + 
    (a22*b11 - a21*b12 - a12*b21 + 3*b12*b21 + a11*b22 - 
     3*b11*b22)*b33;

  p(2) = -(a21*a33*b12) + a21*a32*b13 + 
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

  for (int i=0; i < 3; i++) {
    for (int j=0; j < 3; j++) {
      B(i,j) = A(i,j) - B(i,j);
    }
  }
 
  p(3) =-(b13*b22*b31) + b12*b23*b31 + b13*b21*b32 - 
    b11*b23*b32 - b12*b21*b33 + b11*b22*b33; 
 }
