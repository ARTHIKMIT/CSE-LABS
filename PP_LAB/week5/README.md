# CUDA

## Host
Host : CPU
Host Memory : CPU Memory
Runs Serial Code

## Device
Device : GPU
Device Memory : GPU Memory
Runs Parallel code

1. Copy data from Host to Device Mem
2. Load Device Program and execute
3. Copy result from Device to Host Mem

## Threads, Blocks and Grid

### Thread :
- Distributed by CUDA runtime
- A single path of execution
- There can be multiple threads in a program

### Block : 
- 