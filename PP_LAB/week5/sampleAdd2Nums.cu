/*
Program to add 2 numbers

nvcc <name>.cu -o <name>
./<name>
*/

#include <stdio.h>

#include "cuda_runtime.h"
#include "device_launch_parameters.h"

__global__ void add(int *a, int *b, int *c){
    *c = *a+*b;
}

int main(void){
    int a, b, c;            //Host copies
    int *d_a, *d_b, *d_c;   //Device copies
    int size = sizeof(int);

    //Allocating space for device copies
    cudaMalloc((void **)&d_a, size);
    cudaMalloc((void **)&d_b, size);
    cudaMalloc((void **)&d_c, size);

    a = 3;
    b = 5;

    //Copy to device
    cudaMemcpy(d_a, &a, size, cudaMemcpyHostToDevice);
    cudaMemcpy(d_b, &b, size, cudaMemcpyHostToDevice);

    // Launch add() kernel on GPU
    add<<<1, 1>>>(d_a, d_b, d_c);

    //Copy result to host
    cudaMemcpy(&c, d_c, size, cudaMemcpyDeviceToHost);
    printf("Result : %d \n", c);

    //Cleanup
    cudaFree(d_a);
    cudaFree(d_b);
    cudaFree(d_c);

    return 0;
}