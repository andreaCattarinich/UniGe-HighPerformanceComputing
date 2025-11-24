#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <cuda.h>
#include <cuda_runtime.h>
#include <chrono>

// Simple define to index into a 1D array from 2D space
#define I2D(num, c, r) ((r)*(num)+(c))

/*
 * `step_kernel_mod` is currently a direct copy of the CPU reference solution
 * `step_kernel_ref` below. Accelerate it to run as a CUDA kernel.
 */

__global__ void step_kernel_mod(int ni, int nj, float fact, float* temp_in, float* temp_out)
{
  int i00, im10, ip10, i0m1, i0p1;
  float d2tdx2, d2tdy2;

  int i = threadIdx.x + blockIdx.x * blockDim.x; // colonna globale
  int j = threadIdx.y + blockIdx.y * blockDim.y; // riga globale

  if(i > 0 && i < ni-1 && j > 0 && j < nj-1){
    // find indices into linear memory
    // for central point and neighbours
    i00 = I2D(ni, i, j);
    im10 = I2D(ni, i-1, j);
    ip10 = I2D(ni, i+1, j);
    i0m1 = I2D(ni, i, j-1);
    i0p1 = I2D(ni, i, j+1);

    // evaluate derivatives
    d2tdx2 = temp_in[im10]-2*temp_in[i00]+temp_in[ip10];
    d2tdy2 = temp_in[i0m1]-2*temp_in[i00]+temp_in[i0p1];

    // update temperatures
    temp_out[i00] = temp_in[i00]+fact*(d2tdx2 + d2tdy2);
  }
}

void step_kernel_ref(int ni, int nj, float fact, float* temp_in, float* temp_out)
{
  int i00, im10, ip10, i0m1, i0p1;
  float d2tdx2, d2tdy2;


  // loop over all points in domain (except boundary)
  for ( int j=1; j < nj-1; j++ ) {
    for ( int i=1; i < ni-1; i++ ) {
      // find indices into linear memory
      // for central point and neighbours
      i00 = I2D(ni, i, j);
      im10 = I2D(ni, i-1, j);
      ip10 = I2D(ni, i+1, j);
      i0m1 = I2D(ni, i, j-1);
      i0p1 = I2D(ni, i, j+1);

      // evaluate derivatives
      d2tdx2 = temp_in[im10]-2*temp_in[i00]+temp_in[ip10];
      d2tdy2 = temp_in[i0m1]-2*temp_in[i00]+temp_in[i0p1];

      // update temperatures
      temp_out[i00] = temp_in[i00]+fact*(d2tdx2 + d2tdy2);
    }
  }
}

int main()
{   
    auto _start_entire = std::chrono::high_resolution_clock::now();

    int istep;
    int nstep = 200; // number of time steps

    // Specify our 2D dimensions
    const int ni = 20000;
    const int nj = 20000;
    float tfac = 8.418e-5; // thermal diffusivity of silver

    float* temp1_ref, * temp2_ref, * temp1, * temp2, * temp_tmp;
    float* d_temp1, * d_temp2;

    const int size = ni * nj * sizeof(float);

    printf("Simulation parameters:\n");
	printf("nstep    = %d\n", nstep);
	printf("ni       = %d\n", ni);
	printf("nj       = %d\n", nj);
    printf("size     = %d\n", size);

    // Allocate host memory
#if DEBUG
    printf("Allocate host memory...\n");
#endif
    temp1_ref = (float*)malloc(size);
    temp2_ref = (float*)malloc(size);
    temp1 = (float*)malloc(size);
    temp2 = (float*)malloc(size);

    // Initialize with random data
#if DEBUG
    printf("Initialize with random data...\n");
#endif
    for (int i = 0; i < ni * nj; i++) {
        temp1_ref[i] = temp2_ref[i] = temp1[i] = temp2[i] = (float)rand() / (float)(RAND_MAX / 100.0f);
    }

    // Allocate device memory 
#if DEBUG
    printf("Allocate device memory...\n");
#endif
    cudaMalloc((void**)&d_temp1, size);
    cudaMalloc((void**)&d_temp2, size);

    // Transfer data from host to device memory
#if DEBUG
    printf("Transfer data from host to device memory...\n");
#endif
    cudaMemcpy(d_temp1, temp1, size, cudaMemcpyHostToDevice);
    cudaMemcpy(d_temp2, temp2, size, cudaMemcpyHostToDevice);

    // ---- CPU start ----
    auto _start = std::chrono::high_resolution_clock::now();

    // Execute the CPU-only reference version
    printf("Execute the CPU-only reference version...\n");
    for (istep = 0; istep < nstep; istep++) {
        step_kernel_ref(ni, nj, tfac, temp1_ref, temp2_ref);
        
        // swap the temperature pointers
        temp_tmp = temp1_ref;
        temp1_ref = temp2_ref;
        temp2_ref = temp_tmp;
    }

    auto _end = std::chrono::high_resolution_clock::now();
    std::chrono::duration<double> elapsed = _end - _start;
    printf("- Elapsed time: %.3f s\n", elapsed.count());
    // ---- CPU end ----

    dim3 threadsPerBlock(16, 16);
    dim3 numBlocks((ni + 15) / 16, (nj + 15) / 16);
    //dim3 threadsPerBlock(32, 16);
    //dim3 numBlocks((ni + 31) / 32, (nj + 7) / 8);



    // ---- CUDA events start ----
    cudaEvent_t start, stop;
    cudaEventCreate(&start);
    cudaEventCreate(&stop);

    // Execute the modified version using same data
    printf("Execute GPU kernel...\n");
    cudaEventRecord(start, 0); // start timing

    for (istep = 0; istep < nstep; istep++) {
        step_kernel_mod <<<numBlocks, threadsPerBlock>>> (ni, nj, tfac, d_temp1, d_temp2);
        cudaDeviceSynchronize();

        cudaError_t err = cudaGetLastError();
        if (err != cudaSuccess)
            printf("CUDA Error: %s\n", cudaGetErrorString(err));
        
        // swap dei puntatori GPU
        float* d_tmp = d_temp1;
        d_temp1 = d_temp2;
        d_temp2 = d_tmp;
    }

    cudaEventRecord(stop, 0); // stop timing
    cudaEventSynchronize(stop);

    float ms;
    cudaEventElapsedTime(&ms, start, stop);
    printf("- Elapsed time: %.3f ms\n", ms);

    cudaEventDestroy(start);
    cudaEventDestroy(stop);
    // ---- CUDA events end ----
    
    // Transfer data back to host memory
#if DEBUG
    printf("Transfer data back to host memory...\n");
#endif
    cudaMemcpy(temp1, d_temp1, size, cudaMemcpyDeviceToHost);
    cudaMemcpy(temp2, d_temp2, size, cudaMemcpyDeviceToHost);

    float maxError = 0;
    // Output should always be stored in the temp1 and temp1_ref at this point
    for (int i = 0; i < ni * nj; i++) {
        float diff = fabs(temp1[i] - temp1_ref[i]);
        if (diff > maxError) maxError = diff;
    }

    printf("Max Error = %.6f\n", maxError);
    if (maxError > 0.0005f)
        printf("Problem! The Max Error of %.5f is NOT within ACCEPTABLE bounds.\n", maxError);
    else
        printf("The Max Error of %.5f is within ACCEPTABLE bounds.\n", maxError);

    // Deallocate device memory
#if DEBUG
    printf("Deallocate device memory...\n");
#endif
    cudaFree(d_temp1);
    cudaFree(d_temp2);

    free(temp1_ref);
    free(temp2_ref);
    free(temp1);
    free(temp2);

    //printf("Fine programma, premere invio per uscire...\n");
    //getchar();

    auto _end_entire = std::chrono::high_resolution_clock::now();
    elapsed = _end_entire - _start_entire;
    printf("- Total elapsed time: %.3f s\n", elapsed.count());

    return 0;
}