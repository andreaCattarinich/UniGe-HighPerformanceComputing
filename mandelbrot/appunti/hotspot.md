# Hotspots Analysis

- Compilato senza ottimizzazioni
```sh
icpx -O0 -fopenmp -g -xHost \
	-qopt-report=max \
	-qopt-report-file=reports/mandelbrot-O0.optrpt \
	src/mandelbrot.cpp -o build/mandelbrot-O0
```



- Compilato con ottimizzazioni:
```sh
icpx -O2 -fopenmp -g -xHost \
	-qopt-report=max \
	-qopt-report-file=reports/mandelbrot-O2.optrpt \
	src/mandelbrot.cpp -o build/mandelbrot-O2
```

---

## Test over HP envy
### WSL:
Compilation: `g++ -o build/mandelbrot src/mandelbrot.cpp`

Execution: `./build/mandelbrot`

ITERATION 100
RESOLUTION 1000, `-O0`, 15 s
RESOLUTION 2000, `-O0`, 64 s (1 min 4 s)
RESOLUTION 2000, `-O2`, 9 s

### Windows
Compilation (open x64 Native Tools Command Prompt VS 2022) and run `cl src\mandelbrot.cpp /Fe:build\mandelbrot.exe`

Execution: `build\mandelbrot`

RESOLUTION 1000, 74 s (1 min 24 s)
RESOLUTION 2000, 301 s (5 min 1 s)
RESOLUTION 2000, `/O2`, 301 s (5 min 1 s)
RESOLUTION 2000, `/O2 /EHsc`, 101 s (1 min 41 s)
RESOLUTION 2000, `/O2 /arch:AVX2 /fp:fast /EHsc`, 103 s (1 min 43 s)

Conclusioni:
L'istruzione `z = pow(z, 2) + c` non viene ottimizzata da MSVC