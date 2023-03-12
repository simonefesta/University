/* -------------------------------------------------------------------------  
 * This program is a next-event simulation of a simple inventory system with 
 * a Poisson/Geometric demand model where the demand instances are generated
 * as a Poisson process and at each demand instance the demand amount is a
 * Geometric random variate.  Backlogging is possible and when inventory is
 * ordered there is aa Uniform(0,1) delivery lag. 
 *
 * Name              : sis4.c  (Simple Inventory System, version 4) 
 * Author            : Steve Park & Dave Geyer 
 * Language          : ANSI C 
 * Latest Revision   : 10-21-97 
 * ------------------------------------------------------------------------- 
 */

#include <stdio.h>
#include <math.h>
#include "rngs.h"
#include "rvgs.h"

#define MINIMUM    20             /* 's' inventory policy parameter >= 0 */
#define MAXIMUM    80             /* 'S' inventory policy parameter > s  */
#define START      0.0
#define STOP       100.0
#define INFINITY   (100.0 * STOP)
 

   double GetDemand(long *amount)
/* ------------------------------------------
 * generate a demand instance with rate 120
 * and generate a corresponding demand amount
 * ------------------------------------------
 */
{             
  static double time = START;
                            
  SelectStream(0);
  time += Exponential(1.0 / 120.0);      /* demand instance */
  SelectStream(2);
  *amount = Geometric(0.2);              /* demand amount   */
  return (time);
}


   double GetLag(void)
/* ----------------------- 
 * generate a delivery lag
 * -----------------------
*/
{                                         
  SelectStream(1);
  return (Uniform(0.0, 1.0));
}


   double Min(double a, double b, double c)    
/* ----------------------------------------
 * return the minimum of a, b, c
 * ----------------------------------------
 */
{
  double t = a;

  if (b < t)
    t = b;
  if (c < t)
    t = c;
  return (t);
}

   int main(void)
{
  long inventory = MAXIMUM;            /* current inventory level      */
  long order     = 0;                  /* current order level          */
  struct {
    double demand;                     /* next demand time                */
    double review;                     /* next inventory review time      */
    double arrive;                     /* next order arrival time         */
    double current;                    /* current time                    */
    double next;                       /* next (most imminent) event time */
  } t;
  struct {                             /* sum of -                */
    double setup;                      /*   setup instances       */
    double holding;                    /*   inventory held (+)    */
    double shortage;                   /*   inventory short (-)   */
    double order;                      /*   orders                */
    double demand;                     /*   demands               */
    double lag;                        /*   lags                  */
  } sum          = {0.0, 0.0, 0.0, 0.0, 0.0, 0.0};
  long amount;                         /* amount of (scheduled) demand */

  PlantSeeds(0);
  t.current = START;
  t.demand  = GetDemand(&amount);       /* schedule the first demand */
  t.review  = t.current + 1.0;          /* schedule the first review */
  t.arrive  = INFINITY;                 /* no order arrival pending  */

  while (t.current < STOP) {
    t.next          = Min(t.demand, t.review, t.arrive);
    if (inventory > 0)
      sum.holding  += (t.next - t.current) * inventory;
    else
      sum.shortage -= (t.next - t.current) * inventory;
    t.current       = t.next;

    if (t.current == t.demand) {        /* process an inventory demand */
      sum.demand += amount;
      inventory  -= amount;
      t.demand    = GetDemand(&amount);
    }

    else if (t.current == t.review) {   /* process inventory review */
      if (inventory < MINIMUM) {
        double lag;
        order      = MAXIMUM - inventory;
        lag        = GetLag();
        sum.setup++;
        sum.order += order;
        sum.lag   += lag;
        t.arrive   = t.current + lag;
      }
      t.review  = t.current + 1.0;
    }

    else {                           /* process an inventory order arrival*/
      inventory += order;
      order      = 0;
      t.arrive   = INFINITY;
    }
  } 

  if (inventory < MAXIMUM) {          /* adjust the final inventory level */
    order      = MAXIMUM - inventory;
    sum.setup++;
    sum.order += order;
    inventory += order;
  }

  printf("\nfor %ld time intervals ", (long) STOP);
  printf("with an average demand of %6.2f\n", sum.demand / STOP);
  if (sum.setup > 0.0)
    printf("an average lag of %4.2f", sum.lag / sum.setup);
  printf(" and policy parameters (s, S) = (%d, %d)\n\n", MINIMUM, MAXIMUM);
  printf("   average order ............ = %6.2f\n", sum.order / STOP);
  printf("   setup frequency .......... = %6.2f\n", sum.setup / STOP);
  printf("   average holding level .... = %6.2f\n", sum.holding / STOP);
  printf("   average shortage level ... = %6.2f\n\n", sum.shortage / STOP);

  return (0);
}
