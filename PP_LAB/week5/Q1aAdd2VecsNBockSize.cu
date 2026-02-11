/*
1. a) Add 2 vectors of length N using block size as N
*/

#include <stdio.h>
#include <stdlib.h>

#include "cuda_runtime.h"
#include "device_launch_parameters.h"

__global__ void addVecs(int *a, int *b, int *c, int n){
    /*
    blockIdx.x - which block
    blockDim.x - threads in a block 
    threadIdx.x - which thread in the block 
    */
    int i = threadIdx.x + blockDim.x * blockIdx.x;
    if (i<n)
        c[i] = a[i] + b[i];
}

int main(void){
    int n;
    int *d_a, *d_b, *d_c;   //Device copies

    printf("Enter n : ");
    scanf("%d", &n);

    int size = sizeof(int)*n;

    //Host copies
    int *a = (int*)malloc(size);
    int *b = (int*)malloc(size);
    int *c = (int*)malloc(size);

    //Allocating space for device copies
    cudaMalloc((void **)&d_a, size);
    cudaMalloc((void **)&d_b, size);
    cudaMalloc((void **)&d_c, size);

    printf("Elements of Array 1 : \n");
    for (int i=0; i<n; i++)
        scanf("%d", &a[i]);

    printf("Elements of Array 2 : \n");
    for (int i=0; i<n; i++)
        scanf("%d", &b[i]);

    //Copy to device
    cudaMemcpy(d_a, a, size, cudaMemcpyHostToDevice);
    cudaMemcpy(d_b, b, size, cudaMemcpyHostToDevice);

    // Launch add() kernel on GPU
    int numBlocks = n;
    int numThreads = 1;

    addVecs<<<numBlocks, numThreads>>>(d_a, d_b, d_c, n);

    //Copy result to host
    cudaMemcpy(c, d_c, size, cudaMemcpyDeviceToHost);
    printf("Result : \n");
    for (int i=0; i<n; i++)
        printf("%d\n", c[i]);

    //Cleanup
    cudaFree(d_a);
    cudaFree(d_b);
    cudaFree(d_c);

    return 0;
}