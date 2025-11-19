#include <stdio.h>
#include <omp.h>

#define VECSIZE 1000
#define ITERATIONS 1000000

void update_final(double *x, double *y, int vecsize, int iters);

int main()
{
  double a[VECSIZE], b[VECSIZE];
  double sum;
  unsigned long i, j;

  double begin, end;

  for(i=0;i<VECSIZE;i++) {
    a[i]=1.0;
    b[i]=0.0000001;
  }

  begin=omp_get_wtime();
  update_final(a,b,VECSIZE,ITERATIONS);
  end=omp_get_wtime();

  sum=0.0;
  for(i=0;i<VECSIZE;i++) {
    sum+=a[i];
  }

  printf("Addition took %f seconds\n",end-begin);
  printf("Sum of vector is %20.12f\n",sum);
}
