#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <cuda_runtime.h>

#define N 1024  // Maximum length of sentence
#define M 32    // Maximum length of word

// CUDA kernel to count word occurrences
__global__ void CUDAWordCount(char *sentence, char *word, unsigned int *d_count, int sentence_len, int word_len) {
    int idx = threadIdx.x + blockIdx.x * blockDim.x;

    if (idx <= sentence_len - word_len) {
        int match = 1;
        for (int j = 0; j < word_len; j++) {
            if (sentence[idx + j] != word[j]) {
                match = 0;
                break;
            }
        }
        if (match) {
            atomicAdd(d_count, 1);
        }
    }
}

int main() {
    char sentence[N], word[M];
    char *d_sentence, *d_word;
    unsigned int *d_count, *result;

    result = (unsigned int *)malloc(sizeof(unsigned int));

    printf("Enter a sentence: ");
    fgets(sentence, N, stdin);
    sentence[strcspn(sentence, "\n")] = '\0';  // Remove newline

    printf("Enter the word to count: ");
    scanf("%s", word);

    int sentence_len = strlen(sentence);
    int word_len = strlen(word);

    // Allocate device memory
    cudaMalloc((void **)&d_sentence, N * sizeof(char));
    cudaMalloc((void **)&d_word, M * sizeof(char));
    cudaMalloc((void **)&d_count, sizeof(unsigned int));

    // Copy data to device
    cudaMemcpy(d_sentence, sentence, N * sizeof(char), cudaMemcpyHostToDevice);
    cudaMemcpy(d_word, word, M * sizeof(char), cudaMemcpyHostToDevice);
    cudaMemset(d_count, 0, sizeof(unsigned int));

    // Launch kernel
    int threadsPerBlock = 256;
    int blocks = (sentence_len + threadsPerBlock - 1) / threadsPerBlock;

    CUDAWordCount<<<blocks, threadsPerBlock>>>(d_sentence, d_word, d_count, sentence_len, word_len);

    // Copy result back
    cudaMemcpy(result, d_count, sizeof(unsigned int), cudaMemcpyDeviceToHost);

    printf("The word '%s' occurs %u times.\n", word, *result);

    // Free memory
    cudaFree(d_sentence);
    cudaFree(d_word);
    cudaFree(d_count);
    free(result);

    return 0;
}