/*
2. Add 2 vectors of length N, keeping number of threads per block as 256 and vary the number of blocks to handle N elements.
*/

#include <stdio.h>
#include <stdlib.h>
#include <math.h>

#include "cuda_runtime.h"
#include "device_launch_parameters.h"

__global__ void addVecs(float *a, float *b, int n){
    /*
    blockIdx.x - which block
    blockDim.x - threads in a block 
    threadIdx.x - which thread in the block 
    */
    int i = threadIdx.x + blockDim.x * blockIdx.x;
    if (i<n)
        b[i] = sinf(a[i]);
}

int main(void){
    int n;
    float *d_a, *d_b;   //Device copies

    printf("Enter n : ");
    scanf("%d", &n);

    int size = sizeof(float)*n;

    //Host copies
    float *a = (float*)malloc(size);
    float *b = (float*)malloc(size);

    //Allocating space for device copies
    cudaMalloc((void **)&d_a, size);
    cudaMalloc((void **)&d_b, size);

    printf("Angles in Radians : \n");
    for (int i=0; i<n; i++)
        scanf("%f", &a[i]);

    //Copy to device
    cudaMemcpy(d_a, a, size, cudaMemcpyHostToDevice);

    // Launch add() kernel on GPU
    int numBlocks = ceil(n/256.0);
    int numThreads = 256;

    addVecs<<<numBlocks, numThreads>>>(d_a, d_b, n);

    //Copy result to host
    cudaMemcpy(b, d_b, size, cudaMemcpyDeviceToHost);
    printf("Result : \n");
    for (int i=0; i<n; i++)
        printf("%f\n", b[i]);

    //Cleanup
    cudaFree(d_a);
    cudaFree(d_b);

    return 0;
}