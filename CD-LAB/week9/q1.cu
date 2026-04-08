#include "cuda_runtime.h"
#include "device_launch_parameters.h"

#include <stdio.h>
#include <stdlib.h>

__global__ void csrSpMV(int *values, int *colIndex, int *rowPtr, int *x, int *y, int rows) {

    int row = threadIdx.x + blockIdx.x * blockDim.x;

    if (row < rows) {
        int sum = 0;
        for (int j = rowPtr[row]; j < rowPtr[row + 1]; j++)
            sum += values[j] * x[colIndex[j]];
        y[row] = sum;
    }
}

int main() {
    int rows, cols;

    printf("Enter number of rows and columns: ");
    scanf("%d %d", &rows, &cols);

    int **matrix = (int**)malloc(rows * sizeof(int*));
    for (int i = 0; i < rows; i++)
        matrix[i] = (int*)malloc(cols * sizeof(int));

    printf("Enter matrix elements:\n");
    for (int i = 0; i < rows; i++)
        for (int j = 0; j < cols; j++)
            scanf("%d", &matrix[i][j]);

    int nnz = 0;
    for (int i = 0; i < rows; i++)
        for (int j = 0; j < cols; j++)
            if (matrix[i][j] != 0)
                nnz++;

    int *values = (int*)malloc(nnz * sizeof(int));
    int *colIndex = (int*)malloc(nnz * sizeof(int));
    int *rowPtr = (int*)malloc((rows + 1) * sizeof(int));

    // dense → CSR
    int k = 0;
    rowPtr[0] = 0;

    for (int i = 0; i < rows; i++) {
        for (int j = 0; j < cols; j++) {
            if (matrix[i][j] != 0) {
                values[k] = matrix[i][j];
                colIndex[k] = j;
                k++;
            }
        }
        rowPtr[i + 1] = k;
    }

    int *x = (int*)malloc(cols * sizeof(int));
    int *y = (int*)malloc(rows * sizeof(int));

    printf("Enter vector x:\n");
    for (int i = 0; i < cols; i++)
        scanf("%d", &x[i]);

    int *d_values, *d_colIndex, *d_rowPtr, *d_x, *d_y;

    cudaMalloc((void**)&d_values, nnz * sizeof(int));
    cudaMalloc((void**)&d_colIndex, nnz * sizeof(int));
    cudaMalloc((void**)&d_rowPtr, (rows + 1) * sizeof(int));
    cudaMalloc((void**)&d_x, cols * sizeof(int));
    cudaMalloc((void**)&d_y, rows * sizeof(int));

    cudaMemcpy(d_values, values, nnz * sizeof(int), cudaMemcpyHostToDevice);
    cudaMemcpy(d_colIndex, colIndex, nnz * sizeof(int), cudaMemcpyHostToDevice);
    cudaMemcpy(d_rowPtr, rowPtr, (rows + 1) * sizeof(int), cudaMemcpyHostToDevice);
    cudaMemcpy(d_x, x, cols * sizeof(int), cudaMemcpyHostToDevice);

    int blockSize = 256;
    int gridSize = (rows + blockSize - 1) / blockSize;

    csrSpMV<<<gridSize, blockSize>>>(d_values, d_colIndex, d_rowPtr,
                                    d_x, d_y, rows);

    cudaMemcpy(y, d_y, rows * sizeof(int), cudaMemcpyDeviceToHost);

    printf("\nResult vector y:\n");
    for (int i = 0; i < rows; i++)
        printf("%d ", y[i]);

    cudaFree(d_values);
    cudaFree(d_colIndex);
    cudaFree(d_rowPtr);
    cudaFree(d_x);
    cudaFree(d_y);

    for (int i = 0; i < rows; i++)
        free(matrix[i]);
    free(matrix);

    free(values);
    free(colIndex);
    free(rowPtr);
    free(x);
    free(y);

    return 0;
}
