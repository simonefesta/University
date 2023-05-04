#include "ROOT-Sim.h"

extern void ProcessEvent(lp_id_t me, simtime_t now, unsigned event_type, const void *content, unsigned size, void *s);
extern bool CanEnd(lp_id_t me, const void *snapshot);

unsigned int num_entities;

void *pcs_alloc(size_t size)
{
	return rs_malloc(size);
}

void pcs_free(void *ptr)
{
	rs_free(ptr);
}

struct simulation_configuration conf = {
    .n_threads = 0, // 0 means "use all available cores"
    .termination_time = 1000,
    .gvt_period = 1000,
    .log_level = LOG_INFO,
    .stats_file = "phold",
    .ckpt_interval = 0,
    .prng_seed = 0,
    .core_binding = true,
    .serial = false,
    .dispatcher = ProcessEvent,
    .committed = CanEnd,
};

int main(int argc, char **argv)
{
	// Check if we are given the number of entities to startup
	if(argc < 3) {
		fprintf(stderr, "Usage: %s num_entities end_time\n", argv[0]);
		exit(EXIT_FAILURE);
	}

	num_entities = (int)strtol(argv[1], NULL, 10);
	conf.lps = num_entities;

	// Handle simulation end time
	conf.termination_time = strtod(argv[2], NULL);
	if(conf.termination_time == 0) {
		conf.termination_time = SIMTIME_MAX; // set to "infinity"
	}

	RootsimInit(&conf);
	return RootsimRun();
}
