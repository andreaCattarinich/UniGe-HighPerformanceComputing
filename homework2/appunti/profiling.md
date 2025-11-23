# Profiling performance
Using `time` does not give much information about the program performance. NVIDIA provides a commandline profiler tool called `nvprof`, which give a more insight information of CUDA program performance.


Example: `!nvprof ./vector_add`

```text
==18119== NVPROF is profiling process 18119, command: ./vector_add
out[0] = 3.000000
PASSED
==18119== Profiling application: ./vector_add
==18119== Profiling result:
            Type  Time(%)      Time     Calls       Avg       Min       Max  Name
 GPU activities:   59.19%  24.978ms         1  24.978ms  24.978ms  24.978ms  [CUDA memcpy DtoH]
                   39.71%  16.759ms         2  8.3795ms  8.3172ms  8.4417ms  [CUDA memcpy HtoD]
                    1.09%  461.56us         1  461.56us  461.56us  461.56us  vector_add(float*, float*, float*, int)
      API calls:   65.54%  90.151ms         3  30.050ms  81.898us  89.978ms  cudaMalloc
                   31.25%  42.981ms         3  14.327ms  8.5090ms  25.797ms  cudaMemcpy
                    2.61%  3.5848ms         3  1.1949ms  373.00us  2.0456ms  cudaFree
                    0.34%  462.33us         1  462.33us  462.33us  462.33us  cudaDeviceSynchronize
                    0.13%  184.25us       114  1.6160us     148ns  73.137us  cuDeviceGetAttribute
                    0.11%  152.03us         1  152.03us  152.03us  152.03us  cudaLaunchKernel
                    0.01%  14.459us         1  14.459us  14.459us  14.459us  cuDeviceGetName
                    0.01%  8.8800us         1  8.8800us  8.8800us  8.8800us  cuDeviceGetPCIBusId
                    0.00%  1.7270us         3     575ns     175ns  1.3060us  cuDeviceGetCount
                    0.00%  1.1940us         2     597ns     184ns  1.0100us  cuDeviceGet
                    0.00%     717ns         1     717ns     717ns     717ns  cudaGetLastError
                    0.00%     568ns         1     568ns     568ns     568ns  cuDeviceTotalMem
                    0.00%     427ns         1     427ns     427ns     427ns  cuModuleGetLoadingMode
                    0.00%     307ns         1     307ns     307ns     307ns  cuDeviceGetUuid
```