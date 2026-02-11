#include <stdio.h>
#include "cuda_runtime.h"
#include "device_launch_parameters.h"

__global__ void add(int *a, int *b, int *c) {
    *c = *a + *b;
}

int main(void) {
    int a, b, c;
    int *d_a, *d_b, *d_c;
    int size = sizeof(int);

    // Allocate space for device copies of a, b, c
    cudaMalloc((void **)&d_a, size);
    cudaMalloc((void **)&d_b, size);
    cudaMalloc((void **)&d_c, size);

    // Initialize host variables
    a = 3;
    b = 5;

    // Copy the host variables to device
    cudaMemcpy(d_a, &a, size, cudaMemcpyHostToDevice);
    cudaMemcpy(d_b, &b, size, cudaMemcpyHostToDevice);

    // Launch the kernel
    add<<<1, 1>>>(d_a, d_b, d_c);

    // Copy the result back to the host
    cudaMemcpy(&c, d_c, size, cudaMemcpyDeviceToHost);

    // Print the result
    printf("Result: %d\n", c);

    // Free the device memory
    cudaFree(d_a);
    cudaFree(d_b);
    cudaFree(d_c);

    return 0;
}
