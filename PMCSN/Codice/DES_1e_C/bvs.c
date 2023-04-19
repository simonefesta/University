/* ------------------------------------------------------------------------- 
 * This program reads bivariate data from a text file and computes the mean, 
 * standard deviation, minimum, maximum, correlation coefficient and  
 * regression line angle (theta). 
 *  
 * NOTE: the text data file is assumed to be in a two-values-per-line format
 * (i.e. bivariate format) with NO blank lines in the file. 
 *
 * NOTE: for more information relative to the use of this program, see the
 * header of the analogous univariate program uvs.c 
 *
 * Name              : bvs.c (BiVariate Statistics) 
 * Authors           : Steve Park & Dave Geyer 
 * Language          : ANSI C  
 * Latest Revision   : 5-2-99
 * Compile with      : gcc -lm bvs.c
 * Execute with      : a.out < bvs.dat
 * ------------------------------------------------------------------------- 
 */

#include <stdio.h>
#include <math.h>

typedef struct { 
  double u;
  double v; 
} bivariate;

  int main(void)
{
  long      index;
  bivariate data;
  bivariate sum = {0.0, 0.0};
  bivariate mean;
  bivariate stdev;
  bivariate min;
  bivariate max;
  bivariate diff;
  double    cosum = 0.0;
  double    covariance;
  double    correlation;
  double    temp;
  double    theta;
  double    pi = 4.0 * atan(1.0);        /* 3.14159 ... */

  scanf("%lf %lf\n", &data.u, &data.v);
  if (!feof(stdin)) {
    index = 1;
    mean  = data;
    min   = data;
    max   = data;
  }
  else
    index = 0;

  while (!feof(stdin)) {
    scanf("%lf %lf\n", &data.u, &data.v);
    index++;
    temp    = (index - 1.0) / index;
    diff.u  = data.u - mean.u;
    diff.v  = data.v - mean.v;
    sum.u  += diff.u * diff.u * temp;
    sum.v  += diff.v * diff.v * temp;
    cosum  += diff.u * diff.v * temp;
    mean.u += diff.u / index;
    mean.v += diff.v / index;
    if (data.u > max.u)
      max.u = data.u;
    else if (data.u < min.u)
      min.u = data.u;
    if (data.v > max.v)
      max.v = data.v;
    else if (data.v < min.v)
      min.v = data.v;
  }

  if (index > 0) {
    stdev.u    = sqrt(sum.u / index);
    stdev.v    = sqrt(sum.v / index);
    covariance = cosum / index;
    if (stdev.u * stdev.v > 0.0)
      correlation = covariance / (stdev.u * stdev.v);
    else
      correlation = 0.0;
    sum.u = stdev.u * stdev.u - stdev.v * stdev.v;
    sum.v = 2.0 * covariance;
    theta = 0.5 * atan2(sum.v, sum.u);
    printf("\nfor a bivariate sample of size %ld\n\n", index);
    printf("mean.u ...... = %7.3f\n", mean.u);
    printf("stdev.u ..... = %7.3f\n", stdev.u);
    printf("min.u ....... = %7.3f\n", min.u);
    printf("max.u ....... = %7.3f\n\n", max.u);
    printf("mean.v ...... = %7.3f\n", mean.v);
    printf("stdev.v ..... = %7.3f\n", stdev.v);
    printf("min.v ....... = %7.3f\n", min.v);
    printf("max.v ....... = %7.3f\n\n", max.v);
    printf("correlation ...... = %7.3f\n", correlation);
    printf("theta (radians) .. = %7.3f\n", theta);
    printf("theta (degrees) .. = %7.3f\n", 180.0 * theta / pi);
  }

  return(0);
}
