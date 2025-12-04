#include <iostream>
#include <fstream>
#include <complex>
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
#define RESOLUTION 5000
#define WIDTH (RATIO_X * RESOLUTION)
#define HEIGHT (RATIO_Y * RESOLUTION)

#define STEP ((double)RATIO_X / WIDTH)

#define DEGREE 2        // Degree of the polynomial
#define ITERATIONS 100 // Maximum number of iterations

using namespace std;

int main(int argc, char **argv)
{
    cout << "RESOLUTION   = " << RESOLUTION << endl;
    cout << "ITERATION    = " << ITERATIONS << endl;
    cout << "HEIGHT*WIDTH = " << HEIGHT*WIDTH << endl;
    
    int *const image = new int[HEIGHT * WIDTH];

    const auto start = chrono::steady_clock::now();
    for (int pos = 0; pos < HEIGHT * WIDTH; pos++)
    {
        image[pos] = 0;

        const int row = pos / WIDTH;
        const int col = pos % WIDTH;

        double cRe = col * STEP + MIN_X;
        double cIm = row * STEP + MIN_Y;

        double zRe = 0, zIm = 0;
        for (int i = 1; i <= ITERATIONS; i++)
        {
            double oldRe = zRe;
            double zRe2 = zRe*zRe; // Re(z)^2
            double zIm2 = zIm*zIm; // Im(z)^2

            zRe = (zRe2 - zIm2) + cRe;
            zIm = 2*oldRe*zIm + cIm;

            if(zRe2 + zIm2 >= 4)
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

    // WRITE THE RESULT TO A FILE
    /*
    ofstream matrix_out;

    if (argc < 2)
    {
        cout << "Please specify the output file as a parameter." << endl;
        return -1;
    }

    matrix_out.open(argv[1], ios::trunc);
    if (!matrix_out.is_open())
    {
        cout << "Unable to open file." << endl;
        return -2;
    }

    for (int row = 0; row < HEIGHT; row++)
    {
        for (int col = 0; col < WIDTH; col++)
        {
            matrix_out << image[row * WIDTH + col];

            if (col < WIDTH - 1)
                matrix_out << ',';
        }
        if (row < HEIGHT - 1)
            matrix_out << endl;
    }
    matrix_out.close();
    */

    delete[] image; // It's here for coding style, but useless
    return 0;
}