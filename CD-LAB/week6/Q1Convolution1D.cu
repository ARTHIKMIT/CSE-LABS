/*
1. Write a program in CUDA which performs convolution operation on one dimensional input array of size width using a mask array M of size mask_width to produce the resultant one dimensional array P of size width.

1D Sequential Convolution
Convolution :
array operation that is used in various forms in signal processing, digital recording, image processing, video processing, and computer vision.
Mathematically, each output data element is a weighted sum of a collection of neighboring input elements.
weights used in the weighted sum calculation - convolution mask OR convolution kernel.

*/

#include <stdio.h>
#include <stdlib.h>

#include "cuda_runtime.h"
#include "device_launch_parameters.h"

__global__ void convolution1D(float *N, float *M, float *P, int Mask_Width, int Width) {
    
    int i = blockIdx.x*blockDim.x + threadIdx.x;
    
    if (i >= Width) return;

    float Pvalue = 0;
    int N_startpoint = i - (Mask_Width/2);
    
    for (int j = 0; j < Mask_Width; j++) 
        if (N_startpoint + j >= 0 && N_startpoint + j < Width)
            Pvalue += N[N_startpoint + j]*M[j];
    
    P[i] = Pvalue;
}

int main(void){
    int n, m;
    float *d_a, *d_b, *d_c;

    printf("Enter length of Array : ");
    scanf("%d", &n);

    printf("Enter length of Convolution mask : ");
    scanf("%d", &m);

    int sizeN = sizeof(float)*n, sizeM = sizeof(float)*m;


    
    float *a = (float*)malloc(sizeN);
    float *b = (float*)malloc(sizeM);
    float *c = (float*)malloc(sizeN);

    cudaMalloc((void **)&d_a, sizeN);
    cudaMalloc((void **)&d_b, sizeM);
    cudaMalloc((void **)&d_c, sizeN);

    printf("Elements of Array 1 : \n");
    for (int i=0; i<n; i++)
        scanf("%f", &a[i]);

    printf("Elements of Array 2 : \n");
    for (int i=0; i<m; i++)
        scanf("%f", &b[i]);

    cudaMemcpy(d_a, a, sizeN, cudaMemcpyHostToDevice);
    cudaMemcpy(d_b, b, sizeM, cudaMemcpyHostToDevice);

    dim3 dimGrid(ceil(n/256.0), 1, 1);
    dim3 dimBlock(256, 1, 1);

    convolution1D<<<dimGrid, dimBlock>>>(d_a, d_b, d_c, m, n);

    cudaMemcpy(c, d_c, sizeN, cudaMemcpyDeviceToHost);
    printf("Result : \n");
    for (int i=0; i<n; i++)
        printf("%f\n", c[i]);

    cudaFree(d_a);
    cudaFree(d_b);
    cudaFree(d_c);

    return 0;
}