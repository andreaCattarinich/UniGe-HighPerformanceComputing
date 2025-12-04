#include <iostream>
#include <fstream>
#include <cuda_runtime.h>

// Ranges of the set
#define MIN_X -2
#define MAX_X 1
#define MIN_Y -1
#define MAX_Y 1

// Image ratio
#define RATIO_X (MAX_X - MIN_X)
#define RATIO_Y (MAX_Y - MIN_Y)

// Image size
#define RESOLUTION 5000
#define WIDTH (RATIO_X * RESOLUTION)
#define HEIGHT (RATIO_Y * RESOLUTION)

#define STEP ((float)RATIO_X / WIDTH)


#define ITERATIONS 100

using namespace std;

// Kernel Mandelbrot 1D
__global__ void mandelbrot_kernel_1D(int *image, int width, int height,
                                  float step, int iterations,
                                  float min_x, float min_y)
{
    int pos = blockIdx.x * blockDim.x + threadIdx.x;
    int size = width * height;

    if (pos >= size) return;

    int row = pos / width;
    int col = pos % width;

    float cRe = float(col) * step + min_x;
    float cIm = float(row) * step + min_y;

    float zRe = 0.f, zIm = 0.f;

    for (int i = 1; i <= iterations; i++)
    {
        float oldRe = zRe;
        zRe = (zRe*zRe - zIm*zIm) + cRe;
        zIm = 2 * oldRe * zIm + cIm;

        if (zRe*zRe + zIm*zIm >= 4.f)
        {
            image[pos] = i;
            return;
        }
    }

    image[pos] = 0;
}

int main()
{
    cout << "RESOLUTION   = " << RESOLUTION << endl;
    cout << "ITERATION    = " << ITERATIONS << endl;
    cout << "HEIGHT       = " << HEIGHT << endl;
    cout << "WIDTH        = " << WIDTH << endl;
    cout << "HEIGHT*WIDTH = " << HEIGHT*WIDTH << endl;

    const int N = WIDTH * HEIGHT;
    int *image_host = new int[N];
    int *image_dev;

    cudaMalloc(&image_dev, N * sizeof(int));

    cudaEvent_t start, stop;
    cudaEventCreate(&start);
    cudaEventCreate(&stop);

    // inizio misurazione
    cudaEventRecord(start);

    // ==== 1D ====
    dim3 block(256);
    dim3 grid((N + block.x - 1) / block.x);

    mandelbrot_kernel_1D<<<grid, block>>>(
        image_dev, WIDTH, HEIGHT, STEP, ITERATIONS, (float)MIN_X, (float)MIN_Y
    );
    
    cudaError_t err = cudaGetLastError();
    if (err != cudaSuccess) {
        cout << "CUDA ERROR: " << cudaGetErrorString(err) << endl;
        return 1;
    }

    // fine misurazione
    cudaEventRecord(stop);
    cudaDeviceSynchronize();
    
    float milliseconds = 0;
    cudaEventElapsedTime(&milliseconds, start, stop);

    cout << "GPU kernel time: " << milliseconds << " ms" << endl;

    cudaEventDestroy(start);
    cudaEventDestroy(stop);
    
    cudaMemcpy(image_host, image_dev, N * sizeof(int), cudaMemcpyDeviceToHost);

    long sum = 0;
    for (int i = 0; i < N; ++i)
        sum += image_host[i];

    cout << "Checksum = " << sum << endl;

    cudaFree(image_dev);
    delete[] image_host;

    return 0;
}
