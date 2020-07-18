/*
 **********************************************
 *  CS314 Principles of Programming Languages *
 *  Spring 2020                               *
 **********************************************
 */
#include <stdio.h>
#include <stdlib.h>

__global__ void check_handshaking_gpu(int * strongNeighbor, int * matches, int numNodes) {
	
	int numThreads = blockDim.x * gridDim.x; //total number of threads
	int tid = blockDim.x * blockIdx.x + threadIdx.x;  // global index of the thread
	int i = 0;
	/*this code will automatically loop through the number of threads, as long as you refer to each element in the arrays as [tid]*/

	for(i = tid; i < numNodes; i += numThreads)
	{
		if(i == strongNeighbor[strongNeighbor[i]]){
			matches[i] = strongNeighbor[i];
		}else{
			matches[i] = -1;
		}

	}
}
