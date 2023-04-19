/* ---------------------------------------------------------------------- *
 * A Monte Carlo simulation to estimate the probability that the          *
 * determinant of a 3 by 3 matrix of random numbers is positive.          * 
 *                                                                        *
 * Name              : det.c                                              *
 * Author            : Larry Leemis                                       *
 * Language          : ANSI C                             
 * Latest Revision   : 8-8-02                                             *
 * Compile with      : gcc det.c rng.c                                    *
 *                     if math functions needed, add #include <math.h>    *
 *                     and compile with gcc -lm det.c rng.c               *
 * ---------------------------------------------------------------------- */

#include <stdio.h>
#include "rng.h"

#define N 200000000L                     /* number of replications        */

/* ============= */
  int main(void)
/* ============= */
{
  int    i;                              /* replication index             */
  int    j;                              /* row index                     */
  int    k;                              /* column index                  */
  double a[4][4];                        /* matrix (only 9 elements used) */
  double temp1;                          /* first 2 by 2 determinant      */
  double temp2;                          /* second 2 by 2 determinant     */
  double temp3;                          /* third 2 by 2 determinant      */
  double x;                              /* determinant                   */
  int    count = 0;                      /* counts number of pos det      */
  
  PutSeed(0);

  for (i = 0; i < N; i++) {
    for (j = 1; j <= 3; j++) {
      for (k = 1; k <= 3; k++) {
        a[j][k] = Random();
        if (j != k)
          a[j][k] = -a[j][k];
      }
    }
    temp1 = a[2][2] * a[3][3] - a[3][2] * a[2][3];
    temp2 = a[2][1] * a[3][3] - a[3][1] * a[2][3];
    temp3 = a[2][1] * a[3][2] - a[3][1] * a[2][2];
    x = a[1][1] * temp1 - a[1][2] * temp2 + a[1][3] * temp3;
    if (x > 0)
      count++;
  }

  printf("\nbased on %ld replications ", N);
  printf("the estimated probability of a positive determinant is:\n");
  printf("%11.9f", (double) count / N);
  printf("\n");

  return (0);
}
