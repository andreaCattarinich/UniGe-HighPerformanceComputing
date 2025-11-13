TODO:

1. parallelizzare il ciclo esterno con `#pragma omp parallel for`
    ottimo per CPU con pochi core
```bash
cd homework1$
export OMP_NUM_THREADS=4 # TODO provare tutti i thread fino a 32 (per 10 volte ciascuno)
make -f Makefile.omp
./build/v1
```

2. parallelizzare il ciclo interno con `#pragma omp parallel for reduction(+:Xr_temp, Xi_temp)`

3. parallelizzare entrambi con i punti 1 e 2


---

Risultati (1)

OMP_NUM_THREADS=1  | Ts = 37.993380  | 
OMP_NUM_THREADS=4  | Tp = 9.496761   | S = 
OMP_NUM_THREADS=8  | Tp = 6.009077   | 
OMP_NUM_THREADS=16 | Tp = 5.430242   | 
OMP_NUM_THREADS=24 | Tp = 4.462963   | 
OMP_NUM_THREADS=32 | Tp = 4.262066   | 

