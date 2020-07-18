/*
 **********************************************
 *  CS314 Principles of Programming Languages *
 *  Spring 2020                               *
 **********************************************
 */
#include <stdio.h>
#include <stdlib.h>

__global__ void strongestNeighborScan_gpu(int * src, int * oldDst, int * newDst, int * oldWeight, int * newWeight, int * madeChanges, int distance, int numEdges) {
	/*numEdges is the number of tasks that need to be completed*/
	/*distance is the stride aka the change between each src/dst/weight node check*/


	int numThreads = blockDim.x * gridDim.x; //total number of threads
	int tid = blockDim.x * blockIdx.x + threadIdx.x;  // global index of the thread
	int i = 0;
	/*this code will automatically loop through the number of threads, as long as you refer to each element in the arrays as [tid]*/

	for(i = tid; i < numEdges; i += numThreads)
	{

			/*quickly ensure that the stride is even valid/in the array*/
	if(i-distance >= 0){


		/*check if everything at i is in the same segment*/
	if(src[i]  == src[i-distance]){

		if (oldWeight[i-distance] > oldWeight[i]){ // check if the weight in the next stride is greater than what we have now
			
			newDst[i] = oldDst[i-distance];
			newWeight[i] = oldWeight[i-distance];
			(*madeChanges) = 1;
		}else if(oldWeight[i-distance] == oldWeight[i]){ //nextDoor weight is equal
					
					/*smaller vertexID should be treated as greater*/
					/*it will be already found by dst[i-distance] */
					newDst[i] = oldDst[i-distance];
					newWeight[i] = oldWeight[i];
				

		}else{//in this case, the left oldWeight is greater than the rightside
			newDst[i] = oldDst[i];
			newWeight[i] = oldWeight[i];
			

		}
		//if nothing else, just return the same weight and dst from before
	}else{

			newDst[i] = oldDst[i];
			newWeight[i] = oldWeight[i];
	}

	


	}else{
		newDst[i] = oldDst[i];
			newWeight[i] = oldWeight[i];
			
			}


}
}