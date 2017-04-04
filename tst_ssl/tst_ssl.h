
#ifndef __MULTI_TEST_H__
#define __MULTI_TEST_H__

#ifdef WIN32
#include <process.h>
#include <windows.h>
#else
#include <pthread.h>
#include <semaphore.h>
#endif



#define MULTI_DEFAULT_THREADS		1
#define timeconst					(1.0/CLOCKS_PER_SEC)


// USED TO PASS PARAMETERS TO THE THREAD, AND STORE THE THREAD RELATED PARAMETERS
typedef struct _ThreadParams {
	int my_thread_id;		// passed to the thread
	char ip[32];			// the ip of the server
	char user1[32];			// the user to connect server one way
	char user2[32];			// the user to connect server two way
	int mediaType;			// 0 for Software, 1 for Smartcard
	char password[32];
	char file_media[1000];
	int numOfIterations;
} ThreadParams;

// AA -- Moshe remark

#endif



