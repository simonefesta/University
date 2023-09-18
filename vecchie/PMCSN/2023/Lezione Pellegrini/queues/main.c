#include <stdlib.h>
#include <stdio.h>
#include <time.h>

#include "calqueue.h"
#include "queue.h"

#define PAYLOAD_SIZE	32
//#define NUM_NODES	50
#define NUM_NODES	30000
#define MAX_PRIORITY 5

//#define USE_CALQ
//#define SUPPRESS_PRINT


#ifdef USE_CALQ
calqueue *queue;
#else
linqueue *queue;
#endif

typedef struct _node {
	double priority;
	char payload[PAYLOAD_SIZE];
} node;


// Generate a random string (used for payload)
static char *rand_string(char *str, size_t size) {
	size_t n;
	const char charset[] = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";

	if(size) {
		--size;
		for (n = 0; n < size; n++) {
			int key = rand() % (int) (sizeof charset - 1);
			str[n] = charset[key];
		}

		str[size] = '\0';
    }
    return str;
}

char *rand_string(char *str, size_t size);

int main(void) {
	int i;
	node *e;
	
	// Initialize a simple RNG
	srand(time(NULL));
	
	#ifdef USE_CALQ
	// Allocate and initialize Calendar Queue
	queue = malloc(sizeof(calqueue));
	calqueue_init(queue);
	#else
	queue = malloc(sizeof(linqueue));
	linqueue_init(queue);
	#endif
	
	// Populate Calendar Queue
	puts("Inserting elements:");
	for(i = 0; i < NUM_NODES; i ++) {
		e = malloc(sizeof(node));
		rand_string(e->payload, PAYLOAD_SIZE);

		// It is important to generate priorities randomly!
		e->priority = MAX_PRIORITY * (rand() / (double)RAND_MAX);
		//e->priority = 1.0;
		
		#ifndef SUPPRESS_PRINT
		printf("%03d) Inserting in the queue <%f, %s>\n", i, e->priority, e->payload);
		#endif
		
		#ifdef USE_CALQ
		calqueue_put(queue, e->priority, e);
		#else 
		linqueue_put(queue, e->priority, e);
		#endif
	}
	
	// Retrieve elements from Calendar queue
	puts("\nListing ordered elements:");
	i = 0;
	#ifdef USE_CALQ
	while(!calqueue_empty(queue)) {
		e = calqueue_get(queue);
	#else
	while(!linqueue_empty(queue)) {
		e = linqueue_get(queue);
	#endif
	
		#ifndef SUPPRESS_PRINT
		printf("%03d) Getting from the calendar queue <%f, %s>\n", i++, e->priority, e->payload);
		#endif

		free(e);
	}

	free(queue);
	return 0;
}
