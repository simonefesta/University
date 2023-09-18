#include <stdlib.h>
#include <stdio.h>
#include <limits.h>
#include <float.h>
#include <string.h>
#include <stdint.h>
#include <sys/time.h>

#include "calqueue.h"
#include "core.h"

typedef struct _platform_event {
	double timestamp;
	unsigned int destination;
	unsigned int event_type;
	size_t size;
	void *payload;
} platform_event;


static calqueue *fel;
static unsigned long long int processed_events = 0;
static double simulation_time = 0;
static unsigned int current_entity = UINT_MAX;
static void **simulation_states;
static bool terminate = false;


unsigned int num_entities;


void ScheduleNewEvent(unsigned int receiver, double timestamp, unsigned int event_type, void *event_content,
    unsigned int event_size)
{
	platform_event *e;

	// Sanity checks
	if(timestamp < simulation_time) {
		fprintf(stderr,
		    "Entity %d is trying to send events in the past. Current time: %f, scheduled time: %f\n",
		    current_entity, simulation_time, timestamp);
		exit(EXIT_FAILURE);
	}


	// Populate the message data structure
	e = malloc(sizeof(platform_event));
	bzero(e, sizeof(platform_event));
	e->destination = receiver;
	e->timestamp = timestamp;
	e->event_type = event_type;
	e->size = event_size;
	e->payload = malloc(event_size);
	memcpy(e->payload, event_content, event_size);

	// Put the event in the Calenda Queue
	calqueue_put(fel, timestamp, e);
}

void SetState(void *state)
{
	simulation_states[current_entity] = state;
}

typedef uint_fast64_t timer_uint;

static inline timer_uint timer_new(void)
{
	struct timeval tmptv;
	gettimeofday(&tmptv, NULL);
	return (timer_uint)tmptv.tv_sec * 1000000U + tmptv.tv_usec;
}

static inline timer_uint timer_value(timer_uint start)
{
	return timer_new() - start;
}


int run_simulation(int argc, char **argv)
{
	unsigned int i;
	platform_event *e;
	double end_time;
	timer_uint execution_time;

	// Check if we are given the number of entities to startup
	if(argc < 3) {
		fprintf(stderr, "Usage: %s num_entities end_time\n", argv[0]);
		exit(EXIT_FAILURE);
	}

	// Handle simulation end time
	end_time = strtod(argv[2], NULL);
	if(end_time == 0) {
		end_time = DBL_MAX; // set to "infinity"
	}

	// Initialize data structures to handle entities
	num_entities = (int)strtol(argv[1], NULL, 10);
	printf("Initializing %d entities...\n", num_entities);
	simulation_states = malloc(sizeof(void *) * num_entities);


	// Allocate and initialize FEL
	fel = malloc(sizeof(calqueue));
	calqueue_init(fel);

	execution_time = timer_new();

	// Schedule INIT to entities
	for(i = 0; i < num_entities; i++) {
		current_entity = i;
		ProcessEvent(i, 0, INIT, NULL, 0, NULL);
	}

	// Main loop
	while(!calqueue_empty(fel)) {
		e = calqueue_get(fel);

		// Update current entity and simulation clock
		current_entity = e->destination;
		simulation_time = e->timestamp;

		ProcessEvent(current_entity, simulation_time, e->event_type, e->payload, e->size, simulation_states[current_entity]);
		processed_events++;

		// free memory
		if(e->payload != NULL)
			free(e->payload);
		free(e);

		// Inspect the simulation state to see if we can terminate. Works only with a stable predicate
		terminate &= CanEnd(current_entity, simulation_states[current_entity]);

		// Let the user know that we are alive
		if(simulation_time == DBL_MAX)
			printf("\rVirtual time: infinity");
		else
			printf("\rVirtual time: %lf", simulation_time);
		fflush(stdout);

		if(simulation_time > end_time || terminate)
			break;
	}

	execution_time = timer_value(execution_time);

	puts("Final state reached:");
	for(i = 0; i < num_entities; i++) {
		CanEnd(i, simulation_states[i]);
	}
	printf("Simulation complete after processing %llu events, in %f seconds\n", processed_events, (double)execution_time / 1000000);

	free(simulation_states);
	free(fel);
	return 0;
}
