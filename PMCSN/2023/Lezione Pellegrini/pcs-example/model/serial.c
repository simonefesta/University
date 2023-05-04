#include <stdlib.h>

// This is the entry point of the simple sequential scheduler
extern int run_simulation(int argc, char **argv);

void *pcs_alloc(size_t size)
{
	return malloc(size);
}

void pcs_free(void *ptr)
{
	free(ptr);
}

int main(int argc, char **argv) {
	return run_simulation(argc, argv);
}
