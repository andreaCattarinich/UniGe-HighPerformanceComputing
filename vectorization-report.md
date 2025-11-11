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
main() Function:
```text

LOOP BEGIN at omp_homework_vectorization-report.c(73,7) inlined into omp_homework_vectorization-report.c(43,5)
   remark #25460: No loop optimizations reported

   LOOP BEGIN at omp_homework_vectorization-report.c(71,3) inlined into omp_homework_vectorization-report.c(43,5)
   <Peeled loop for vectorization>
   LOOP END

   LOOP BEGIN at omp_homework_vectorization-report.c(71,3) inlined into omp_homework_vectorization-report.c(43,5)
      remark #15301: PERMUTED LOOP WAS VECTORIZED
   LOOP END

   LOOP BEGIN at omp_homework_vectorization-report.c(71,3) inlined into omp_homework_vectorization-report.c(43,5)
   <Remainder loop for vectorization>
   LOOP END
LOOP END

LOOP BEGIN at omp_homework_vectorization-report.c(73,7) inlined into omp_homework_vectorization-report.c(46,5)
   remark #25460: No loop optimizations reported

   LOOP BEGIN at omp_homework_vectorization-report.c(71,3) inlined into omp_homework_vectorization-report.c(46,5)
   <Peeled loop for vectorization>
   LOOP END

   LOOP BEGIN at omp_homework_vectorization-report.c(71,3) inlined into omp_homework_vectorization-report.c(46,5)
      remark #15301: PERMUTED LOOP WAS VECTORIZED
   LOOP END

   LOOP BEGIN at omp_homework_vectorization-report.c(71,3) inlined into omp_homework_vectorization-report.c(46,5)
   <Remainder loop for vectorization>
   LOOP END
LOOP END
```

DTF() Function:
```text
===========================================================================

Begin optimization report for: DFT(int, double *, double *, double *, double *, int)

    Report from: Vector optimizations [vec]


LOOP BEGIN at omp_homework_vectorization-report.c(84,5)
<Peeled loop for vectorization, Multiversioned v1>
LOOP END

LOOP BEGIN at omp_homework_vectorization-report.c(84,5)
<Multiversioned v1>
   remark #15300: LOOP WAS VECTORIZED
LOOP END

LOOP BEGIN at omp_homework_vectorization-report.c(84,5)
<Alternate Alignment Vectorized Loop, Multiversioned v1>
LOOP END

LOOP BEGIN at omp_homework_vectorization-report.c(84,5)
<Remainder loop for vectorization, Multiversioned v1>
   remark #15301: REMAINDER LOOP WAS VECTORIZED
LOOP END

LOOP BEGIN at omp_homework_vectorization-report.c(84,5)
<Remainder loop for vectorization, Multiversioned v1>
LOOP END

LOOP BEGIN at omp_homework_vectorization-report.c(84,5)
<Multiversioned v2>
LOOP END

LOOP BEGIN at omp_homework_vectorization-report.c(84,5)
<Remainder, Multiversioned v2>
LOOP END
===========================================================================
```

Conclusions:





