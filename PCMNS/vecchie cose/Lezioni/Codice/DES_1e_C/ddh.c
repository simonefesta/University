/* ------------------------------------------------------------------------- 
 * This program illustrates a linked-list algorithm for tallying a 
 * discrete-data histogram for data read from standard input (stdin).   
 * Like program uvs, a compiled version of this program supports file 
 * redirection. 
 * 
 * NOTE: if the data is not discrete, i.e., virtually all inputs are likely 
 * to be unique, and if the number of inputs is large (say 10,000 or more)
 * then this program will execute for a LOOOONG time!
 *
 * Name            : ddh.c  (Discrete Data Histogram)
 * Authors         : Steve Park & Dave Geyer
 * Language        : ANSI C
 * Latest Revision : 10-05-98
 * ------------------------------------------------------------------------- 
 */

#include <stdio.h>                                   
#include <math.h>                                       
#include <stdlib.h>                                     

struct node {
  double value;
  long   count;
  struct node *next;
};

typedef struct node *pointer;


   void Initialize(pointer *p, double data)      
/* ---------------------------------------- 
 * initialize a new list node 
 * ----------------------------------------
 */
{
  *p = malloc(sizeof(struct node));

  (*p)->value = data;
  (*p)->count = 1;
  (*p)->next  = NULL;
}


   void Insert(pointer head, double data)      
/* --------------------------------------
 * add 'data' to the list 
 * --------------------------------------
 */
{                                      
  int     found = 0;
  pointer p;                           /* the traveling pointer        */
  pointer q;                           /* pointer to the previous node */

  p = head;
  while ((!found) && (p != NULL)) {    /* traverse the list until */
    q = p;                            
    if (p->value == data)              /* either 'data' is found  */
      found = 1;                       /* or the list ends        */
    else
      p = p->next;
  }
  if (found)                           /* if 'data' was found         */
    (p->count)++;                      /* inc the corresponding count */  
  else {                               /* else                        */
    Initialize(&p, data);              /* add a new node (at the end) */
    q->next = p;                       /* and link it                 */
  }
}


   void Traverse(pointer head)         
/* ---------------------------------------------------------------
 * traverse the list to compute the histogram statistics and print 
 * the histogram   
 * ---------------------------------------------------------------
 */
{                                         
  pointer  p;
  long     index  = 0;
  double   sum    = 0.0;
  double   sumsqr = 0.0;
  double   diff;
  double   mean;
  double   stdev;

  p = head;
  while (p != NULL) {                 /* traverse the list               */ 
    index += p->count;                /* to accumulate 'sum' and 'index' */
    sum   += p->value * p->count;
    p      = p->next;
  }
  mean = sum / index;

  p = head;                            /* traverse the list      */
  while (p != NULL) {                  /* to accumulate 'sumsqr' */
    diff    = p->value - mean;
    sumsqr += diff * diff * p->count;
    p       = p->next;
  }
  stdev = sqrt(sumsqr / index);
  printf("     value      count   proportion\n\n");
  p = head;                            /* traverse the list      */
  while (p != NULL) {                  /* to print the histogram */
    printf("%10.2f %10ld %12.3f\n",
            p->value, p->count, (double) p->count / index);
    p = p->next;
  }
  printf("\nsample size ........... = %7ld\n", index);
  printf("mean .................. = %7.3f\n", mean);
  printf("standard deviation .... = %7.3f\n", stdev);
}


   void Swap(pointer *p, pointer *q)       
/* ---------------------------------------------------------
 * swap the contents of the nodes to which 'p' and 'q' point     
 * ---------------------------------------------------------
 */
{                                          
  double value;
  long   count;

  value       = (*q)->value;
  count       = (*q)->count;
  (*q)->value = (*p)->value;
  (*q)->count = (*p)->count;
  (*p)->value = value;
  (*p)->count = count;
}


   void Sort(pointer head)              
/* -------------------------------
 * selection sort - slow, but sure 
 * -------------------------------
 */
{
  pointer p;                           /* the "outside" pointer       */
  pointer q;                           /* the "inside" pointer        */
  double  min;                         /* the smallest unsorted value */

  p = head;
  while (p != NULL) {
    q   = p;
    min = q->value;
    while (q != NULL) {                /* find the smallest unsorted value */
      if (q->value < min)              /* - that is 'min'                  */
        min = q->value;
      q = q->next;
    }
    q = p;                             /* find the node containing 'min' */
    while (q->value != min)            /* - 'q' is that node's pointer   */
      q = q->next;
    Swap(&p, &q);                      /* swap the contents of nodes p and q */
    p = p->next;
  }
}


  int main(void)
{
  pointer  head;                       /* pointer to the head of the list */
  double   data;

  scanf("%lf\n", &data);
  if (!feof(stdin))
    Initialize(&head, data);
  else
    head = NULL;

  while (!feof(stdin))  {
    scanf("%lf\n", &data);
    Insert(head, data);
  }

  if (head != NULL) {
    Sort(head);
    Traverse(head);
  }
  return (0);
}
