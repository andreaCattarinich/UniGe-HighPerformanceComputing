#include <stdio.h>
#include <omp.h>

#define VECSIZE 1000
#define ITERATIONS 1000000

int main()
{
  float a[VECSIZE], b[VECSIZE];
  float sum;
  unsigned long i, j;

  double begin, end;

  for(i=0;i<VECSIZE;i++) {
    a[i]=1.0;
    b[i]=0.0000001;
  }

  begin=omp_get_wtime();
  for(j=0;j<ITERATIONS;j++){
    for(i=0;i<VECSIZE;i++) {
      a[i]=a[i]+b[i];
    } 
  }
  end=omp_get_wtime();

  sum=0.0;
  for(i=0;i<VECSIZE;i++) {
    sum+=a[i];
  }

  printf("Addition took %f seconds\n",end-begin);
  printf("Sum of vector is %20.12f\n",sum);
}
