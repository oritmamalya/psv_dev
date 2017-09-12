
#ifdef WIN32
#include <process.h>
#include <windows.h>
#endif

#include <stdio.h>
#include <stdlib.h>
#include "tst_ssl.h"

// This is a remark in Orit branch

ThreadParams *G_ThreadParamsArray;
int G_this_client_threads;    // NUMBER OF THREADS

double my_time_diff(long *end, long *start)
{
	double elapsed;
	elapsed = (*end - *start) * 123;
	return elapsed;
}

// Hello Alll!!!!!!!!!!!


int open_ssl_connection(int threadId, int NumOfIterations, char *ip, char *user1, char* user2, int isSC, char *pass, char *userMedia)
{
	int i=0;
	int rc = 0;
	void*	csv = NULL;
	
	// For loop commentAAA
	for(i;i<NumOfIterations+3;i++)
	{
		// Checking i index
		if (i%2 == 0)
		{
			//rc = csv_open_auth(csv, ip, user1, 0, MT_SSL_NOMEDIA, "", "");
			if (rc)
				printf("Thread ID: %d: csv_open_auth one way error = %d in %d iteration\n", threadId, rc, i);
			else if (i%10 == 0)
				printf("Thread ID: %d: csv_open one way %d iteration end successfully.\n", threadId, i);

			//rc = csv_close(csv);
			if (rc)
				printf("Thread ID: %d: csv_close one way error = %d in %d iteration\n", threadId, rc, i);

		}
		else
		{
			/*if (isSC)
				rc = csv_open_auth(csv, ip, user2, 0, MT_SMARTCARD, "", pass);
			else
				rc = csv_open_auth(csv, ip, user2, 0, MT_SOFTWARE, userMedia, pass);

			if (rc)
				printf("Thread ID: %d: csv_open_auth two way error = %d in %d iteration\n", threadId, rc, i);
			else if (i%5 == 0)
				printf("Thread ID: %d: csv_open two way %d iteration end successfully.\n", threadId, i);

			rc = csv_close(csv);*/
			if (rc)
				printf("Thread ID: %d: csv_close two way error = %d in %d iteration\n", threadId, rc, i);

		}
	}
	return rc;
}

// THREAD FUNCTION :
void ssl_thread(void *lpParameter)
{
	ThreadParams *my_params;
	int rc;

	my_params = (ThreadParams *) lpParameter;
	printf("In THREAD %d (ID)\n", my_params->my_thread_id + 1);
	rc = open_ssl_connection(my_params->my_thread_id + 1, my_params->numOfIterations, my_params->ip, my_params->user1,
							 my_params->user2, my_params->mediaType, my_params->password, my_params->file_media);
	if (rc)
		printf("ERROR ON Thread %d, rc = 0x%x\n", my_params->my_thread_id, rc);
}

int run_ssl_tst(int num_threads, char **argv)
{
	int i, sum = 0;
	unsigned int tmp;
	long t1, t2;

	// Create the threads
#ifdef WIN32
	HANDLE *threads = NULL;
	threads = (HANDLE*) malloc(sizeof(HANDLE) * num_threads);
#else
	pthread_t *tinfo;
	tinfo = (pthread_t*) malloc(sizeof(pthread_t) * num_threads);
#endif

	// Update the number of threads
	G_this_client_threads = num_threads;

	// Create the threads array parameters as argv
	G_ThreadParamsArray = (ThreadParams *) malloc(sizeof(ThreadParams) * num_threads);

	printf("Press enter to start num_threads: %d..\n", num_threads);
	getc(stdin);
	t1 = clock();

	// Run all the threads..
	for(i = 0; i < num_threads; i++)
	{
		// Update the thread ID
		G_ThreadParamsArray[i].my_thread_id = i;

		// Update the thread primary IP
		strcpy(G_ThreadParamsArray[i].ip, argv[1]);

		// Update the thread user1 ID to be connected to the server
		strcpy(G_ThreadParamsArray[i].user1, argv[2]);

		// Update the thread user2 ID to be connected to the server
		strcpy(G_ThreadParamsArray[i].user2, argv[3]);

		// Update the thread mediatype
		G_ThreadParamsArray[i].mediaType = atoi(argv[4]);

		// Update the thread password
		strcpy(G_ThreadParamsArray[i].password, argv[5]);

		// Update the thread file_media
		strcpy(G_ThreadParamsArray[i].file_media, argv[6]);

		G_ThreadParamsArray[i].numOfIterations = atoi(argv[7]);

		// Run the thread by sending the thread running function and the thread parameters
#ifdef WIN32
		if ((tmp = _beginthread(ssl_thread, 0, &G_ThreadParamsArray[i])) == -1)
		{
			printf("Error on CreateThread, error number is %d\n", GetLastError());
			exit(1);
		}
		threads[i] = (HANDLE *) tmp;
#else
		tmp = pthread_create(&tinfo[i], NULL, ssl_thread, &G_ThreadParamsArray[i]);
		if (tmp)
		{
			 printf("Error on pthread_create\n");
			 exit(1);
		}
#endif

	}

#ifdef WIN32
	// NOW WAIT FOR ALL THE THREADS, AND EXIT WHEN ANY OF THEM EXITS
	WaitForMultipleObjects(num_threads, threads, TRUE, INFINITE);
#else
	for (i=0; i<num_threads; i++)
	{
		tmp = pthread_join(tinfo[i], NULL);
		if (tmp)
			printf("pthread_join failed\n");
	}
#endif

	// Free alocated memory
	free(G_ThreadParamsArray);

	// Print total time
	t2 = clock();
	printf("total time is: %lg\n" ,my_time_diff(&t2,&t1));
	return 0;
}

//--------------------------------------------------------------------------
// main
//
// arguments: <psv ip>, <used id 1>, <used id 2>, [Media Type 0/1 for SOFTWARE/SMARTCARD],
//					[Password of user2] [File Media], <num of iterations> <num of threads>
//
// For example: 212.25.66.133 first EKMuser 0 741852 C:\\EKMuser.sft 6 5
//--------------------------------------------------------------------------
int main(int argc, char **argv)
{
	int num_threads = MULTI_DEFAULT_THREADS;
	double a[1024]={1}, b[1024]={2}, c[1024]={0};
	unsigned int i, sum =sizeof(a);

	/*if(argc < 6)
	{
		printf("USAGE: <psv ip>, <used id 1>, <used id 2>, [Media Type 0/1 for SOFTWARE/SMARTCARD], [Password of user2] [File Media], <num of iterations> <num of threads>\n");
		return 0;;
	}

	if (argc > 7)
		num_threads = atoi(argv[8]);

	run_ssl_tst(num_threads, argv);*/

	do
	{

		Sleep(20);

		//sum = 0;
		memset(a, 1, sum);
		memset(b, 2, sum);
		memset(c, 0, sum);

		for (i = 0; i < 0xfffff; i++)
			c[i] = a[i]*b[i];
		//sum += i;


	} while (1);


	return 0;
}
