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
Compilation: `g++ -o build/mandelbrot src/mandelbrot.cp`

Execution: `./build/mandelbrot`

RESOLUTION 1000, 15 secs
RESOLUTION 10000,  secs

### Windows
Compilation (open x64 Native Tools Command Prompt VS 2022) and run `cl src\mandelbrot.cpp /Fe:build\mandelbrot.exe`

Execution: `build\mandelbrot`

RESOLUTION 1000, 74 secs
RESOLUTION 10000,  secs