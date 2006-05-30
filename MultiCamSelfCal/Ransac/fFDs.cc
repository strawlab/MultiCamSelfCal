#include <octave/oct.h>
#include <cmath>

#define f1 F(0)
#define f2 F(1)
#define f3 F(2)
#define f4 F(3)
#define f5 F(4)
#define f6 F(5)
#define f7 F(6)
#define f8 F(7)
#define f9 F(8)

#define u1 u(uinc+0)
#define u2 u(uinc+1)
#define u4 u(uinc+3)
#define u5 u(uinc+4)

DEFUN_DLD (fFDs, args, ,
  "[...] = fFDs (...)\n\
\n\
fast FDs routine.")
{

  ColumnVector F (args(0).vector_value());
  ColumnVector u (args(1).vector_value());

  int len = u.length();
  ColumnVector p (len);

  double rx, ry, rwc, ryc, rxc, r;
  int i;
  int uinc=0;

  printf("fFDs\n");

  for (i=0; i<len; i++)
    {
      rxc = f1 * u4 + f4 * u5 + f7;
      ryc = f2 * u4 + f5 * u5 + f8;
      rwc = f3 * u4 + f6 * u5 + f9;
      r =(u1 * rxc + u2 * ryc + rwc);
      rx = f1 * u1 + f2 * u2 + f3;
      ry = f4 * u1 + f5 * u2 + f6; 

      p(i) = r*r / (rxc*rxc + ryc*ryc + rx*rx + ry*ry);
      uinc += 6;
    }
  return octave_value(p);
}
