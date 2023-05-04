#pragma once

#include <stdlib.h>
#include <stdbool.h>

typedef struct _linqueue_node {
	double priority;
	void *payload;
	struct _linqueue_node *next;
} linqueue_node;

typedef struct _linqueue {
	linqueue_node *head;
	size_t size;
} linqueue;


extern void linqueue_init(linqueue *);
extern void linqueue_put(linqueue *, double, void *);
extern void *linqueue_get(linqueue *);
extern bool linqueue_empty(linqueue *);
