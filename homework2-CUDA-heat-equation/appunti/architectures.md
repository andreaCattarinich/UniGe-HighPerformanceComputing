## Visual Studio Code (2019 or 2022)
When you compile a `.cu` file, `nvcc` separates:
- **device code** -> code for GPU 
- **host code** -> code for CPU
  
I can use profiling tools such as `nsys` and [`nsys_easy`](https://github.com/harrism/nsys_easy)


# Google Colab - NVIDIA T4
name, driver_version, compute_cap
Tesla T4, 550.54.15, 7.5

Has 40 SMs and 2560 CUDA Cores

Each SM can achieve 1024 actives threads