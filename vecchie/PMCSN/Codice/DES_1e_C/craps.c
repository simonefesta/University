/* ------------------------------------------------------------------------- * 
 * A Monte Carlo simulation of the dice game Craps.                          * 
 *                                                                           * 
 * Name              : craps.c                                               * 
 * Author            : Steve Park & Dave Geyer                               * 
 * Language          : ANSI C                                                * 
 * Latest Revision   : 9-16-95                                               * 
 * Compile with      : gcc craps.c rng.c                                     *
 * ------------------------------------------------------------------------- */

#include <stdio.h>
#include "rng.h"

#define N 10000L                           /* number of replications */

/* global variables */
long    i;                                 /* replication index    */
long    point;                             /* the initial roll     */
long    result;                            /* 0 = lose, 1 = win    */
long    wins = 0;                          /* number of wins       */
double  p;                                 /* probability estimate */

/* ============================== */
  long Equilikely(long a, long b)          /* use a < b */
/* ============================== */
{
  return(a + (long) ((b - a + 1) * Random()));
}

/* ============== */
  long Roll(void)
/* ============== */
{
  return(Equilikely(1, 6) + Equilikely(1, 6));
}

/* ==================== */                 /* roll until a 7 is obtained */
  long Play(long point)                    /*  - then return a 0         */
/* ==================== */                 /* or the point is made       */
{                                          /*  - then return a 1         */
  long sum;                                       
                                                 
  do {                                          
    sum = Roll();
  } while ((sum != point) && (sum != 7));
  return( (sum == point) ? 1 : 0 );
}

/* ============= */
  int main(void)
/* ============= */
{
  PutSeed(0);

  for (i = 0; i < N; i++) {                /* do N Monte Carlo replications */
    point = Roll();                              
    switch(point) {
      case  7:
      case 11:  result = 1;
                break;
      case  2:
      case  3:
      case 12:  result = 0;
                break;
      case  4:
      case  5:
      case  6:
      case  8:
      case  9:
      case 10:  result = Play(point);
                break;
    }
    wins += result;
  }

  p = (double) wins / (double) N;          /* estimate the probability */

  printf("\nfor %ld replications\n", N);
  printf("the estimated probability of winning is %5.3lf\n\n", p);

  return(0);
}
