# Vectorization

**Compiler**
- Compiler stages: pre-processing (#define #include #ifdef #if), source-to-object, linking to create an executable
- Compiler optimization options (icc): -O0, -O1, -O2, -O3, etc...

**Vectorization** SIMD applied:
```c
for (int i = 0; i < 4; i++) {
    // Before
    c[i] = a[i] + b[i];  // 1 operation at time

    // After
    c[0:3] = a[0:3] + b[0:3];  // 4 operations by once!
}
```

CPU registers:
- Standard: 64 bit -> 1 number
- Vectorial (SIMD)
  - 128 bit (SSE):      4 floats  | 2 double  [pag. 2.3.25]
  - 256 bit (AVX2):     8 floats  | 4 double
  - 512 bit (AVX512):   16 floats | 8 double

Automatic:
```bash
# Compile with con -O2 o -O3
icc -O2 mio_programma.c
```

Developer:
```bash
#pragma omp simd
for (int i = 0; i < N; i++) {
    c[i] = a[i] + b[i];
}
```

**Requirements for vectorization** [pag 2.3.26]:
- Number of loop iterations is known before
- No dependencies
    ```c
    // a[i] usa a[i-1] dell'iterazione precedente
    for (int i = 1; i < N; i++) {
        a[i] = a[i-1] + b[i];  // NON vectorizzabile
    }
    ```
- Simple operations (+ - * /)
- No function calls
    ```c
    for (int i = 0; i < N; i++) {
        a[i] = funzione_complessa(b[i]);  // Probabilmente non vectorizzabile
    }
    ```

## Vectorization Report [2.3.27]:
The vectorization report is a compiler report that shows which loops are or are not vectorized and why.

Related command: `-qopt-report-phase=vec` or `=openmp` or `par`.

Reports are written to files `.optrpt`

### Usage
`-qopt-report=\<n>`, with n from 0 to 5:
- 0: None
- 1: Lists vectorized loops
- 2: 1 + Lists loops not vectorized, with explanation



---
## RAW (Read After Write) - Flow dependency
Non è vettorizzabile
```c
for (int i = 1; i < N; i++) {
    a[i] = a[i-1] + b[i];  // RAW: leggi a[i-1] che è stato scritto nell'iterazione precedente
}
```

## WAR (Write After Read) - Anti dependency
E' vettorizzabile
```c
for (int i = 0; i < N-1; i++) {
    a[i] = a[i+1] + b[i];  // WAR: leggi a[i+1] poi sovrascrivi a[i]
}
```

## WAW (Write After Write) - Output dependency
Non è vettorizzabile
```c
for (int i = 0; i < N; i++) {
    a[i % 2] = b[i] + c[i];  // WAW: sovrascrivi continuamente a[0] e a[1]
}

// Input: b = [1, 2, 3, 4], c = [5, 6, 7, 8]

// SCALARE (corretto):
Iter 0: a[0] = 1 + 5 = 6
Iter 1: a[1] = 2 + 6 = 8
Iter 2: a[0] = 3 + 7 = 10  ← Sovrascrive 6
Iter 3: a[1] = 4 + 8 = 12  ← Sovrascrive 8
// Risultato: a = [10, 12]

// VETTORIALE (sbagliato):
// Se faccio 4 iterazioni insieme, quale valore va in a[0]?
// 6 o 10?
// Il risultato sarebbe non deterministico!
```

---


