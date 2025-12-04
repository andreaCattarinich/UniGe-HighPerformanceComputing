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

    // Choose between 1D | 2D
    mandelbrot_kernel_1D<<<grid, block>>>(
        image_dev, WIDTH, HEIGHT, STEP, ITERATIONS, MIN_X, MIN_Y
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
