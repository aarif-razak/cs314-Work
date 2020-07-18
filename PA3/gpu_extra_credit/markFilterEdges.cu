/*
 **********************************************
 *  CS314 Principles of Programming Languages *
 *  Spring 2020                               *
 **********************************************
 */
#include <stdio.h>
#include <stdlib.h>

__global__ void markFilterEdges_gpu(int * src, int * dst, int * matches, int * keepEdges, int numEdges) {
	int numThreads = blockDim.x * gridDim.x; //total number of threads
	int tid = blockDim.x * blockIdx.x + threadIdx.x;  // global index of the thread
	int i = 0;
	/*this code will automatically loop through the number of threads, as long as you refer to each element in the arrays as [tid]*/
	for(i = tid; i < numEdges; i += numThreads)
	{
	if(matches[src[i]] == -1){//check inside the src to be sure
		if(matches[dst[i]] == -1){
			//now we can establish than edge should be ketp
			keepEdges[i] = 1;
		}else{
			keepEdges[i] = 0;
		}
	}else{
		keepEdges[i] = 0;
	} 


	}

}
