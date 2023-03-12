/* ---------------------------------------------------------------------- * 
 * A Monte Carlo simulation of the hat check girl problem.                *
 *                                                                        * 
 * Name              : hat.c                                              * 
 * Authors           : Steve Park & Dave Geyer                            * 
 * Language          : ANSI C                                             * 
 * Latest Revision   : 09-16-95                                           * 
 * Compile with      : gcc hat.c rng.c                                    *
 * ---------------------------------------------------------------------- */

#include <stdio.h>
#include "rng.h"

#define  SIZE  10                            /* array size                */
#define  N     10000L                        /* number of replications    */

typedef long permutation[SIZE];

/* global variables */
long         i;                              /* replication index         */
permutation  arr;                            /* array                     */
long         count = 0;                      /* # of times a match occurs */
double       p;                              /* probability estimate      */

/* =============================== */
  long Equilikely(long a, long b)            /* use a < b                 */
/* =============================== */
{
  return(a + (long) ((b - a + 1) * Random()));
}

/* ============================== */
  void Initialize(permutation a)
/* ============================== */
{
  int j;

  for(j = 0; j < SIZE; j++)
    a[j] = j;
}

/* =========================== */
  void Shuffle(permutation a)
/* =========================== */
{ 
  int j;
  int t;
  int hold;

  for(j = 0; j < (SIZE - 1); j++) {          /* shuffle an array         */
    t     = Equilikely(j, (SIZE - 1));       /* in such a way that all   */
    hold  = a[j];                            /* permutations are equally */
    a[j]  = a[t];                            /* likely to occur          */
    a[t]  = hold;
  }
}

/* ============================ */
  int Check(permutation a)
/* ============================ */
{ 
  int j    = 0;
  int test = 0;

  do {                                       /* test to see if at least */
    test = (a[j] == j);                      /* one element is in its   */
    j++;                                     /* 'natural' position      */
  } while ((j != SIZE) && !test);            /* - return a 1 if so      */
  return (test ? 1 : 0);                     /* - return a 0 otherwise  */
}

/* ============== */
  int main(void)
/* ============== */
{
  PutSeed(0);

  Initialize(arr);

  for(i = 0; i < N; i++) {                 /* do N Monte Carlo replications */
    Shuffle(arr);
    count += Check(arr);
  }

  p = (double) (N - count) / (double) N;   /* estimate the probability */

  printf("\nfor %ld replications and an array of size %d\n", N, SIZE);
  printf("the estimated probability is %5.3lf\n\n", p);

  return(0);
}
