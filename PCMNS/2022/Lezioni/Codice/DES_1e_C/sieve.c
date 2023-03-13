/* ------------------------------------------------------------------------- *
 * This is the classic prime sieve of Eratosthenes - a simple algorithm      *
 * that finds all the prime numbers between 2 and the constant 'N'.          * 
 *                                                                           *
 * Name            : sieve.c  (Sieve of Eratosthenes)                        *
 * Author          : Steve Park & Dave Geyer                                 *
 * Language        : ANSI C                                                  *
 * Latest Revision : 9-15-96                                                 *
 * ------------------------------------------------------------------------- */

#include <stdio.h>
#include <math.h>                      

#define N     46341L                 /* limited only by memory size   */
#define SQRTN ((long) sqrt(N)) 

/* ============== */
   int main(void)                                    
/* ============== */
{
  int  prime[N + 1];                  /* n is prime <=> prime[n] == 1  */
  long n;                             /* index of possible primes      */
  long s;                             /* step index                    */
  long t = 0;                         /* index used for tabular output */

  prime[0] = 0;                       /* initialize the sieve */
  prime[1] = 0;
  for (n = 2; n <= N; n++)       
    prime[n] = 1;

  for (n = 2; n <= SQRTN; n++)         /* search all possibilities       */
    if (prime[n])                      /* if n is prime,                 */
      for (s = 2; s <= (N / n); s++)   /* 2n, 3n, 4n ...  can't be prime */
        prime[s * n] = 0;

  printf("\tThe primes between 2 and %ld are\n\n", N);
  for (n = 2; n <= N; n++)
    if (prime[n])  {
      if (t == 0)
        printf("\t");
      printf("%7ld", n);
      t = (t + 1) % 10;
      if (t == 0)
        printf("\n");
    }
  printf("\n");

  return (0);
}
