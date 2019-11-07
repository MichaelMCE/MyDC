
#define WIN32_LEAN_AND_MEAN
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/types.h>
#include <pthread.h>
#include <semaphore.h>

#include "mydc.h"
#include "lock.h"


//pthread_cond_t cv;
//pthread_condattr_t cattr;
//pthread_mutex_t mp;

sem_t semTMYDCHUB;
pthread_mutex_t muteTMYDCHUB;
sem_t semRecvMYDC;



void TMYDCHUB_LOCK_CREATE ()
{
	// TMYDCHUB = new LOCK (constructor)
	// create sem with local process scope, with one lock
	
	pthread_mutex_init(&muteTMYDCHUB, 0);
	sem_init(&semTMYDCHUB, 0, 1);
};

void TMYDCHUB_LOCK_DELETE ()
{
	// delete TMYDCHUB (deconstruct))
	
	sem_destroy(&semTMYDCHUB);
	pthread_mutex_destroy (&muteTMYDCHUB);
};

void TMYDCHUB_LOCK ()
{
	//TMYDCHUB::LOCK

	pthread_mutex_lock (&muteTMYDCHUB);
	do{
	}
	while (sem_wait(&semTMYDCHUB) != 0);
};

void TMYDCHUB_UNLOCK ()
{
	//TMYDCHUB::UNLOCK
	if (sem_post(&semTMYDCHUB) == -1)
		LOG("TMYDCHUB_UNLOCK(): failed to unlock semaphore");
	pthread_mutex_unlock (&muteTMYDCHUB);
};


void RECVMYDC_LOCK_CREATE ()
{
	// create sem with local process scope, with one lock
	sem_init(&semRecvMYDC, 0, 1);
};

void RECVMYDC_LOCK_DELETE ()
{
	sem_destroy(&semRecvMYDC);
};

void RECVMYDC_LOCK ()
{
	do{
	}
	while (sem_wait(&semRecvMYDC) != 0);
};

void RECVMYDC_UNLOCK ()
{
	if (sem_post(&semRecvMYDC) == -1)
		LOG("RECVMYDC_UNLOCK(): failed to unlock semaphore");
//	else
//		LOG("unlocked");
};


