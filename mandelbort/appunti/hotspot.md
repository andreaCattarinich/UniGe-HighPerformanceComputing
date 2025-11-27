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