# CUDA

## Obiettivi
- Portare il codice che calcola la 2D heat conduction su GPU usando CUDA
- eseguire esperimenti su Google Colab (GPU) variando configurazioni <<<block,thread>>>

## TODO List
- [ ] define the BEST sequential time to be used as reference
- [ ] present the performance using Google colab
- [ ] provide tables and charts regarding speedup values only
- [ ] discuss conclusions
- [x] Template report
- [ ] CUDA Profiling 

## CUDA Toolkit
Mandatory if I want to develop the project on my personal Windows/WSL workstation.
Link: [https://developer.nvidia.com/cuda-downloads?target_os=Windows&target_arch=x86_64&target_version=10&target_type=exe_local](https://developer.nvidia.com/cuda-downloads?target_os=Windows&target_arch=x86_64&target_version=10&target_type=exe_local)

## Google Colab
1. Nuovo notebook Colab -> Runtime -> Change runtime type -> T4 GPU -> Connect (vedi [immagine](/5137057-reports/cuda/assets/google_colab/colab-risorse.png))
   
2. Connessione a Google Drive per ottenere la persistenza dei dati
    ```python
    from google.colab import drive
    drive.mount('/content/drive')
    ```

    Percorso dei file: `content/drive/MyDrive/Colab Notebooks/HPC-CUDA`

    Utilizzo:

        - `!ls "$ROOT"`
        - `!nvcc "$ROOT/devicequery/devicequery.cu" -o "$ROOT/devicequery/devicequery"`
3. Compute capabilities GPU Colab
   Comandi per ottenerle:
   - **Compute capability (1)**: `!"$ROOT/devicequery/devicequery"`
   - **Compute capability (2)**: `!nvidia-smi --query-gpu=name,driver_version,compute_cap --format=csv !nvidia-smi --query-gpu=name,driver_version,compute_cap --format=csv`

    I due comandi forniscono le `compute capability della GPU Colab`.

    Informazioni importanti:
    - **GPU individuata**: Device 0: "Tesla T4", CUDA Capability: 7.5
      - Significa che devo compilare con: `nvcc -arch=sm_75 -O3 heat_cuda.cu -o heat_cuda`
    - **Memoria globale**: Total amount of global memory: 15095 MB
    - SM e CUDA cores (per parallelismo): Multiprocessors: 40, CUDA Cores/MP: 64, Totale CUDA Cores = 2560


## CUDA profiling
See [profiling.md](/homework2/appunti/profiling.md)

### CUDA Single Thread
```c
__global__
void add(int n, float *x, float *y) {
    for (int i = 0; i < n; i++)
        y[i] = x[i] + y[i];
}

// Lancio kernel
add<<<1, 1>>>(N, x, y);
```
- Solo **1 thread** esegue tutto il lavoro.
- **Nessun parallelismo**

### CUDA Single Block
```c
__global__
void add(int n, float *x, float *y) {
    int index = threadIdx.x;       // indice nel blocco
    int stride = blockDim.x;       // numero di thread nel blocco

    for (int i = index; i < n; i += stride)
        y[i] = x[i] + y[i];
}

// Lancio kernel
int blockSize = 256;
add<<<1, blockSize>>>(N, x, y);
```
- 1 blocco, 256 thread.
- Ogni thread lavora su una “striscia” di elementi separati.
- index = 0..255, in particular:
```text
Thread 0: parte da 0      256 512 768
Thread 1: parte da 1      257 513 769
Thread 2: parte da 2      258 514 770
...
Thread 255: parte da 255  511 767 1023
```
- stride = 256 → Thread 0 processa 0, 256, 512…

Cosa fa:
- Parallelismo dentro un blocco.
- Copre più velocemente l’array, ma solo un SM è utilizzato

---

`<<1, 1>>`is called execution configuration, and tells the CUDA runtime how many parallel threads to use for the launch on the GPU.

- Param 1
- Param 2: number of threads in a thread block (multiple of 32)

Example of usage:
```c
add<<1, 256>>(N, x, y);

__global__
void add(int n, float *x, float *y)
{
  int index = threadIdx.x;
  int stride = blockDim.x;
  for (int i = index; i < n; i += stride)
      y[i] = x[i] + y[i];
}
```
- `threadIdx.x` contains the index of the current thread within its block
- `blockDim.x` contains the number of threads in the block.

---

### CUDA Multiple Blocks
```c
__global__
void add(int n, float *x, float *y) {
    int index = blockIdx.x * blockDim.x + threadIdx.x; // indice globale
    int stride = blockDim.x * gridDim.x;              // stride globale

    for (int i = index; i < n; i += stride)
        y[i] = x[i] + y[i];
}

// Lancio kernel
int blockSize = 256;
int numBlocks = (N + blockSize - 1) / blockSize; // arrotonda per eccesso
add<<<numBlocks, blockSize>>>(N, x, y);
```
- Più blocchi, ogni blocco ha 256 thread
- Tutti i thread della GPU lavorano.
- Copre array di qualunque dimensione, sfruttando tutti gli SM.
