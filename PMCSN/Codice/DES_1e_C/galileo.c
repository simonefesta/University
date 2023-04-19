/* ------------------------------------------------------------------------- 
 * A Monte Carlo simulation of Galileo's three dice experiment. 
 * 
 * Name              : galileo.c 
 * Author            : Steve Park & Dave Geyer 
 * Language          : ANSI C
 * Latest Revision   : 9-11-98
 * ------------------------------------------------------------------------- 
 */

#include <stdio.h>
#include "rng.h"

#define N 10000L                          /* number of replications */


   long Equilikely(long a, long b)        
/* ------------------------------------------------
 * generate an Equilikely random variate, use a < b 
 * ------------------------------------------------
 */
{
  return (a + (long) ((b - a + 1) * Random()));
}


  int main(void)
{
  long   i;                               /* replication index      */
  long   x;                               /* sum of three dice      */
  long   count[19] = {0};                 /* histogram              */
  double p[19]     = {0.0};               /* probability estimates  */

  PutSeed(0);

  for (i = 0; i < N; i++) {
    x = Equilikely(1, 6) + Equilikely(1, 6) + Equilikely(1, 6);
    count[x]++;
  }

  for (x = 3; x < 19; x++)                /* estimate probabilities */
    p[x] = (double) count[x] / N;

  printf("\nbased on %ld replications ", N);
  printf("the estimated probabilities are:\n\n");
  for (x = 3; x < 19; x++)
    printf("p[%2ld] = %5.3f\n", x, p[x]);
  printf("\n");

  return (0);
}
