#include <math.h>
#include <time.h>

#include "rng.h"

#define MODULUS 2147483647
#define MULTIPLIER 48271
#define A256 22925         // jump multiplier

static long master_seed;

double Uniform(long *seed)
{
	const long Q = MODULUS / MULTIPLIER;
	const long R = MODULUS % MULTIPLIER;
	long t;

	t = MULTIPLIER * (*seed % Q) - R * (*seed / Q);
	if(t > 0)
		*seed = t;
	else
		*seed = t + MODULUS;
	return ((double)*seed / MODULUS);
}

double Exponential(long *seed, double m)
{
	return (-m * log(1.0 - Uniform(seed)));
}

static long ModPow(long base, int exponent)
{
	long result = 1;
	while (exponent > 0) {
		if (exponent % 2 == 1) {
			result = (result * base) % MODULUS;
		}
		base = (base * base) % MODULUS;
		exponent /= 2;
	}
	return result;
}

long InitSeed(unsigned int me)
{
	const long Q = MODULUS / A256;
	const long R = MODULUS % A256;
	long x = master_seed;
	long seed;

	if (me == 0) {
		return x;
	}

	x = A256 * (x % Q) - R * (x / Q);
	if (x > 0) {
		seed = x;
	} else {
		seed = x + MODULUS;
	}

	const int k = me - 1;
	const long powA256 = ModPow(A256, k);
	const long powQ = ModPow(Q, k);

	seed = (seed * powA256) % MODULUS;
	seed = (seed - ((R * ((powQ - 1) / (Q - 1))) % MODULUS)) % MODULUS;

	if (seed < 0) {
		seed += MODULUS;
	}

	return seed;
}

static void __attribute__((constructor)) initialize() {
	master_seed = (long)(((unsigned long)time((time_t *)NULL)) % MODULUS);
}
