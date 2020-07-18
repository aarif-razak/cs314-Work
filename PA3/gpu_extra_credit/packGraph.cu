/*
 **********************************************
 *  CS314 Principles of Programming Languages *
 *  Spring 2020                               *
 **********************************************
 */
#include <stdio.h>
#include <stdlib.h>

__global__ void packGraph_gpu(int * newSrc, int * oldSrc, int * newDst, int * oldDst, int * newWeight, int * oldWeight, int * edgeMap, int numEdges) {
	int numThreads = blockDim.x * gridDim.x; //total number of threads
	int tid = blockDim.x * blockIdx.x + threadIdx.x;  // global index of the thread
	int i = 0;
	/*this code will automatically loop through the number of threads, as long as you refer to each element in the arrays as [tid]*/

	for(i = tid; i < numEdges; i += numThreads)
	{

		//2 cases, keeping an edge or not
		/// to check if we keep
		if(edgeMap[i+1] != edgeMap[i]){
			newSrc[edgeMap[i]] = oldSrc[i];
			newDst[edgeMap[i]] = oldDst[i];
			newWeight[edgeMap[i]] = oldWeight[i];
		}



	}
}
