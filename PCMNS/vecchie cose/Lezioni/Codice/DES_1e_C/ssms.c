/* -----------------------------------------------------------------------
 * This program - an extension of program ssq2 - simulates a single-server 
 * machine shop using Exponentially distributed failure times, Uniformly 
 * distributed service times, and a FIFO service queue.  
 *
 * Name            : ssms.c  (Single Server Machine Shop)
 * Authors         : Steve Park & Dave Geyer
 * Language        : ANSI C
 * Latest Revision : 9-28-98 
 * -----------------------------------------------------------------------
 */
 
#include <stdio.h>
#include <math.h>                                             
#include "rngs.h"

#define LAST    100000                  /* number of machine failures */
#define START   0.0                     /* initial time               */
#define M       60                      /* number of machines         */


   double Exponential(double m)            
/* ---------------------------------------------------
 * generate an Exponential random variate, use m > 0.0 
 * ---------------------------------------------------
 */
{                                       
  return (-m * log(1.0 - Random()));     
}


   double Uniform(double a, double b)       
/* --------------------------------------------
 * generate a Uniform random variate, use a < b 
 * --------------------------------------------
 */
{                                         
  return (a + (b - a) * Random());    
}


   double GetFailure(void)       
/* ------------------------------------------------ 
 * generate the operational time until next failure 
 * ------------------------------------------------
 */
{
  SelectStream(0);
  return (Exponential(100.0));
}


   double NextFailure(double failure[], int *m)
/* -----------------------------------------------------------------
 * return the next failure time, and the index of the failed machine
 * -----------------------------------------------------------------
 */
{
  int    i = 0;
  double t = failure[0];

  *m = i;
  for (i = 1; i < M; i++) 
    if (failure[i] < t) {
       t = failure[i];
      *m = i;
    }
  return (t);
}


   double GetService(void)
/* ------------------------------
 * generate the next service time
 * ------------------------------
 */ 
{
  SelectStream(1);
  return (Uniform(1.0, 2.0));
}

  int main(void)
{
  long   index     = 0;                    /* job (machine failure) index */
  double arrival   = START;                /* time of arrival (failure)   */
  double delay;                            /* delay in repair  queue      */
  double service;                          /* service (repair) time       */
  double wait;                             /* delay + service             */
  double departure = START;                /* time of service completion  */
  int    m;                                /* machine index 0,1,...(M-1)  */
  double failure[M];                       /* list of next failure times  */
  struct {                                 /* sum of ...            */
    double wait;                           /*   wait times          */
    double delay;                          /*   delay times         */
    double service;                        /*   service times       */
    double interarrival;                   /*   interarrival times  */
  } sum = {0.0, 0.0, 0.0};  

  PlantSeeds(123456789);

  for (m = 0; m < M; m++)                   /* initial failures */
    failure[m] = START + GetFailure();

  while (index < LAST) {
    index++;
    arrival      = NextFailure(failure, &m);
    if (arrival < departure)
      delay      = departure - arrival;  
    else
      delay      = 0.0; 
    service      = GetService();
    wait         = delay + service;
    departure    = arrival + wait;           /* completion of service  */
    failure[m]   = departure + GetFailure(); /* next failure, machine m */
    sum.wait    += wait;
    sum.delay   += delay;
    sum.service += service;
  }
  sum.interarrival = arrival - START;

  printf("\nfor a pool of %d machines ", M); 
  printf("and %ld simulated failures\n\n", index);
  printf("average interarrival time .. = %6.2f\n", sum.interarrival / index);
  printf("average wait ............... = %6.2f\n", sum.wait / index);
  printf("average delay .............. = %6.2f\n", sum.delay / index);
  printf("average service time ....... = %6.2f\n", sum.service / index);
  printf("average # in the node ...... = %6.2f\n", sum.wait / departure);
  printf("average # in the queue ..... = %6.2f\n", sum.delay / departure);
  printf("utilization ................ = %6.2f\n", sum.service / departure);

  return (0);
}
