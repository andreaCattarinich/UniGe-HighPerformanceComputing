## Vectorization Report [2.3.27]:
The vectorization report is a compiler report that shows which loops are or are not vectorized and why.

<!-- TODO: aggiungere al report questa parte -->
Since the Intel(R) C++ Compiler Classic (ICC) is deprecated and was removed from product release in the second half of 2023. The Intel(R) oneAPI DPC++/C++ Compiler (ICX) was used to performe the analysis.
<!-- -->

### Usage
Normal compilation, plus some parameters
```bash
icc
    -O2 
    omp_homework_hotspots_v2.c
    -o omp_homework_hotspots_v2
```

Choose your prefered level of explanation.
`-qopt-report=\<n>`, with n from 0 to 5:
- 0: None
- 1: Lists vectorized loops
- 2: 1 + Lists loops not vectorized, with explanation
- 3:
- 4: 
- 5:

Choose which optimation part to show. Reports are written to files `.optrpt`.
`-qopt-report-phase=...` can be:
- `=vec` (ICC) | `-fopt-info-vec` (ICX)
- `=openmp`
- `=par` 


---

# Test on 210 WORKSTATION
Command
```bash
icc
    -O2
    -qopt-report=1 -qopt-report-phase=vec omp_homework_vectorization-report.c
```

Output in the file `omp_homework_vectorization.optrpt`:
### main() Function:

Parte importante - loop vettorizzato:
```text
LOOP BEGIN at omp_homework_vectorization-report.c(73,7) inlined into omp_homework_vectorization-report.c(46,5)
   remark #15542: loop was not vectorized: inner loop was already vectorized

   LOOP BEGIN at omp_homework_vectorization-report.c(71,3) inlined into omp_homework_vectorization-report.c(46,5)
   <Peeled loop for vectorization>
   LOOP END

   LOOP BEGIN at omp_homework_vectorization-report.c(71,3) inlined into omp_homework_vectorization-report.c(46,5)
      remark #15389: vectorization support: reference xi_check[k] has unaligned access   [ omp_homework_vectorization-report.c(77,11) ]
      remark #15389: vectorization support: reference xi_check[k] has unaligned access   [ omp_homework_vectorization-report.c(77,11) ]
      remark #15388: vectorization support: reference xr_check[k] has aligned access   [ omp_homework_vectorization-report.c(75,11) ]
      remark #15388: vectorization support: reference xr_check[k] has aligned access   [ omp_homework_vectorization-report.c(75,11) ]
      remark #15381: vectorization support: unaligned access used inside loop body
      remark #15305: vectorization support: vector length 2
      remark #15309: vectorization support: normalized vectorization overhead 0.123
      remark #15301: PERMUTED LOOP WAS VECTORIZED
      remark #15442: entire loop may be executed in remainder
      remark #15448: unmasked aligned unit stride loads: 1 
      remark #15449: unmasked aligned unit stride stores: 1 
      remark #15450: unmasked unaligned unit stride loads: 1 
      remark #15451: unmasked unaligned unit stride stores: 1 
      remark #15475: --- begin vector cost summary ---
      remark #15476: scalar cost: 563 
      remark #15477: vector cost: 130.000 
      remark #15478: estimated potential speedup: 4.320 
      remark #15482: vectorized math library calls: 2 
      remark #15486: divides: 2 
      remark #15487: type converts: 2 
      remark #15488: --- end vector cost summary ---
   LOOP END

   LOOP BEGIN at omp_homework_vectorization-report.c(71,3) inlined into omp_homework_vectorization-report.c(46,5)
   <Remainder loop for vectorization>
   LOOP END
LOOP END
```

### DTF() Function:
**Importan part of the report!!! Fa riferimento al main hotspot**
```text
Begin optimization report for: DFT(int, double *, double *, double *, double *, int)

    Report from: Vector optimizations [vec]


LOOP BEGIN at omp_homework_vectorization-report.c(71,3)
   remark #15541: outer loop was not auto-vectorized: consider using SIMD directive

   LOOP BEGIN at omp_homework_vectorization-report.c(73,7)
      remark #15344: loop was not vectorized: vector dependence prevents vectorization
      remark #15346: vector dependence: assumed OUTPUT dependence between Xr_o[k] (75:11) and Xi_o[k] (77:11)
      remark #15346: vector dependence: assumed OUTPUT dependence between Xi_o[k] (77:11) and Xr_o[k] (75:11)
   LOOP END
LOOP END
```


Meno importante...
```text
LOOP BEGIN at omp_homework_vectorization-report.c(84,5)
<Peeled loop for vectorization, Multiversioned v1>
LOOP END

LOOP BEGIN at omp_homework_vectorization-report.c(84,5)
<Multiversioned v1>
   remark #15388: vectorization support: reference Xr_o[n] has aligned access   [ omp_homework_vectorization-report.c(85,7) ]
   remark #15388: vectorization support: reference Xr_o[n] has aligned access   [ omp_homework_vectorization-report.c(85,7) ]
   remark #15388: vectorization support: reference Xi_o[n] has aligned access   [ omp_homework_vectorization-report.c(86,7) ]
   remark #15388: vectorization support: reference Xi_o[n] has aligned access   [ omp_homework_vectorization-report.c(86,7) ]
   remark #15305: vectorization support: vector length 2
   remark #15399: vectorization support: unroll factor set to 4
   remark #15309: vectorization support: normalized vectorization overhead 0.064
   remark #15300: LOOP WAS VECTORIZED
   remark #15442: entire loop may be executed in remainder
   remark #15448: unmasked aligned unit stride loads: 2 
   remark #15449: unmasked aligned unit stride stores: 2 
   remark #15475: --- begin vector cost summary ---
   remark #15476: scalar cost: 63 
   remark #15477: vector cost: 35.000 
   remark #15478: estimated potential speedup: 1.770 
   remark #15486: divides: 2 
   remark #15488: --- end vector cost summary ---
LOOP END

LOOP BEGIN at omp_homework_vectorization-report.c(84,5)
<Alternate Alignment Vectorized Loop, Multiversioned v1>
LOOP END

LOOP BEGIN at omp_homework_vectorization-report.c(84,5)
<Remainder loop for vectorization, Multiversioned v1>
   remark #15389: vectorization support: reference Xr_o[n] has unaligned access   [ omp_homework_vectorization-report.c(85,7) ]
   remark #15389: vectorization support: reference Xr_o[n] has unaligned access   [ omp_homework_vectorization-report.c(85,7) ]
   remark #15388: vectorization support: reference Xi_o[n] has aligned access   [ omp_homework_vectorization-report.c(86,7) ]
   remark #15388: vectorization support: reference Xi_o[n] has aligned access   [ omp_homework_vectorization-report.c(86,7) ]
   remark #15381: vectorization support: unaligned access used inside loop body
   remark #15305: vectorization support: vector length 2
   remark #15309: vectorization support: normalized vectorization overhead 0.247
   remark #15301: REMAINDER LOOP WAS VECTORIZED
   remark #15442: entire loop may be executed in remainder
LOOP END

LOOP BEGIN at omp_homework_vectorization-report.c(84,5)
<Remainder loop for vectorization, Multiversioned v1>
LOOP END

LOOP BEGIN at omp_homework_vectorization-report.c(84,5)
<Multiversioned v2>
   remark #15304: loop was not vectorized: non-vectorizable loop instance from multiversioning
LOOP END

LOOP BEGIN at omp_homework_vectorization-report.c(84,5)
<Remainder, Multiversioned v2>
LOOP END
===========================================================================
```

## Conclusions:
Some parts are vectorized, but the main hotspot (DFT) is not vectorized due to the dependence.

About DFT() function: compilator found a dependence between `Xr_o[k]` and `Xi_o[k]`;


<!-- TODO: applicare queste soluzioni possibili: -->
Possible solutions:
1. Tell the compiler that the two vectors are independent, using keyword `restric`:
   ```c
   int DFT(..., double* restrict Xr_o, double* restrict Xi_o) {
      /* CODE */
   }
   ```
2. Add an esplicit directive:
   ```c
   #pragma simd
   //or
   #pragma omp simd
   ```
   Forza la vectorization anche in presenza di dipendenze presunte (usa con cautela, solo se sei sicuro che non ci siano conflitti)

<!-- TODO:
Gestire meglio la compilazione!
- fare un Makefile per la compilazione automatica
- così posso cambiare i parametri in modo semplice e veloce
- i risultati della compilazione possono essere salvati automaticamente in diverse cartelle
- 
 
-->

<!-- TODO: passare a ICX -->