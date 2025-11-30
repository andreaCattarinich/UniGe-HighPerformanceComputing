#include <iostream>
#include <fstream>
#include <chrono>

// Ranges of the set
#define MIN_X -2
#define MAX_X 1
#define MIN_Y -1
#define MAX_Y 1

// Image ratio
#define RATIO_X (MAX_X - MIN_X) // 3
#define RATIO_Y (MAX_Y - MIN_Y) // 2

// Image size
#define RESOLUTION 2000
#define WIDTH (RATIO_X * RESOLUTION)
#define HEIGHT (RATIO_Y * RESOLUTION)

#define STEP ((double)RATIO_X / WIDTH)

#define DEGREE 2        // Degree of the polynomial
#define ITERATIONS 1000 // Maximum number of iterations

using namespace std;

int main(int argc, char **argv)
{
    cout << "RESOLUTION   = " << RESOLUTION << endl;
    cout << "ITERATION    = " << ITERATIONS << endl;
    cout << "HEIGHT*WIDTH = " << HEIGHT*WIDTH << endl;
    
    int *const image = new int[HEIGHT * WIDTH];

    const auto start = chrono::steady_clock::now();
    
    #pragma omp parallel for
    for (int pos = 0; pos < HEIGHT * WIDTH; pos++)
    {
        image[pos] = 0;

        const int row = pos / WIDTH;
        const int col = pos % WIDTH;

        double cRe = col * STEP + MIN_X;
        double cIm = row * STEP + MIN_Y;

        // z = z^2 + c
        double zRe = 0, zIm = 0;
        for (int i = 1; i <= ITERATIONS; i++)
        {
            double oldRe = zRe;
            zRe = (zRe*zRe - zIm*zIm) + cRe;
            zIm = 2*oldRe*zIm + cIm;

            // If it is convergent
            if(zRe*zRe + zIm*zIm >= 4)
            {
                image[pos] = i;
                break;
            }
        }
    }
    const auto end = chrono::steady_clock::now();
    cout << "Time elapsed: "
         << chrono::duration_cast<chrono::seconds>(end - start).count()
         << " seconds." << endl;

    delete[] image;
    return 0;
}