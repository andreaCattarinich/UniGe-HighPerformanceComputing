---
Subject:
  - High-Performance Computing
Type:
  - Note
---

# GPU for graphics

Highly parallel microprocessor (thousands of cores).

Private memory with high bandwidth (900 GB/s).

Mostly used for rendering 3D graphics.

## Rendering 3D graphics

Applying SIMD on every triangle and point to render, operations are calculated in parallel. Every point is computed independently.

Follows a graphics pipeline that was vendor-specific at first, later all shaders were uniformed into a unified processing array.

# GPGPU programming

***GPGPU (General Purpose GPU) programming*** relates to use **GPU's** to solve **any type of problem**, that might be unrelated to graphics.

The **program** runs **on the CPU**, but contains **parts** of the code that run **on the GPU**.

A ***kernel*** is a **function** that runs **on the GPU**.

The program has to **manage data transfers** between CPU and GPU.
- Traditional languages don't offer these features, **language extensions** and libraries (such as **CUDA**) are used.

# GPU architecture

A texture processing cluster (TPC) contains many streaming multiprocessors (SM), composed by streaming processors (SP), the basic block for computation, and shared memory.

## GPU vs. CPU

![image.png](cpu-vs-gpu-achitecture.png)

Inside a CPU:

- ALU: can compute complex operations, more powerful than a SP, only a couple.
- A few registers.
- Big control unit, has to deal with reordering operations and branch reordering.
- Big cache.
- Best for complex parts of the program, event driven, memory accesses.

Inside a GPU:

- SP: they only compute simple operations, less powerful than a ALU, a lot of them.
- Register file with a lot of registers (32k to 64k registers).
- Simpler control units, one for every SM.
	- Instruction scheduler dispatcher, for feeding the SP's.
- Small shared memory with large bandwidth, used to feed the many SP's.
- Best for simple but computational-intensive parts of the program.

GPU is used for a sort of vectorization (Single Instruction Multiple Data), rather than parallelism (Single Instruction Multiple Program).

Data needs to be moved from and to the CPU, which is an overhead.

## GPU functional unit types

- FP32: basic 32-bit floating point operations.
- INT32: basic 32-bit integer operations.
- FP64: basic 64-bit double precision floating point operations.
- SFU: reciprocal, sin, cos, inverse square root, etc...
- LS: Load and store from memory.
- Tensor core: More modern, specialized for matrix $A(B+C)$ fused multiply addition for AI applications.

> Gaming GPU's like the GeForce series are much cheaper because they don't have many FP64 units, unlike the Tesla family, which is targeted at HPC applications.

## Nvidia SM

![image.png](nvidia-sm-architectures.png)

Nvidia SM's are composed by CUDA cores.

There can be multiple dispatch units for a single SM.

A warp is the basic execution unit in CUDA, and it's a group of 32 threads, allocated on the CUDA cores.

# GPU programming

To use a GPU, programs must have both parts targeted at CPUs and GPUs. The data transfer between CPU and GPU has to be managed, traditional languages like C and Fortran cannot run manage this.

A function that runs on a GPU is called kernel. The code to run on the GPU has to be wrapped into functions, to be called from the CPU program.

# CUDA programming model

CUDA (Compute Unified Device Architecture) is an API to write GPU programs.

Higher level than other API's like OpenCL.

## Kernel example

For example, the CPU code:
	
```C
// define the function
void vecAddCPU(int N, const float *A, const float *B, float *C) {
	int i;
	for (i = 0; i < N; i++) {
		c[i] = a[i] + b[i];
	}
}

// call the function
vecAddCPU(N, a, b, c);
```

Becomes the following kernel:

```C
// define the kernel
__global__ void vecAddGPU(int N, const float *A, const float *B, float *C) {
	int i = blockIdx.x * blocDim.x + threadIdx.x;
	if (i < N) c[i] = a[i] + b[i];
}

// call the kernel
vecAddCPU<<<1, N>>>(N, a, b, c);
cudaDeviceSynchronize();
```

## Observations

In the GPU code, there is no `for` loop: every thread is assigned to one scalar computation. The check if(i < N) is supposing there are more GPU threads than for iterations.

The keyword `__global__` before the function signature indicates that the function is a kernel.

Another keyword `__device__` denotes kernels that are called by other kernels. Typically there will be one `__global__` kernel that calls multiple `__device__` kernels. `__device__` kernels can also be called by other `__device__` kernels.

The syntax `<<<1, N>>>` denotes the configuration used to run the kernel.

- The first number indicates the number of blocks (SM's).
- The second number indicates the number of threads per block.

Kernels are executed asynchronously, the function call `cudaDeviceSynchronize` is used for synchronization.

The compiler that supports this extension is `mvcc`, `gcc` will not work.

# Thread hierarchy in CUDA

GPU threads are grouped in blocks, which make up a grid.

CUDA threads are executed on CUDA cores

blocks are executed on SM's

Each block is executed independently on different SM's.

`threadIdx`: `{.x, .y}` pair, coordinates of a thread in a block.

`blockIdx`: `{.x, .y}` pair, coordinates of a block inside a grid.

`blockDim`: `{.x, .y}` pair, dimension in number of threads for each block, total number of threads is `.x * .y`.

`gridDim`: `{.x, .y}` pair, dimension in number of blocks in each grid, total number of blocks is `.x * .y`.

The max number of threads per block is 1024, if more threads are necessary, they should be distributed across multiple blocks.

## Warps

SM's execute threads in groups of 32 threads called warps.
- It is not efficient to execute less than 32 threads with a GPU.

They all start at the first instruction but have their own registers and are executed independently.

## Warp scheduler

The **warp scheduler** is a **component of the SM** that groups threads into warps and **decides which warps are executed**.

- Scheduling warps implies the order of execution is changed, in order to optimize hardware optimization.
- A best practice

A SM can have **multiple warp schedulers**. In this case, it is possible to execute **more warps at a time** if the hardware supports it.

## Warp divergence

***Warp divergence*** is an **issue** that occurs when threads in a warp need to execute **different operations** because of a **branch**. This implies the single warp will require the time to execute all branches **sequentially**.

Solved by making sure an entire warp executes **only one branch**, for example as follows:
	
```C
if = blockId
if ((i / 32) % 2 == 0)
	// code
else
	// code
```

Warp divergences can be detected by **advanced profilers** such as *Nsight*.
	
# Hierarchy of GPU memories

![image.png](cuda-device-memory-model.png)

![image.png](cache-hierarchy-for-global-memory-accesses.png)

A GPU contains different kinds of memories with specific behaviors.

***Global memory***:
- Similar to RAM.
- Largest memory, about 4 GB.
- Data maintained between kernel launches, only lasts for the execution of the program.
- High bandwidth: high throughput, just because thousands of threads need to be fed with memory, it's not actually very high.
	- Coalescence must be exploited.
- High latency (400 to 800 clock cycles).

***Per-block shared memory***:
- Similar to cache.

***L1 Cache***:
- Used alongside shared memory.
- In some implementation it's the same hardware.

***L2 Cache***:
- Shared among SM's, very little (1MB to 4MB).

***Local memory (registers)***
- Registers (32kB to 64kB) for every thread.
- No latency.
- If threads require more memory than available from registers, they are stored in the global memory.

***Constant memory***:
- Small, around 64kB.
- Used to store read-only data used by many threads.
- In CUDA, declared with `__constant__`.
- In CUDA, set with `cudaMemcpyToSymbol`.
	- snippet for `cudaMemcpyToSymbol`.

***Texture memory***:
- Used to apply textures for graphics, also used as constant memory for general purpose programming.
- Faster for 2D patterns.

## Coalescent access to global memory

Access to global memory is ***coalescent*** when data is loaded for **multiple threads** in a **single transaction**.

Situation that allows **maximum bandwidth**.

Similar to cache lines.

## Data alignment in global memory

Data alignment enables coalescence.

`cudaMalloc` grants alignment of first element in global memory.

`cudaMallocPitch` used to allocate 2D buffers.

# Memory allocation in CUDA

## Manual memory management

Memory on the CPU and on the GPU are independent from one another, functions from the C standard library such as `malloc` cannot allocate memory inside the GPU, `cudaMalloc` is used instead.

```C
// Allocate memory in the GPU
int N;
int *a;
cudaMalloc((void **)&a, N * sizeof(int));
  ```

Memory has to be manually moved from the CPU to the GPU.

```C
// Copy memory from the CPU memory to the GPU memory
cudaMemcpy(cpuPointer, gpuPointer, N * sizeof(int), cudaMemcpyHostToDevice);

// Copy memory from the GPU memory to the CPU memory
cudaMemcpy(gpuPointer, cpuPointer, N * sizeof(int), cudaMemcpyDeviceToHost);
```

## Shared memory allocation

It is possible to allocate a variable in shared memory using `__shared__` before the variable declaration.

finish from page 110

## Unified memory

Supported by CUDA 6.x

Memory management is abstracted away.
- Single pointer for both GPU RAM and CPU RAM, the CUDA runtime will move the data automatically.
- `cudaMallocManaged` creates a pointer for unified memory.

Easier but worse performance.

```C  
cudaMallocManaged();
```

## Error checking

`cudaGetErrorString` used to get the error description when an error occurs, by providing the error code.

May introduce overhead during synchronization, should only be used during debug and not in production code

insert code snippet for `cudaGetErrorString` etc... (at page 72)

# GPU Execution model

One block is made up of at most 1024 threads, the workload should be subdivided into blocks.

Blocks are not moved between SM's.

No synchronization is possible among blocks, only threads among blocks. The only way to achieve this level of synchronization is submitting the kernel again.