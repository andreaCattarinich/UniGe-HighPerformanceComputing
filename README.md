# UniGe-HighPerformanceComputing

--- 
## Homeworks:
1. [OpenMP](https://2024.aulaweb.unige.it/mod/assign/view.php?id=41695)
2. [CUDA](https://2024.aulaweb.unige.it/mod/assign/view.php?id=41718)
3. [MPI](https://2024.aulaweb.unige.it/mod/assign/view.php?id=41746)


## Esame
Scrivere un report (vedere i requirements negli Homeworks) dell'analisi del codice e il processo utilizzato per parallelizzare il codice.

Come scrivere il report:
- **speedup** 1.1.21
- **efficienza** 1.1.21
- **legge di Amdahl** 1.1.22
- describe always the compute capability of the resource you are using;
- use ICC/ICX on our workstations, GCC with Colab;
- use the BEST sequential execution time;
- always provide the compilation and execution commands (e.g. icc -O3 -xHost...);
- consider different and meaningful data sizes (i.e. no sequential execution time shorter than a few seconds).  


1. Fare gli homework: OpenMP, CUDA (e MPI)

2. Parallelizzare in OpenMP, CUDA (e MPI) il [Mandelbrot program](https://2024.aulaweb.unige.it/pluginfile.php/131000/mod_resource/content/3/mandelbrot.cpp).

3. Parallelizzare un algoritmo (da proporre)



## Studio
- Architettura dei calcolatori (pipeling, cache, memoria)
- Compilatori **gcc**, **icc**, **nvcc**
- Parallel computing

### Performance Metrics
T(n,p) è il tempo per risolvere un problema di dimensione *n* utilizzando *p* processors.

**Speedup**:    S(n,p) = T(n,1)/T(n,p)

**Efficiency**: E(n,p) = S(n,p)/p

**Amdahl's Law**: TODO: studiarla
Maximal Speedup = 1/(1-P) 
Speedup = 1 / ( (P/N) + S)

Dove: N=numero dei processori, S=serial portion of code


