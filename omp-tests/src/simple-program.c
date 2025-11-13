#include <omp.h>
#include <stdio.h>
#include <stdlib.h>

int main () {
    int tid, nthreads;
    
    #pragma omp parallel private(tid)
    {
        tid = omp_get_thread_num();
        printf("Hello World from thread %d\n", tid);
        
        //#pragma omp barrier
        if ( tid == 0 ) {
            nthreads = omp_get_num_threads();
            printf("Total threads= %d\n",nthreads);
        }
    }
}