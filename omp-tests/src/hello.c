#include <omp.h>
#include <stdio.h>

int main() {

    printf("N. max thread disponibili: %d\n", omp_get_max_threads());
    
    #pragma omp parallel
    {
        printf(" hello ");
        printf(" world\n");
    }
    return 0;
}