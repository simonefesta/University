/* ------------------------------------------------------------------------- 
 * This program - an extension of program sis1.c - simulates a simple (s,S) 
 * inventory system using Equilikely distributed demands. 
 * 
 * Name              : sis2.c  (Simple Inventory System, version 2)
 * Authors           : Steve Park & Dave Geyer 
 * Language          : ANSI C 
 * Latest Revision   : 8-28-97 
 * ------------------------------------------------------------------------- 
 */

#include <stdio.h>
#include "rng.h"

#define MINIMUM  20                        /* 's' inventory policy parameter */
#define MAXIMUM  80                        /* 'S' inventory policy parameter */
#define STOP     100                       /* number of time intervals       */
#define sqr(x)   ((x) * (x))


   long Equilikely(long a, long b)          
/* ------------------------------------------------
 * generate an Equilikely random variate, use a < b 
 * ------------------------------------------------
 */
{
  return (a + (long) ((b - a + 1) * Random()));
}


   long GetDemand(void)                 
/* ------------------------
 * generate the next demand
 * ------------------------
 */
{                                             
  return (Equilikely(10, 50)); 
}


  int main(void)
{
  long index     = 0;                      /* time interval index     */
  long inventory = MAXIMUM;                /* current inventory level */
  long demand;                             /* amount of demand        */
  long order;                              /* amount of order         */
  struct {                                 /* sum of ...              */
    double setup;                          /*   setup instances       */
    double holding;                        /*   inventory held (+)    */
    double shortage;                       /*   inventory short (-)   */
    double order;                          /*   orders                */
    double demand;                         /*   demands               */
  } sum = {0.0, 0.0, 0.0, 0.0, 0.0}; 

  PutSeed(123456789);

  while (index < STOP) {
    index++;
    if (inventory < MINIMUM) {             /* place an order */
      order         = MAXIMUM - inventory;
      sum.setup++;
      sum.order    += order;
    }
    else                                   /* no order       */
      order         = 0;
    inventory      += order;               /* there is no delivery lag */
    demand          = GetDemand();
    sum.demand     += demand;
    if (inventory > demand)
      sum.holding  += (inventory - 0.5 * demand);
    else {
      sum.holding  += sqr(inventory) / (2.0 * demand);
      sum.shortage += sqr(demand - inventory) / (2.0 * demand);
    }
    inventory     -= demand;
  } 

  if (inventory < MAXIMUM) {               /* force the final inventory to */
    order      = MAXIMUM - inventory;      /* match the initial inventory  */
    sum.setup++;
    sum.order += order;
    inventory += order;
  }

  printf("\nfor %ld time intervals ", index);
  printf("with an average demand of %6.2f\n", sum.demand / index);
  printf("and policy parameters (s, S) = (%d, %d)\n\n", MINIMUM, MAXIMUM);
  printf("   average order ............ = %6.2f\n", sum.order / index);
  printf("   setup frequency .......... = %6.2f\n", sum.setup / index);
  printf("   average holding level .... = %6.2f\n", sum.holding / index);
  printf("   average shortage level ... = %6.2f\n", sum.shortage / index);

  return (0);
}
