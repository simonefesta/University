#include <stdlib.h>
#include <stdio.h>

#include "queue.h"


void linqueue_init(linqueue *q) {
	q->head = NULL;
	q->size = 0;
}


void linqueue_put(linqueue *q, double priority, void *payload) {
	linqueue_node *curr, *new;

	// Create and setup our new link
	new = (linqueue_node *)malloc(sizeof(linqueue_node));
	if (new == NULL) {
		printf("Memory not available to create link. Exiting.\n");
		exit (EXIT_FAILURE);
	}
	new->priority = priority;
	new->payload = payload;
	
	q->size++;
	
	// If Head is NULL, the queue doesn't yet exist, so we create one.
	if (q->head == NULL) {
		q->head = new;
		new->next = NULL;
		return;
	}
	
	// does our new element go before the first one?
	if (new->priority < q->head->priority) {
		new->next = q->head;
		q->head = new;
		return;
	}
	
	// if our element goes in the middle, this code will scan through
	// to find out exactly where it belongs.
	curr = q->head; // start at the begining node.
	while ((curr->next != NULL)) {
		if ((new->priority < curr->next->priority)) {
			if((new->priority >= curr->priority)) {
				// this inserts the new node into the middle if
				// it ID doesn't already exist in the queue
				new->next = curr->next;
				curr->next = new;
				return;
			}
		}
		curr = curr->next; // move to the next node.
	}
	
	// if we still haven't found the place, add at the end.
	//check if it's a dupe of the last element or not
	if (curr->priority == new->priority) {
		// if it's the same don't do anything, because the node already 
		// exists. In a real program you would update the nodes other
		// data in this section.
		return;
	} else {
		// else add the new element on the end.
		curr->next = new;
		new->next = NULL;
		return;
	}
}

void *linqueue_get(linqueue *q) {
	void *payload;
	linqueue_node *next;
	
	if (q->head == NULL) {
		puts("Couldn't remove node from queue");
		return NULL;
	}
	
	payload = q->head->payload;
	next = q->head->next;
	free(q->head);
	q->head = next;
	q->size--;

	return payload;
}

bool linqueue_empty(linqueue *q) {
	return (q->size == 0);
}
