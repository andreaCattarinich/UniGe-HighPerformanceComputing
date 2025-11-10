# Profiling and Tuning

First step for improving the performance of a program is the profiling, to understand where are the **hotspots**.

Esistono diversi *profiler*, noi dobbiamo usare [**Intel VTune**](https://www.intel.com/content/www/us/en/developer/tools/oneapi/vtune-profiler.html). Ci sono diversi [tutorial qui](https://www.intel.com/content/www/us/en/docs/vtune-profiler/user-guide/2023-0/tutorials-and-samples.html)


### Come usare i computer delle aule 210, SW1 e SW2
- Inserire le credenziali UniGe Pass
- Impostare il *path*: `source /opt/intel/oneapi/setvars.sh`
- Avviare Intel VTune (GUI): `vtune-gui
  
### Compilare l'eseguibile
`gcc -O2 -fopenmp omp_homework_hotspots_v1.c -lm -o omp_homework_hotspots_v1`

- Creare un nuovo progetto
- Importare l'eseguibile