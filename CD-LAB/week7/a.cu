#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <cuda_runtime.h>

#define N 100  // maximum length of input string

// CUDA kernel to generate RS string
__global__ void generateRS(char *input, char *output, int len) {
    int idx = threadIdx.x + blockIdx.x * blockDim.x;

    int pos = 0;

    for (int i = 0; i < len; i++) {
        if (idx < len - i) {
            output[pos + idx] = input[idx];
        }
        pos += (len - i);
        __syncthreads();
    }
}

int main() {
    char input[N];
    char *d_input, *d_output;
    int len;

    printf("Enter the string: ");
    scanf("%s", input);

    len = strlen(input);
    int output_len = len * (len + 1) / 2; // total length of RS

    char *output = (char *)malloc(output_len + 1); // +1 for null terminator

    // Allocate device memory
    cudaMalloc((void **)&d_input, len * sizeof(char));
    cudaMalloc((void **)&d_output, output_len * sizeof(char));

    // Copy input string to device
    cudaMemcpy(d_input, input, len * sizeof(char), cudaMemcpyHostToDevice);

    // CUDA events for timing
    cudaEvent_t start, stop;
    cudaEventCreate(&start);
    cudaEventCreate(&stop);
    cudaEventRecord(start, 0);

    // Launch kernel
    int threadsPerBlock = 256;
    int blocks = (len + threadsPerBlock - 1) / threadsPerBlock;
    generateRS<<<blocks, threadsPerBlock>>>(d_input, d_output, len);

    cudaEventRecord(stop, 0);
    cudaEventSynchronize(stop);

    // Check for kernel errors
    cudaError_t error = cudaGetLastError();
    if (error != cudaSuccess) {
        printf("CUDA Kernel Error: %s\n", cudaGetErrorString(error));
    }

    // Copy result back
    cudaMemcpy(output, d_output, output_len * sizeof(char), cudaMemcpyDeviceToHost);
    output[output_len] = '\0';

    // Calculate elapsed time
    float elapsedTime;
    cudaEventElapsedTime(&elapsedTime, start, stop);

    printf("Output RS: %s\n", output);
    printf("Time Taken = %f ms\n", elapsedTime);

    // Free memory
    cudaFree(d_input);
    cudaFree(d_output);
    free(output);

    return 0;
}