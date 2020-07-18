/*
 **********************************************
 *  CS314 Principles of Programming Languages *
 *  Spring 2020                               *
 **********************************************
 */
#include <stdio.h>
#include <stdlib.h>

__global__ void exclusive_prefix_sum_gpu(int * oldSum, int * newSum, int distance, int numElements) {
	int numThreads = blockDim.x * gridDim.x; //total number of threads
	int tid = blockDim.x * blockIdx.x + threadIdx.x;  // global index of the thread
	int i = 0;
	/*this code will automatically loop through the number of threads, as long as you refer to each element in the arrays as [tid]*/

	for(i = tid; i <= numElements; i += numThreads)
	{
		//since this is an exclusive prefix sum, if the distance is 0, every element in the output should be set to the previous element
		//of the intput
		if(distance == 0 ){
			//check for an out of bounds to start
			if( i == 0){
				newSum[i] = 0;
			}else{
				//make everything in the new output equal to the prev of the input
				newSum[i] = oldSum[i-1];
			}
		}else{ //distance/stride != 0, we start adding.
			if(i >= distance){ //first make sure we dont array indexes less than 0.
				newSum[i] = oldSum[i] + oldSum[i-distance]; // the actual scan

			}else{ // if the distance is somehow less than 0
				newSum[i] = oldSum[i];
			}
		}



	}

}
