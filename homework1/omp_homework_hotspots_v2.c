#include "stdio.h" // printf
#include "stdlib.h" // malloc and rand for instance. Rand not thread safe!
#include "time.h"   // time(0) to get random seed
#include "math.h"  // sine and cosine
#include "omp.h"   // openmp library like timing

// two pi
#define PI2 6.28318530718
#define R_ERROR 0.01

int DFT(int idft, double* xr, double* xi, double* Xr_o, double* Xi_o, int N);
int fillInput(double* xr, double* xi, int N);
int setOutputZero(double* Xr_o, double* Xi_o, int N);
int checkResults(double* xr, double* xi, double* xr_check, double* xi_check, double* Xr_o, double* Xi_r, int N);
int printResults(double* xr, double* xi, int N);


int main(int argc, char* argv[]){
  // size of input array
  int N = 40000;
  printf("DFTW calculation with N = %d \n",N);

  double start_entire_program;
  double start, end;

  start_entire_program = omp_get_wtime();

  
  // -- FILL INPUT --
  double* xr = (double*) malloc (N *sizeof(double));
  double* xi = (double*) malloc (N *sizeof(double));
  start = omp_get_wtime();
  fillInput(xr,xi,N);
  end = omp_get_wtime();
  printf("- fillInput() time: %.10f seconds\n", end-start);


  // -- SET OUTPUT ZERO 1--
  double* xr_check = (double*) malloc (N *sizeof(double));
  double* xi_check = (double*) malloc (N *sizeof(double));
  start = omp_get_wtime();
  setOutputZero(xr_check,xi_check,N);
  end = omp_get_wtime();
  printf("- setOutputZero1() time: %.10f seconds\n", end-start);

  // -- SET OUTPUT ZERO 2--
  double* Xr_o = (double*) malloc (N *sizeof(double));
  double* Xi_o = (double*) malloc (N *sizeof(double));
  start = omp_get_wtime();
  setOutputZero(Xr_o,Xi_o,N);
  end = omp_get_wtime();
  printf("- setOutputZero2() time: %.10f seconds\n", end-start);

  // -- DFT --
  int idft = 1;
  start = omp_get_wtime();
  DFT(idft,xr,xi,Xr_o,Xi_o,N);
  end = omp_get_wtime();
  printf("- DFT() time: %.10f seconds\n", end-start);

  // -- IDFT --
  idft = -1;
  start = omp_get_wtime();
  DFT(idft,Xr_o,Xi_o,xr_check,xi_check,N);
  end = omp_get_wtime();
  printf("- IDFT() time: %.10f seconds\n", end-start);

  // -- CHECK RESULTS --
  // check the results: easy to make correctness errors with openMP
  start = omp_get_wtime();
  checkResults(xr,xi,xr_check,xi_check,Xr_o, Xi_o, N);
  end = omp_get_wtime();
  printf("- checkResults() time: %.10f seconds\n", end-start);

  // -- PRINT RESULTS --
  // print the results of the DFT
#ifdef DEBUG
  start = omp_get_wtime();
  printResults(Xr_o,Xi_o,N);
  end = omp_get_wtime();
  printf("- printResults() time: %.10f seconds\n", end-start);
#endif

  // take out the garbage
  free(xr);
  free(xi);
  free(Xi_o);
  free(Xr_o);
  free(xr_check);
  free(xi_check);


  end = omp_get_wtime();
  printf("Total time: %.10f seconds\n", end-start_entire_program);

  return 1;
}

// DFT/IDFT routine
// idft: 1 direct DFT, -1 inverse IDFT (Inverse DFT)
int DFT(int idft, double* xr, double* xi, double* Xr_o, double* Xi_o, int N){
  int k, n;
  for (k=0 ; k<N ; k++)
  {
      for (n=0 ; n<N ; n++)  {
        // Real part of X[k]
          Xr_o[k] += xr[n] * cos(n * k * PI2 / N) + idft*xi[n]*sin(n * k * PI2 / N);
          // Imaginary part of X[k]
          Xi_o[k] += -idft*xr[n] * sin(n * k * PI2 / N) + xi[n] * cos(n * k * PI2 / N);

      }
  }

  // normalize if you are doing IDFT
  if (idft==-1){
    for (n=0 ; n<N ; n++){
      Xr_o[n] /=N;
      Xi_o[n] /=N;
    }
  }
  return 1;
}

// set the initial signal
// be careful with this
// rand() is NOT thread safe in case
int fillInput(double* xr, double* xi, int N){
  int n;
  srand(time(0));
  for(n=0; n < 100000;n++) // get some random number first
    rand();
  for(n=0; n < N;n++){
     // Generate random discrete-time signal x in range (-1,+1)
     //xr[n] = ((double)(2.0 * rand()) / RAND_MAX) - 1.0;
     //xi[n] = ((double)(2.0 * rand()) / RAND_MAX) - 1.0;
     // constant real signal
     xr[n] = 1.0;
     xi[n] = 0.0;
  }
  return 1;
}

// set to zero the output vector
int setOutputZero(double* Xr_o, double* Xi_o, int N){
  int n;
  for(n=0; n < N;n++){
     Xr_o[n] = 0.0;
     Xi_o[n] = 0.0;
  }
  return 1;
}

// check if x = IDFT(DFT(x))
int checkResults(double* xr, double* xi, double* xr_check, double* xi_check, double* Xr_o, double* Xi_r, int N){
  int n;
  for(n=0; n < N;n++){
    if (fabs(xr[n] - xr_check[n]) > R_ERROR)
      printf("ERROR - x[%d] = %f, inv(X)[%d]=%f \n",n,xr[n], n,xr_check[n]);
      if (fabs(xi[n] - xi_check[n]) > R_ERROR)
      printf("ERROR - x[%d] = %f, inv(X)[%d]=%f \n",n,xi[n], n,xi_check[n]);

    }
    printf("Xre[0] = %f \n",Xr_o[0]);
    return 1;
}

// print the results of the DFT
int printResults(double* xr, double* xi, int N){
  int n;
  for(n=0; n < N;n++)
      printf("Xre[%d] = %f, Xim[%d] = %f \n", n, xr[n], n, xi[n]);
  return 1;
}
