# January 5, 2005
#
# Makefile for compiling accompanying software for
# "Discrete-Event Simulation: A First Course" by Park and Leemis
#

CC = gcc
CFLAGS = -g -Wall
LDFLAGS = -lm

OBJFILES = acs buffon cdh craps det ddh estimate galileo hat msq rng.o rngs.o rvgs.o rvms.o san sieve sis1 sis2 sis3 sis4 ssms ssq1 ssq2 ssq3 ssq4 ttr uvs

all: $(OBJFILES)

acs: acs.c
	$(CC) $< -o $@ $(LDFLAGS)

buffon: buffon.c rng.o
	$(CC) $^ -o $@ $(LDFLAGS) 

cdh: cdh.c
	$(CC) $^ -o $@ $(LDFLAGS)

craps: craps.c rng.o
	$(CC) $^ -o $@ $(LDFLAGS)

det: det.c rng.o
	$(CC) $^ -o $@ $(LDFLAGS)

ddh: ddh.c
	$(CC) $^ -o $@ $(LDFLAGS)

estimate: estimate.c rngs.o rvms.o
	$(CC) $^ -o $@ $(LDFLAGS)

galileo: galileo.c rng.o
	$(CC) $^ -o $@ $(LDFLAGS)

hat: hat.c rng.o
	$(CC) $^ -o $@ $(LDFLAGS)

msq: msq.c rngs.o
	$(CC) $^ -o $@ $(LDFLAGS)

rng.o: rng.c rng.h
	$(CC) -c $<

rngs.o: rngs.c rngs.h
	$(CC) -c $<

rvgs.o: rvgs.c rvgs.h rngs.c rngs.h
	$(CC) -c $<

rvms.o: rvms.c rvms.h rngs.c rngs.h
	$(CC) -c $<

san: san.c rngs.o
	$(CC) $^ -o $@ $(LDFLAGS)

sieve: sieve.c
	$(CC) $^ -o $@ $(LDFLAGS)

sis1: sis1.c
	$(CC) $^ -o $@ $(LDFLAGS)

sis2: sis2.c rng.o
	$(CC) $^ -o $@ $(LDFLAGS)

sis3: sis3.c rngs.o
	$(CC) $^ -o $@ $(LDFLAGS)

sis4: sis4.c rngs.o rvgs.o
	$(CC) $^ -o $@ $(LDFLAGS)

ssms: ssms.c rngs.o
	$(CC) $^ -o $@ $(LDFLAGS)

ssq1: ssq1.c
	$(CC) $^ -o $@ $(LDFLAGS)

ssq2: ssq2.c rng.o
	$(CC) $^ -o $@ $(LDFLAGS)

ssq3: ssq3.c rngs.o
	$(CC) $^ -o $@ $(LDFLAGS)

ssq4: ssq4.c rngs.o rvgs.o
	$(CC) $^ -o $@ $(LDFLAGS)

ttr:  ttr.c rngs.o
	$(CC) $^ -o $@ $(LDFLAGS)

uvs: uvs.c rngs.o rvgs.o
	$(CC) $^ -o $@ $(LDFLAGS)

clean:
	/bin/rm -f $(OBJFILES) core*
