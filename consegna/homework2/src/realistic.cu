#include <stdio.h>
#include <stdlib.h>
#include <cuda.h>

#define I2D(num, c, r) ((r)*(num)+(c))

__global__ void step_kernel_mod(int ni, int nj, float fact, float* temp_in, float* temp_out)
{
    int i = threadIdx.x + blockIdx.x * blockDim.x;
    int j = threadIdx.y + blockIdx.y * blockDim.y;

    if(i > 0 && i < ni-1 && j > 0 && j < nj-1){
        int i00 = I2D(ni, i, j);
        int im10 = I2D(ni, i-1, j);
        int ip10 = I2D(ni, i+1, j);
        int i0m1 = I2D(ni, i, j-1);
        int i0p1 = I2D(ni, i, j+1);

        float d2tdx2 = temp_in[im10]-2*temp_in[i00]+temp_in[ip10];
        float d2tdy2 = temp_in[i0m1]-2*temp_in[i00]+temp_in[i0p1];

        temp_out[i00] = temp_in[i00] + fact*(d2tdx2 + d2tdy2);
    }
}

int main()
{
    int nstep = 100000;
    int step = 250;
    const int ni = 100;
    const int nj = 100;
    float tfac = 0.01f;

    float temp1[ni*nj], temp2[ni*nj], *temp_tmp;
    float *d_temp1, *d_temp2;

    // Initialize random temperatures
    //for(int i=0;i<ni*nj;i++) temp1[i] = temp2[i] = (float)rand()/RAND_MAX*100.0f;

    // parametri del quadrato caldo
    int hot_size = 40;                   // lato del quadrato caldo
    int hot_temp = 80;                  // temperatura del quadrato caldo
    int hot_i0 = ni/2 - hot_size/2;     // centro in i
    int hot_j0 = nj/2 - hot_size/2;     // centro in j

    for(int j = 0; j < nj; j++){
        for(int i = 0; i < ni; i++){

            int idx = I2D(ni, i, j);

            // controlla se siamo nel quadrato caldo centrale
            if(i >= hot_i0 && i < hot_i0 + hot_size &&
            j >= hot_j0 && j < hot_j0 + hot_size)
            {
                temp1[idx] = temp2[idx] = (float)hot_temp;   // fonte di calore
            }
            else
            {
                temp1[idx] = temp2[idx] = (float)rand() / RAND_MAX * 30.0f; // ambiente random
            }
        }
    }

    cudaMalloc((void**)&d_temp1, ni*nj*sizeof(float));
    cudaMalloc((void**)&d_temp2, ni*nj*sizeof(float));
    cudaMemcpy(d_temp1, temp1, ni*nj*sizeof(float), cudaMemcpyHostToDevice);
    cudaMemcpy(d_temp2, temp2, ni*nj*sizeof(float), cudaMemcpyHostToDevice);

    dim3 threads(16,16);
    dim3 blocks((ni+15)/16, (nj+15)/16);

    // crea cartella se non esiste
    system("mkdir -p sim");

    for(int istep=0; istep<nstep; istep++){
        step_kernel_mod<<<blocks, threads>>>(ni, nj, tfac, d_temp1, d_temp2);
        cudaDeviceSynchronize();

        // swap puntatori
        float* d_tmp = d_temp1;
        d_temp1 = d_temp2;
        d_temp2 = d_tmp;
        
        // copia dati e salva in bin
        cudaMemcpy(temp1, d_temp1, ni*nj*sizeof(float), cudaMemcpyDeviceToHost);
        
        if ( istep % step == 0) {
            char fname[64];
            sprintf(fname, "sim/temp_step_%02d.bin", istep);
            FILE *fp = fopen(fname, "wb");
            fwrite(temp1, sizeof(float), ni*nj, fp);
            fclose(fp);
        }
    }

    cudaFree(d_temp1);
    cudaFree(d_temp2);

    return 0;
}
