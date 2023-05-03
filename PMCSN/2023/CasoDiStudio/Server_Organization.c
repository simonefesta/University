#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include "rngs.h"                      /* the multi-stream generator     */
#include "rvgs.h"

#define DEBUG           1              /* When set to 0, prints on the   */
                                       /* terminal are disabled          */
#define START         0.0              /* initial time                   */
#define STOP      20000.0              /* terminal (close the door) time */
#define INFINITY   (100.0 * STOP)      /* must be much larger than STOP  */

double lambda = 4.0;
double mu = 1.5;
int servers_num = 4;
int k = 3; //K-Erlang's phases number
double alpha = 2.15; //Pareto's alpha
int service_distribution = 1; //1 = k-Erlang, 2 = Exponential, 3 = Pareto

int distributions = 5;
int organizations = 3;

double arrival = START;


double Min(double a, double c){ 
  if (a < c){
    return (a);
  }
  else{
    return (c);
  } 
}

double GetArrival(double lambda){
  SelectStream(0);

  arrival += Exponential(1/lambda);
  return (arrival);
} 

/*double GetService(double mu){
  SelectStream(1);

  return (Exponential(1/mu));
}*/

/* 
   Per avere la stessa media dell'esponenziale, la Pareto deve avere k=(a-1)/(a*mu).
   Per avere momento del secondo ordine finito, deve essere inoltre a>2.
*/
double GetService(double avg_service_rate){
  SelectStream(1);

  double new_service;

  switch(service_distribution){
    case 1:
      new_service = Erlang(k, 1/(k*avg_service_rate));
      break;
    case 2:
      new_service = Exponential(1/avg_service_rate);
      break;
    case 3:
      new_service = Pareto(alpha, (alpha-1)/(alpha*avg_service_rate));
      break;
    default:
      printf("Invalid service distribution\n");
      exit(0);
      break;
  }

  return new_service;
}

typedef struct {
  double arrival;                 /* next arrival time                   */
  double completion;              /* next completion time                */
  double current;                 /* current time                        */
  double next;                    /* next (most imminent) event time     */
  double last;                    /* last arrival time                   */
} time;

typedef struct {
  double node;                    /* time integrated number in the node  */
  double queue;                   /* time integrated number in the queue */
  double service;                 /* time integrated number in service   */
} sys_status;

typedef struct {                        /* the next-event list    */
  double t;                             /*   next event time      */
  int    x;                             /*   event status, 0 or 1 */
} next_event;

typedef struct {
  int jobs;
  double interarrival;
  double wait;
  double delay;
  double service;
  double Ns;
  double Nq;
  double utilization;
} analysis;

int NextEvent(next_event *events){
  int e;                                      
  int i = 0;

  while (events[i].x == 0){      /* find the index of the first 'active' */
    i++;                        /* element in the event list            */ 
  }       
  e = i;

  while (i < servers_num) {         /* now, check the others to find which  */
    i++;                        /* event type is most imminent          */
    if ((events[i].x == 1) && (events[i].t < events[e].t))
      e = i;
  }

  return (e);
}

int FindOne(next_event *event)
/* -----------------------------------------------------
 * return the index of the available server idle longest
 * -----------------------------------------------------
 */
{
  int s;
  int i = 1;

  while (event[i].x == 1)       /* find the index of the first available */
    i++;                        /* (idle) server                         */
  s = i;
  while (i < servers_num) {     /* now, check the others to find which   */ 
    i++;                        /* has been idle longest                 */
    if ((event[i].x == 0) && (event[i].t < event[s].t))
      s = i;
  }
  return (s);
}

void server_organization_1(int seed, analysis *result){
  long index  = 0;                  /* used to count departed jobs         */
  long number = 0;                  /* number in the node                  */
  time t;
  sys_status area = {0.0, 0.0, 0.0};

  PlantSeeds(seed);
  t.current    = START;                               /* set the clock                         */
  t.arrival    = GetArrival(lambda / servers_num);    /* schedule the first arrival            */
  t.completion = INFINITY;                            /* the first event can't be a completion */

  while ((t.arrival < STOP) || (number > 0)) {
    t.next = Min(t.arrival, t.completion);            /* next event time   */
    if (number > 0) {                                 /* update integrals  */
      area.node    += (t.next - t.current) * number;
      area.queue   += (t.next - t.current) * (number - 1);
      area.service += (t.next - t.current);
    }
    t.current       = t.next;                    /* advance the clock */

    if (t.current == t.arrival)  {               /* process an arrival */
      number++;
      t.arrival     = GetArrival(lambda / servers_num);
      if (t.arrival > STOP)  {
        t.last      = t.current;
        t.arrival   = INFINITY;
      }
      if (number == 1)
        t.completion = t.current + GetService(mu);
    }

    else {                                        /* process a completion */
      index++;
      number--;
      if (number > 0)
        t.completion = t.current + GetService(mu);
      else
        t.completion = INFINITY;
    }
  } 

  result->jobs = index;
  result->interarrival = t.last / index;
  result->wait = area.node / index;
  result->delay = area.queue / index;
  result->service = area.service / index;
  result->Ns = area.node / t.current;
  result->Nq = area.queue / t.current;
  result->utilization = area.service / t.current;

  if(DEBUG){
    printf("\nfor %ld jobs the service node statistics are:\n\n", result->jobs);
    printf("   average interarrival time = %lf\n", result->interarrival);
    printf("   average wait ............ = %lf\n", result->wait);
    printf("   average delay ........... = %lf\n", result->delay);
    printf("   average service time .... = %lf\n", result->service);
    printf("   average # in the node ... = %lf\n", result->Ns);
    printf("   average # in the queue .. = %lf\n", result->Nq);
    printf("   utilization ............. = %lf\n\n\n", result->utilization);
  }
  
  arrival = START;
}

void servers_organization_2(int seed, analysis *result){
  time t;
  next_event event[servers_num + 1];
  long       number = 0;             /* number in the node                 */
  int        e;                      /* next event index                   */
  int        s;                      /* server index                       */
  long       index  = 0;             /* used to count processed jobs       */
  double     area   = 0.0;           /* time integrated number in the node */
  double delay_area = 0.0;
  struct {                           /* accumulated sums of                */
    double service;                  /*   service times                    */
    long   served;                   /*   number served                    */
  } sum[servers_num + 1];

  PlantSeeds(seed);
  t.current    = START;
  event[0].t   = GetArrival(lambda);
  event[0].x   = 1;
  for (s = 1; s <= servers_num; s++) {
    event[s].t     = START;          /* this value is arbitrary because */
    event[s].x     = 0;              /* all servers are initially idle  */
    sum[s].service = 0.0;
    sum[s].served  = 0;
  }

  while ((event[0].x != 0) || (number != 0)) {
    e         = NextEvent(event);                  /* next event index */
    t.next    = event[e].t;                        /* next event time  */
    area     += (t.next - t.current) * number;     /* update integral  */
    t.current = t.next;                            /* advance the clock*/

    if (e == 0) {                                  /* process an arrival*/
      number++;
      event[0].t        = GetArrival(lambda);
      if (event[0].t > STOP)
        event[0].x      = 0;
      if (number <= servers_num) {
        double service  = GetService(mu);
        s               = FindOne(event);
        sum[s].service += service;
        sum[s].served++;
        event[s].t      = t.current + service;
        event[s].x      = 1;
      }
    }
    else {                                         /* process a departure */
      index++;                                     /* from server s       */  
      number--;
      s                 = e;                       
      if (number >= servers_num) {
        double service   = GetService(mu);
        sum[s].service += service;
        sum[s].served++;
        event[s].t      = t.current + service;
      }
      else
        event[s].x      = 0;
    }
  }

  delay_area = area;
  double total_service = 0;
  double total_served = 0;
  for (s = 1; s <= servers_num; s++){           /* adjust area to calculate */ 
    delay_area -= sum[s].service;               /* averages for the queue   */
    total_service += sum[s].service;
    total_served += sum[s].served;
  }

  result->jobs = index;
  result->interarrival = event[0].t / index;
  result->wait = area / index;
  result->delay = delay_area / index;
  result->service = total_service / total_served;
  result->Ns = area / t.current;
  result->Nq = delay_area / t.current;
  result->utilization = (total_service / servers_num) / t.current;

  if(DEBUG){
    printf("\nfor %ld jobs the service node statistics are:\n\n", result->jobs);
    printf("   average interarrival time = %lf\n", result->interarrival);
    printf("   average wait ............ = %lf\n", result->wait);
    printf("   average delay ........... = %lf\n", result->delay);
    printf("   average service time .... = %lf\n", result->service);
    //printf("   average service time .... = %lf\n", (area - delay_area) / index);
    printf("   average # in the node ... = %lf\n", result->Ns);
    printf("   average # in the queue .. = %lf\n", result->Nq);
    printf("   utilization ............. = %lf\n\n\n", result->utilization);

    printf("\nthe server statistics are:\n\n");
    printf("    server     utilization     avg service        share\n");
    for (s = 1; s <= servers_num; s++){
      printf("%8d %16lf %15lf %14lf\n", s, sum[s].service / t.current, sum[s].service / sum[s].served, (double) sum[s].served / index);
    }
    printf("\n");
  }

  arrival = START;
}

void server_organization_3(int seed, analysis *result){
  long index  = 0;                  /* used to count departed jobs         */
  long number = 0;                  /* number in the node                  */
  time t;
  sys_status area = {0.0, 0.0, 0.0};

  PlantSeeds(seed);
  t.current    = START;                 /* set the clock                         */
  t.arrival    = GetArrival(lambda);    /* schedule the first arrival            */
  t.completion = INFINITY;              /* the first event can't be a completion */

  while ((t.arrival < STOP) || (number > 0)) {
    t.next = Min(t.arrival, t.completion);            /* next event time   */
    if (number > 0) {                                 /* update integrals  */
      area.node    += (t.next - t.current) * number;
      area.queue   += (t.next - t.current) * (number - 1);
      area.service += (t.next - t.current);
    }
    t.current       = t.next;                    /* advance the clock */

    if (t.current == t.arrival)  {               /* process an arrival */
      number++;
      t.arrival     = GetArrival(lambda);
      if (t.arrival > STOP)  {
        t.last      = t.current;
        t.arrival   = INFINITY;
      }
      if (number == 1)
        t.completion = t.current + GetService(servers_num * mu);
    }

    else {                                        /* process a completion */
      index++;
      number--;
      if (number > 0)
        t.completion = t.current + GetService(servers_num * mu);
      else
        t.completion = INFINITY;
    }
  }

  result->jobs = index;
  result->interarrival = t.last / index;
  result->wait = area.node / index;
  result->delay = area.queue / index;
  result->service = area.service / index;
  result->Ns = area.node / t.current;
  result->Nq = area.queue / t.current;
  result->utilization = area.service / t.current;

  if(DEBUG){
    printf("\nfor %ld jobs the service node statistics are:\n\n", result->jobs);
    printf("   average interarrival time = %lf\n", result->interarrival);
    printf("   average wait ............ = %lf\n", result->wait);
    printf("   average delay ........... = %lf\n", result->delay);
    printf("   average service time .... = %lf\n", result->service);
    printf("   average # in the node ... = %lf\n", result->Ns);
    printf("   average # in the queue .. = %lf\n", result->Nq);
    printf("   utilization ............. = %lf\n\n\n", result->utilization);
  }

  arrival = START;
}

int main(void){
  analysis results[distributions][organizations];

  for(int i=0; i<distributions; i++){
    if(DEBUG) printf("-------------------- SERVER ORGANIZATION 1 --------------------\n");
    server_organization_1(13, &results[i][0]);

    if(DEBUG) printf("-------------------- SERVER ORGANIZATION 2 --------------------\n");
    servers_organization_2(13, &results[i][1]);

    if(DEBUG) printf("-------------------- SERVER ORGANIZATION 3 --------------------\n");
    server_organization_3(13, &results[i][2]);

    if(service_distribution < 3){
      service_distribution++;
    }
    else if(i < distributions-1){
      alpha -= 0.05;
    }
  }

  FILE *fpt;
  int i;
  fpt = fopen("Comparison.csv", "w");
  fprintf(fpt,"Interarrival; Server Organization 1; Server Organization 2; Server Organization 3;\n");
  fprintf(fpt,"K-Erlang; %lf; %lf; %lf;\n", results[0][0].interarrival, results[0][1].interarrival, results[0][2].interarrival);
  fprintf(fpt,"Exponential; %lf; %lf; %lf;\n", results[1][0].interarrival, results[1][1].interarrival, results[1][2].interarrival);
  fprintf(fpt,"Pareto (2.15); %lf; %lf; %lf;\n", results[2][0].interarrival, results[2][1].interarrival, results[2][2].interarrival);
  fprintf(fpt,"Pareto (2.10); %lf; %lf; %lf;\n", results[3][0].interarrival, results[3][1].interarrival, results[3][2].interarrival);
  fprintf(fpt,"Pareto (2.05); %lf; %lf; %lf;\n", results[4][0].interarrival, results[4][1].interarrival, results[4][2].interarrival);

  fprintf(fpt,"Response Time; Server Organization 1; Server Organization 2; Server Organization 3;\n");
  fprintf(fpt,"K-Erlang; %lf; %lf; %lf;\n", results[0][0].wait, results[0][1].wait, results[0][2].wait);
  fprintf(fpt,"Exponential; %lf; %lf; %lf;\n", results[1][0].wait, results[1][1].wait, results[1][2].wait);
  fprintf(fpt,"Pareto (2.15); %lf; %lf; %lf;\n", results[2][0].wait, results[2][1].wait, results[2][2].wait);
  fprintf(fpt,"Pareto (2.10); %lf; %lf; %lf;\n", results[3][0].wait, results[3][1].wait, results[3][2].wait);
  fprintf(fpt,"Pareto (2.05); %lf; %lf; %lf;\n", results[4][0].wait, results[4][1].wait, results[4][2].wait);
  
  fprintf(fpt,"Queue Delay; Server Organization 1; Server Organization 2; Server Organization 3;\n");
  fprintf(fpt,"K-Erlang; %lf; %lf; %lf;\n", results[0][0].delay, results[0][1].delay, results[0][2].delay);
  fprintf(fpt,"Exponential; %lf; %lf; %lf;\n", results[1][0].delay, results[1][1].delay, results[1][2].delay);
  fprintf(fpt,"Pareto (2.15); %lf; %lf; %lf;\n", results[2][0].delay, results[2][1].delay, results[2][2].delay);
  fprintf(fpt,"Pareto (2.10); %lf; %lf; %lf;\n", results[3][0].delay, results[3][1].delay, results[3][2].delay);
  fprintf(fpt,"Pareto (2.05); %lf; %lf; %lf;\n", results[4][0].delay, results[4][1].delay, results[4][2].delay);

  fprintf(fpt,"Service Time; Server Organization 1; Server Organization 2; Server Organization 3;\n");
  fprintf(fpt,"K-Erlang; %lf; %lf; %lf;\n", results[0][0].service, results[0][1].service, results[0][2].service);
  fprintf(fpt,"Exponential; %lf; %lf; %lf;\n", results[1][0].service, results[1][1].service, results[1][2].service);
  fprintf(fpt,"Pareto (2.15); %lf; %lf; %lf;\n", results[2][0].service, results[2][1].service, results[2][2].service);
  fprintf(fpt,"Pareto (2.10); %lf; %lf; %lf;\n", results[3][0].service, results[3][1].service, results[3][2].service);
  fprintf(fpt,"Pareto (2.05); %lf; %lf; %lf;\n", results[4][0].service, results[4][1].service, results[4][2].service);

  fprintf(fpt,"Node Jobs; Server Organization 1; Server Organization 2; Server Organization 3;\n");
  fprintf(fpt,"K-Erlang; %lf; %lf; %lf;\n", results[0][0].Ns, results[0][1].Ns, results[0][2].Ns);
  fprintf(fpt,"Exponential; %lf; %lf; %lf;\n", results[1][0].Ns, results[1][1].Ns, results[1][2].Ns);
  fprintf(fpt,"Pareto (2.15); %lf; %lf; %lf;\n", results[2][0].Ns, results[2][1].Ns, results[2][2].Ns);
  fprintf(fpt,"Pareto (2.10); %lf; %lf; %lf;\n", results[3][0].Ns, results[3][1].Ns, results[3][2].Ns);
  fprintf(fpt,"Pareto (2.05); %lf; %lf; %lf;\n", results[4][0].Ns, results[4][1].Ns, results[4][2].Ns);

  fprintf(fpt,"Queue Jobs; Server Organization 1; Server Organization 2; Server Organization 3;\n");
  fprintf(fpt,"K-Erlang; %lf; %lf; %lf;\n", results[0][0].Nq, results[0][1].Nq, results[0][2].Nq);
  fprintf(fpt,"Exponential; %lf; %lf; %lf;\n", results[1][0].Nq, results[1][1].Nq, results[1][2].Nq);
  fprintf(fpt,"Pareto (2.15); %lf; %lf; %lf;\n", results[2][0].Nq, results[2][1].Nq, results[2][2].Nq);
  fprintf(fpt,"Pareto (2.10); %lf; %lf; %lf;\n", results[3][0].Nq, results[3][1].Nq, results[3][2].Nq);
  fprintf(fpt,"Pareto (2.05); %lf; %lf; %lf;\n", results[4][0].Nq, results[4][1].Nq, results[4][2].Nq);

  fprintf(fpt,"Utilizzation; Server Organization 1; Server Organization 2; Server Organization 3;\n");
  fprintf(fpt,"K-Erlang; %lf; %lf; %lf;\n", results[0][0].utilization, results[0][1].utilization, results[0][2].utilization);
  fprintf(fpt,"Exponential; %lf; %lf; %lf;\n", results[1][0].utilization, results[1][1].utilization, results[1][2].utilization);
  fprintf(fpt,"Pareto (2.15); %lf; %lf; %lf;\n", results[2][0].utilization, results[2][1].utilization, results[2][2].utilization);
  fprintf(fpt,"Pareto (2.10); %lf; %lf; %lf;\n", results[3][0].utilization, results[3][1].utilization, results[3][2].utilization);
  fprintf(fpt,"Pareto (2.05); %lf; %lf; %lf;\n", results[4][0].utilization, results[4][1].utilization, results[4][2].utilization);

  return (0);
}
