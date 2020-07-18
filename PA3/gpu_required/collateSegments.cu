/*
 **********************************************
 *  CS314 Principles of Programming Languages *
 *  Spring 2020                               *
 **********************************************
 */
#include <stdio.h>
#include <stdlib.h>

__global__ void collateSegments_gpu(int * src, int * scanResult, int * output, int numEdges) {
	
	int numThreads = blockDim.x * gridDim.x; //total number of threads
	int tid = blockDim.x * blockIdx.x + threadIdx.x;  // global index of the thread
	int i;
	/*this code will automatically loop through the number of threads, as long as you refer to each element in the arrays as [tid]*/


	for(i = tid; i < numEdges; i += numThreads)
	{

		if(src[i] != src[i+1]){ //we see that the data next to it isnt the same segment, so we've reached the last node
				//then we just update the output array with the scanResults from strongestNeighbor
			output[src[i]] = scanResult[i];
		}


	}

}
