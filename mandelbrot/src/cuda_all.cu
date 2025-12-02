#include <iostream>
#include <fstream>
#include <cuda_runtime.h>

#define MIN_X -2
#define MAX_X 1
#define MIN_Y -1
#define MAX_Y 1

#define RATIO_X (MAX_X - MIN_X)
#define RATIO_Y (MAX_Y - MIN_Y)

#define RESOLUTION 10000
#define WIDTH (RATIO_X * RESOLUTION)
#define HEIGHT (RATIO_Y * RESOLUTION)
#define STEP ((double)RATIO_X / WIDTH)

#define ITERATIONS 100

using namespace std;

// Kernel Mandelbrot 1D
__global__ void mandelbrot_kernel_1D(int *image, int width, int height,
                                  double step, int iterations,
                                  double min_x, double min_y)
{
    int pos = blockIdx.x * blockDim.x + threadIdx.x;
    int size = width * height;

    if (pos >= size) return;

    int row = pos / width;
    int col = pos % width;

    double cRe = col * step + min_x;
    double cIm = row * step + min_y;

    double zRe = 0, zIm = 0;

    for (int i = 1; i <= iterations; i++)
    {
        double oldRe = zRe;
        zRe = (zRe*zRe - zIm*zIm) + cRe;
        zIm = 2 * oldRe * zIm + cIm;

        if (zRe*zRe + zIm*zIm >= 4.0)
        {
            image[pos] = i;
            return;
        }
    }

    image[pos] = 0;
}

// Kernel Mandelbrot 2D
__global__ void mandelbrot_kernel_2D(int *image, int width, int height,
                                     double step, int iterations,
                                     double min_x, double min_y)
{
    // coordinate globali del thread
    int col = threadIdx.x + blockIdx.x * blockDim.x;
    int row = threadIdx.y + blockIdx.y * blockDim.y;

    if (col >= width || row >= height) return;

    int pos = row * width + col;

    double cRe = col * step + min_x;
    double cIm = row * step + min_y;

    double zRe = 0, zIm = 0;

    for (int i = 1; i <= iterations; i++)
    {
        double oldRe = zRe;
        zRe = zRe * zRe - zIm * zIm + cRe;
        zIm = 2 * oldRe * zIm + cIm;

        if (zRe * zRe + zIm * zIm >= 4.0)
        {
            image[pos] = i;
            return;
        }
    }

    image[pos] = 0;
}


int main()
{
    const int N = WIDTH * HEIGHT;
    cout << "WIDTH=" << WIDTH << " HEIGHT=" << HEIGHT << endl;

    int *image_host = new int[N];
    int *image_dev;

    cudaMalloc(&image_dev, N * sizeof(int));

    cudaEvent_t start, stop;
    cudaEventCreate(&start);
    cudaEventCreate(&stop);

    // inizio misurazione
    cudaEventRecord(start);

    dim3 block(256);
    dim3 grid((N + block.x - 1) / block.x);

    // dim3 block(16,16);
    // dim3 grid((WIDTH + block.x - 1)/block.x, (HEIGHT + block.y - 1)/block.y);

    // Choose between 1D | 2D
    mandelbrot_kernel_1D<<<grid, block>>>(
        image_dev, WIDTH, HEIGHT, STEP, ITERATIONS, MIN_X, MIN_Y
    );
    
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
