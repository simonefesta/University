/* --------------------------------------------------------------------------  *
 * A Monte Carlo simulation of a stochastic activity network.                  *
 *                                                                             *
 * Name              : san.c                                                   *
 * Author            : Jeff Mallozzi, Kerry Connell, Larry Leemis, Matt Duggan *
 * Language          : ANSI C                                                  *
 * Latest Revision   : 6-16-04                                                 *
 * Compile with      : gcc -lm san.c rngs.c                                    *
------------------------------------------------------------------------------ */

#include <stdio.h>
#include <math.h>
#include <stdlib.h>
#include "rngs.h"

#define MAXEDGE  50
#define MAXNODE  50
#define MAXPATHS 50
#define N 10000L                           /* number of replications */

long   M[MAXNODE][MAXEDGE];
long   Paths[MAXPATHS][MAXNODE];
double UpperLimit[MAXEDGE];
double p[MAXEDGE];
long   paths;
long   nodes;
long   edges;

/* =========================== */
  double Uniform(double a, double b)          /* use a < b */
/* =========================== */
{
  return (a + (b - a) * Random());
}

/* ========================== */
  void GetActivityDurations()
/* ========================== */
{
  long i;

  for (i = 1; i <= edges; i++)
    p[i] = Uniform(0.0, UpperLimit[i]);

  return;
}

/* ================ */
  void PrintPaths()
/* ================ */
{
  long i;
  long j;

  printf("\n");
  for (i = 1; i <= paths; i++) {
    printf("Path %ld: ", i);
    j = 1;
    while(Paths[i][j] != 0) {
      j++;
    }
    j--;
    while(j > 0) {
      printf("-%ld-", Paths[i][j]);
      j--;
    }
    printf("\n");
  }

  return;
}

/* =============================== */
  double TimeToComplete(long node)
/* =============================== */
{
  long   k;
  long   l = 0;
  double tmax   = 0.0;
  double t  = 0.0;
  
  k = 1;
  while (l < M[node][0]) {
    if (M[node][k] == -1) {
      t = TimeToComplete(M[0][k]) + p[k];
      if (t >= tmax)
	tmax = t;
      l++;
    }
    k++;
  }
  return(tmax);
}

/* ============================================= */
  long GetPaths(long node, long step, long path)
/* ============================================= */
{
  long i = 1;
  long j;
  long found    = 0;
  long numpaths = 0;
  long total    = 0;
  
  while(found < M[node][0]) {
    if(M[node][i] == -1) {
      numpaths = GetPaths(M[0][i], step + 1, path + total);
      for (j = 0; j < numpaths; j++) {
	Paths[path + j + total][step] = i;
      }
      total += numpaths;
      found++;
    }
    i++;
  }

  if(total == 0) {
    Paths[path][step] = 0;
    total = 1;
  }

  return(total);
}

/* ============================================= */
  void EstimatePathProb()
/* ============================================= */
{
  long   i;
  long   j;
  long   k;
  long   maxpath;
  long   PathProb[MAXPATHS] = {0};
  double pathtime           = 0.0;
  double maxtime            = 0.0;
  
  for (i = 0; i < N; i++) {
    GetActivityDurations();

    for (j = 1; j <= paths; j++) {
      k = 1;
      while(Paths[j][k] != 0) {
	pathtime += p[Paths[j][k]];
	k++;
      }
      if(pathtime > maxtime) {
	maxtime = pathtime;
	maxpath = j;
      }
      pathtime = 0.0;
    }
    PathProb[maxpath]++;
    
    maxpath = 0;
    maxtime = 0.0;
  }

  printf("\nCritical path probabilities:\n");
  for (i = 1; i <= paths; i++)
    printf(" -  %2ld  - ", i);
  printf("\n");
  for (i = 1; i <= paths; i++)
    printf(" %1.6f ", (double) PathProb[i]/N);
  printf("\n");

  return;
}

/* =================== */
  void DefineNetwork()
/* =================== */
{
  long j;
  long k;

  edges = 9;
  nodes = 6;

  for (j = 0; j <= nodes; j++) {
    for (k = 0; k <= edges; k++) {
      M[j][k] = 0;
    }
  }
  M[1][1] = 1;
  M[2][1] = -1;
  M[1][2] = 1;
  M[3][2] = -1;
  M[1][3] = 1;
  M[4][3] = -1;
  M[2][4] = 1;
  M[3][4] = -1;
  M[2][5] = 1;
  M[5][5] = -1;
  M[3][6] = 1;
  M[4][6] = -1;
  M[3][7] = 1;
  M[6][7] = -1;
  M[4][8] = 1;
  M[6][8] = -1;
  M[5][9] = 1;
  M[6][9] = -1;

  for (j = 1; j <= nodes; j++) {
    for (k = 1; k <= edges; k++) {
      if(M[j][k] == -1) {
	M[j][0]++;
      }
      else if(M[j][k] == 1) {
	M[0][k] = j;
      }
    }
  }

  UpperLimit[1] = 3.0;
  UpperLimit[2] = 6.0;
  UpperLimit[3] = 13.0;
  UpperLimit[4] = 9.0;
  UpperLimit[5] = 3.0;
  UpperLimit[6] = 9.0;
  UpperLimit[7] = 7.0;
  UpperLimit[8] = 6.0;
  UpperLimit[9] = 3.0;

  paths = GetPaths(nodes, 1, 1);

  printf("Network read in:\n");
  printf("%ld edges.\n", edges);
  printf("%ld nodes.\n", nodes);
  printf("%ld paths.\n", paths);

  return;
}

/* ============================ */
  void EstimateCompletionTime()
/* ============================ */
{
  long   node;
  long   i;
  double time;
  double sumtime = 0.0;
  
  node = nodes; 

  for (i = 0; i < N; i++) {
    GetActivityDurations();
    time = TimeToComplete(node);
    sumtime += time; 
  }

  printf("\nFor %ld replications,", N);
  printf("\nthe estimated average time to complete the network is:\n"); 
  printf("%11.5f\n", sumtime / (double) N);

  return;
}
  
/* ============= */
  int main(void)
/* ============= */
{
  DefineNetwork();
  PrintPaths();
  PutSeed(0);
  EstimateCompletionTime();
  PutSeed(0);
  EstimatePathProb();
  return(0);
}
