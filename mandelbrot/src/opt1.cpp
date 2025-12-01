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
#define RESOLUTION 10000
#define WIDTH (RATIO_X * RESOLUTION)
#define HEIGHT (RATIO_Y * RESOLUTION)

#define STEP ((double)RATIO_X / WIDTH)

#define DEGREE 2        // Degree of the polynomial
#define ITERATIONS 100 // Maximum number of iterations

using namespace std;

int main(int argc, char **argv)
{   
    const auto start_entire = chrono::steady_clock::now();
    
    cout << "RESOLUTION   = " << RESOLUTION << endl;
    cout << "ITERATION    = " << ITERATIONS << endl;
    cout << "HEIGHT*WIDTH = " << HEIGHT*WIDTH << endl;
    
    int *const image = new int[HEIGHT * WIDTH];

    const auto start_par = chrono::steady_clock::now();
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
    const auto end_par = chrono::steady_clock::now();    

    long sum = 0;
    for (int i = 0; i < HEIGHT*WIDTH; ++i)
        sum += image[i];

    cout << "Checksum: " << sum << endl;

    const auto end_entire = chrono::steady_clock::now();    
    delete[] image;

    auto Ts = chrono::duration_cast<chrono::milliseconds>(end_entire - start_entire).count() -
                   chrono::duration_cast<chrono::milliseconds>(end_par - start_par).count();
    
    auto Tp = chrono::duration_cast<chrono::milliseconds>(end_par - start_par).count();
    auto Ttot = chrono::duration_cast<chrono::milliseconds>(end_entire - start_entire).count();
    
    double Fs = (double)Ts / Ttot;
    double Fp = (double)Tp / Ttot;
    
    cout << "Time elapsed: " << Ttot << endl;
    cout << "Tp = " << Tp << " ms | Fp = " << Fp << endl;
    cout << "Ts = " << Ts << " ms | Fs = " << Fs << endl;

    return 0;
}