/* ------------------------------------------------------------------------- 
 * This program is a next-event simulation of a multi-user time-sharing
 * system.  All users begin with the thinking task and the simulation ends 
 * when the simulation clock time meets or exceeds the terminal time STOP.
 * 
 * Name              : ttr.c (Think-Type-Receive)
 * Author            : Larry Leemis 
 * Language          : ANSI C 
 * Latest Revision   : 10-12-04 
 * Compile with      : gcc -lm ttr.c rngs.c 
 * ------------------------------------------------------------------------- 
 */

#include <stdio.h>
#include <math.h>
#include "rngs.h"

#define START    0.0                    /* initial simulation clock time  */
#define STOP     100.0                  /* terminal time                  */
#define N        5                      /* number of servers              */

   long Equilikely(long a, long b)
/* ===================================================================
 * Returns an equilikely distributed integer between a and b inclusive. 
 * NOTE: use a < b
 * ===================================================================
 */
{
  return (a + (long) ((b - a + 1) * Random()));
}

   double Uniform(double a, double b)
/* =========================================================== 
 * Returns a uniformly distributed real number between a and b. 
 * NOTE: use a < b
 * ===========================================================
 */
{ 
  return (a + (b - a) * Random());
}
   

   double GetThinkTime(void)
/* ----------------------------
 * generate the next think time 
 * ----------------------------
 */ 
{     
  SelectStream(0);
  return (Uniform(0.0, 10.0));
}

   
   double GetKeystrokeTime(void)
/* -------------------------------
 * generate the next keystroke time 
 * -------------------------------
 */ 
{     
  SelectStream(1);
  return (Uniform(0.15, 0.35));
}

   
   long GetNumKeystrokes(void)
/* ---------------------------------
 * generate the number of keystrokes 
 * ---------------------------------
 */ 
{     
  SelectStream(2);
  return (Equilikely(5, 15));
}

   
   long GetNumCharacters(void)
/* ---------------------------------
 * generate the number of characters 
 * ---------------------------------
 */ 
{     
  SelectStream(3);
  return (Equilikely(50, 300));
}

  int main(void)
{
  int i;                             /* loop parameter                         */
  int j;                             /* index for the next event               */
  long nevents = 0;                  /* number of events during the simulation */
  long nsearches = 0;                /* number of event list searches          */
  double tnow;                       /* simulation clock                       */
  double temp;                       /* used to find time of next event        */
  double ReceiveRate = 1.0 / 120.0;  /* time to transmit a character           */
  struct {
    double time;                     /* event time                             */
    int    type;                     /* event type                             */
    int    info;                     /* ancillary information                  */
  } event[N];

  PlantSeeds(0);
  tnow = START;
  for (i = 0; i < N; i++) {
    event[i].time = GetThinkTime();
    event[i].type = 1;
    event[i].info = 0;
  }

  while (tnow < STOP) { 
    nevents++;
    temp = 100.0 * STOP;
    for (i = 0; i < N; i++) {
      nsearches++;
      if (event[i].time <= temp) {
        temp = event[i].time;
        j = i;
      }
    }
    tnow = event[j].time;   
    if (event[j].type == 1) {           /* complete thinking event  */
      event[j].time = tnow + GetKeystrokeTime();
      event[j].type = 2;
      event[j].info = GetNumKeystrokes();
    }
    else if (event[j].type == 2) {      /* complete keystroke event */
      event[j].info--; 
      if (event[j].info > 0) {
        event[j].time = tnow + GetKeystrokeTime();
      }
      else {                            /* last keystroke           */
        event[j].time = tnow + ReceiveRate; 
        event[j].type = 3;
        event[j].info = GetNumCharacters();
      }
    }
    else if (event[j].type == 3) {      /* complete character recpt */
      event[j].info--; 
      if (event[j].info > 0) {
        event[j].time = tnow + ReceiveRate; 
      }
      else {                            /* last character           */
        event[j].time = tnow + GetThinkTime(); 
        event[j].type = 1;
        event[j].info = 0;
      }
    }
    else {
      printf("\nerror: event type must be 1, 2, or 3\n");  
    }
  } 

  printf("\nsimulation end time .... = %6.2f\n", tnow);
  printf("\nfinal status of the event list:\n");  
  for (i = 0; i < N; i++)
    printf("%8d %14.3f %8d %8d\n", i, event[i].time, event[i].type, event[i].info); 

  printf("\nnumber of events ....... = %ld\n", nevents);
  printf("\nnumber of searches ..... = %ld\n", nsearches);
  printf("\n");

  return (0);
}
