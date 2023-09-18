#pragma once

// This is the initialization event that must be supported by the model
#define INIT 65534

// These are the application callbacks invoked by the core
void ProcessEvent(unsigned int me, double now, int event_type, void *event_content, unsigned int size, void *state);
bool CanEnd(unsigned int me, void *snapshot);

// Simulation core APIs
extern void ScheduleNewEvent(unsigned int receiver, double timestamp, unsigned int event_type, void *event_content, unsigned int event_size);
extern void SetState(void *state);

// Numerical library
extern void Srand(long *);
extern float Uniform(long *);
extern double Expent(long *, double);

// Number of LPs defined in the simulation at command line
extern unsigned int num_entities;
