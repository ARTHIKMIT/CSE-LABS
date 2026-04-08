#include "cuda_runtime.h"
#include "device_launch_parameters.h"

#include <stdio.h>
#include <stdlib.h>

__global__ void rowPower(int *A, int rows, int cols) {
    int row = threadIdx.x + blockIdx.x * blockDim.x;

    if (row < rows) {
        int power = row + 1;

        for (int col = 0; col < cols; col++) {
            int val = A[row * cols + col];
            int result = 1;

            for (int i = 0; i < power; i++)
                result *= val;

            A[row * cols + col] = result;
        }
    }
}

int main() {
    int rows, cols;

    printf("Enter number of rows and columns: ");
    scanf("%d %d", &rows, &cols);

    int size = rows * cols * sizeof(int);

    int *A = (int*)malloc(size);

    printf("Enter matrix elements:\n");
    for (int i = 0; i < rows * cols; i++)
        scanf("%d", &A[i]);

    int *d_A;
    cudaMalloc((void**)&d_A, size);

    cudaMemcpy(d_A, A, size, cudaMemcpyHostToDevice);

    int blockSize = 256;
    int gridSize = (rows + blockSize - 1) / blockSize;

    rowPower<<<gridSize, blockSize>>>(d_A, rows, cols);

    cudaMemcpy(A, d_A, size, cudaMemcpyDeviceToHost);

    printf("\nResult matrix:\n");
    for (int i = 0; i < rows; i++) {
        for (int j = 0; j < cols; j++)
            printf("%d ", A[i * cols + j]);
        printf("\n");
    }

    cudaFree(d_A);
    free(A);

    return 0;
}
