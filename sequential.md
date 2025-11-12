# Decisione del data size (N=60000)

Per deciderlo ho dovuto eseguire la compilazione con diverse opzioni di ottimizzazione (vedi [Makefile.seq](/homework1/Makefile.seq)).

Compilazione:
```bash
make -f Makefile.seq all
```

Esecuzione:
```bash
./build/omp_homework_O1 # 110.091782 seconds
./build/omp_homework_O2 # 32.549948 seconds
./build/omp_homework_O3 # 32.643375 seconds

./build/omp_homework_O2_xHost # 13.646404 seconds
./build/omp_homework_O2_native # 14.762813 seconds
```

Aumento N e mantengo l'ottimizzazione O2 xHost
N = 80000, 24.316571 sec
N = 90000, 30.710730 sec
N = 100000, 37.875294 sec

Provo con O2 -march=native
N = 100000, 41.325764 sec

---

