/*
 * compile with:  nvcc -arch=sm_20 -o bigMatrix bigMatrix.cu
 * run with ./bigMatrix file1, file2
 */

#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <assert.h>
#include <omp.h>
#include <string.h>

//computes ab
//now, b is transposed so the task is now to multiply the rows of b with the rows of a. note: b_r and b_c are rows and columns of original b matrix
//get one processor for each item in result matrix
__global__ void mult(int *a, int *b, int *ret, int a_r, int a_c, int b_r, int b_c){

	int t = blockDim.x * blockIdx.x + threadIdx.x;
	
	int x = t / a_r; // row in a
	int y = t % b_c; //row in b_t

	int retSize = a_c * b_r;
	int sum = 0;

	int counter = 0;
	int *l = (int*)malloc(sizeof(int) * a_c);
	int *r = (int*)malloc(sizeof(int) * b_r);

	while( t < retSize ){
		for(counter = 0; counter < a_c; counter++){
			l[counter] = a[ (a_c) * x + counter];
		}

		for(counter = 0; counter < b_r; counter++){
			r[counter] = b[ (b_r) * y + counter];
		}

		if(b_r != a_c){ 
			ret[t] = -666;
		}
		else {
			for(counter = 0; counter < b_r; counter++){
				sum += l[counter] * r[counter];
			}
			ret[t] = sum;
		}

		t += gridDim.x * blockDim.x; 
		x = t / a_r; // row in a
		y = t % b_c; //row in b_t

		sum = 0;
		
	}


	free(l);
	free(r);

}

int main(int argc, char **argv){

	double start = omp_get_wtime();

	FILE *left = fopen(argv[1], "r");
	assert(left != NULL);
	FILE *right = fopen(argv[2], "r");
	assert(right != NULL);

	int l_c = 0, l_r = 0, r_c = 0, r_r = 0;

	//read rows and columns of left
	fscanf(left, "%d", &l_r);
	fscanf(left, "%d", &l_c);

	//read rows and columns of right
	fscanf(right, "%d", &r_r);
	fscanf(right, "%d", &r_c);


	int lNum = l_r * l_c;
	int rNum = r_r * r_c;
	int lrNum = l_c * r_r;

	int *lMat = (int*)malloc(sizeof(int) * lNum);
	int *rMat = (int*)malloc(sizeof(int) * rNum);
	int *lrMat = (int*)malloc(sizeof(int) * lrNum);

	int *rTranspose = (int*)malloc(sizeof(int) * rNum);
	int tranRow = 0;
	int tranCol = 0;

	//read in left matrix (argv[1])
	int counter = 0, inner = 0;
	while(counter < lNum){ fscanf(left, "%d", &lMat[counter]);  counter++;}

	//read in right matrix (argv[2])
	counter = 0;
	while(counter < rNum){ 
		fscanf(right, "%d", &rMat[counter]);  
		rTranspose[ (r_r * tranRow) + tranCol] = rMat[counter]; //transpose matrix
		counter++;

		tranRow++;
		if(tranRow == r_c){
			tranRow = 0;
			tranCol++;
		}
	}


//have to manually set heap size http://docs.nvidia.com/cuda/cuda-c-programming-guide/index.html#dynamic-global-memory-allocation-and-operations
/*
	to multiply a mXn and a oXp matrix, need the following memory: mXn + oXp + mXp + (m + p)(mXp)
*/
	int *a, *b, *ret;
	assert( cudaMalloc(&a, sizeof(int) * lNum) != cudaErrorMemoryAllocation);
	assert(cudaMalloc(&b, sizeof(int) * rNum) != cudaErrorMemoryAllocation);
	assert(cudaMalloc(&ret, sizeof(int) * lrNum) != cudaErrorMemoryAllocation);

	assert( cudaMemcpy(a, lMat, sizeof(int) * lNum, cudaMemcpyHostToDevice) == cudaSuccess);
	assert( cudaMemcpy(b, rTranspose, sizeof(int) * rNum, cudaMemcpyHostToDevice) == cudaSuccess);

	//printf(cudaGetErrorString(cudaMemcpy(b, rTranspose, sizeof(int) * rNum, cudaMemcpyHostToDevice) ));// == cudaSuccess);

	mult<<<12, 128>>>(a, b, ret, l_r, l_c, r_r, r_c); //switch the rows and columns for the transposed matrix

printf(cudaGetErrorString(cudaMemcpy(lrMat, ret, sizeof(int) * lrNum, cudaMemcpyDeviceToHost) ));
	assert(cudaMemcpy(lrMat, ret, sizeof(int) * lrNum, cudaMemcpyDeviceToHost) == cudaSuccess);

	//print result matrix
	FILE *out = fopen("cudamat", "w");
	for(counter = 0; counter < l_r; counter++){
		for(inner = 0; inner < r_c; inner++){
			fprintf(out, "%d ", lrMat[ (counter * r_c) + inner]);
		}
		fprintf(out, "\n");
	}

	fclose(out);

	cudaFree(a);
	cudaFree(b);
	cudaFree(ret);

	free(lMat);
	free(rMat);
	free(lrMat);
	
	free(rTranspose);

	fclose(left);
	fclose(right);

	double end = omp_get_wtime();
	printf("%lf\n", end - start);

	return 0;
}
