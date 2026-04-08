/*
2. Write a program in CUDA to perform selection sort in parallel.
*/

#include <stdio.h>
#include <stdlib.h>

#include "cuda_runtime.h"
#include "device_launch_parameters.h"

__global__ void parallelSort(int *arr, int n) {
    
    int tid = blockIdx.x*blockDim.x + threadIdx.x;
    int pos = 0;
    int data = arr[tid];

    if (tid > n-1 ) return;

    for (int i = 0; i<n; i++)
        if (arr[i] < data || (arr[i] == data && i < tid))
            pos++;
    arr[pos] = data;
}

int main(void){
    int n;
    int *d_a;

    printf("Enter length of Array : ");
    scanf("%d", &n);

    int size = sizeof(int)*n;

    int *a = (int*)malloc(size);
    
    cudaMalloc((void **)&d_a, size);
    
    printf("Elements of Array : \n");
    for (int i=0; i<n; i++)
        scanf("%d", &a[i]);

    cudaMemcpy(d_a, a, size, cudaMemcpyHostToDevice);
    
    dim3 dimGrid(ceil(n/256.0), 1, 1);
    dim3 dimBlock(256, 1, 1);

    parallelSort<<<dimGrid, dimBlock>>>(d_a, n);

    cudaMemcpy(a, d_a, size, cudaMemcpyDeviceToHost);
    printf("Result : \n");
    for (int i=0; i<n; i++)
        printf("%d\n", a[i]);

    cudaFree(d_a);
    return 0;
}