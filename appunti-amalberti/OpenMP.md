---
Subject:
  - High-Performance Computing
Type:
  - Note
---

# Introduction

## OpenMP

***OpenMP (Open Multi Parallelism)*** is a **platform-independent API** for writing **multi-threaded programs**.

It relies on a **standard**
- Adopted in **many compilers** for languages such as C, Fortran
- Adopted by the Python interpreter (important to check support).

API components:
- Compiler **directives** (`pragma`-based).
- Runtime library routines (**function calls**).
- **Environment variables**.

More information can be found on the OpenMP website.

> We don't discuss offloading to the GPU, because we use CUDA instead.

### Why OpenMP?

An alternative to developing parallel applications is using **low level libraries** such as `pthread` on Linux. These solutions are **complex**, **error-prone** and are **platform-dependent**.

There are also other alternatives which are even **higher level**, but often these libraries are also **platform-dependent**.

OpenMP is **largely used** and **platform-independent**.

## Memory architectures

***Non-uniform***: every **CPU** is attached to a **different memory bank**.
- **Expensive** for a thread to **access memory that is not attached** to it.
- This is the architecture **supported by OpenMP**.

***Uniform***: every **CPU** is attached to a **same shared memory**.
- This architecture is **not supported by OpenMP**.

## Threads vs. processes

A ***process***:
- Is the **instance of a computer program**.
- Its image in memory contains:
	- ***Text***: machine instructions.
	- ***Data***: constant global values, such as hard-coded strings and numbers.
	- ***Stack***: local variables and function scopes.
	- ***Heap***: manually allocated memory.
	- ***Program counter***.
- A **process cannot access the memory of another process** (otherwise a segmentation fault will occur). In order for processes to communicate, they must exchange data with **IPC techniques** such as message-passing (MPI).
- **Creating a process** involves **copying the entire memory image**, including text and data sections.

A ***thread***:

- is a **"lightweight process"** that **belongs to a process**.
- All the threads of the same process can read the entire memory of the process, but they can also have a private memory region.
- **Creating a thread** does not involve this: **only the program counter and the memory sections are duplicated**, so each thread has their own program counter, stack and heap, but the data and text sessions are shared.

> The concept of **replicating data but not the code** is called ***SPMD (Single Program Multiple Data)***. This is **different from SIMD** (Single Instruction Multiple Data) used in vectorization, different **level of abstraction**.

## OpenMP common core

The common core is a list of the most commonly used items from the standard.

# Threads

## Creation

```C
// threads are created at the beginning of the block
#pragma omp parallel
{
	// parallel code...
}
// threads are joined at the end of the block
```
  
Parallel code runs only inside the block: threads are created at the beginning of the block and are joined at the end of the block.

The threads are created once and joined once. Individual threads cannot be increased or joined inside the block.

## Number of threads

The number of threads has an impact of performance which is not necessarily proportional to the number of threads. Different values should be tested, by keeping in mind the number of cores of the processor and the capability for SMT. The `omp_get_num_procs()` can be called to obtain the number of cores installed on a system.

The max number of threads supported on a system can be obtained by `omp_get_max_threads()`.

## Setting the number of threads

The number of threads can be set by:
- At **compile time**, using `#pragma omp parallel num_threads(n)` or calling `omp_set_num_threads(n)`.
	- They should only be used if we are sure the number of threads is optimal at compile time
	- Only for very special situations, otherwise not recommended.
- At **runtime**, setting the `OMP_NUM_THREADS=n` environment variable.
	- Allows to test different number of threads without recompiling.
	- Usually preferred.
- None of the above, letting the system automatically determine the number of threads to use.
	- Most of the times the best option is to let the system determine the number of threads automatically by not specifying anything.

> Less threads than specified might be created, it's a good practice to call `omp_get_num_threads()` to get the correct number of threads.

# Worksharing-loop constructs

Worksharing-loop constructs are constructs used to parallelize `for` loops by spawning multiple threads and subdividing the workload to the threads.

A typical `for` loop looks like the following:

```C
int i;
for (i = 0; i < n; i++) {
	// some code...
}
```
## Manual workload subdivision

This code can be run in parallel by manually subdividing the workload:

```C
#pragma omp parallel
{
	int i;
	int n_threads = omp_get_num_threads();
	int thread_id = omp_get_thread_num()
	int start = thread_id * n / n_threads;
	int end = (thread_id + 1) * n / n_threads;

	for (i = start; i < end; i++) {
		// some code...
	}
}
```

This way, each for loop is executed `omp_get_num_threads()` less times.

## Workload subdivision using `#pragma omp for`

The same result can be achieved by using the `#pragma omp for` directive:

```C
#pragma omp parallel
{
	int i;
	#pragma omp for
	for (i = 0; i < n; i++) {
		// some code...
	}
}

```
If the parallel region is only a single `for` loop, the shortcut `#pragma omp parallel for` can be used:

```C
#pragma omp parallel for
for (i = 0; i < n; i++) {
	// some code...
}
```

## Loop scheduling

Dynamic loop scheduling
- If each iteration can take different times, it's possible to use dynamic scheduling, to dynamically assign workload to threads, to reduce load unbalancing. Dynamic scheduling has some overhead, but it's negligible if we can improve the load unbalancing.
- This is done using the clause `schedule(dynamic)`.

Static loop scheduling
- If we can guarantee each iteration requires similar time, it's best to use static scheduling, to reduce the overhead of dynamic scheduling.
- This is done using the clause `schedule(static)`.

Guided loop scheduling
- Guided loop scheduling is a compromise of the two strategies above: threads are assigned blocks of workload of progressively smaller size, to reduce the workload at the beginning and allow for less load unbalancing near the end.
- This is done using the clause `schedule(guided)`.

## Using a shared array between threads

In situations such as integration, where we need to accumulate a value at each iteration, we can use an array where all the partial results of each thread are stored and later added up when all the threads are joined to compute the total.

### False sharing

***False sharing*** happens when the **array elements** are all stored on the **same cache line**. This **can** result in a **race condition**, as the threads will **write on the same cache line simultaneously**.

If this issue is detected, it can be **solved** by adding some **padding to the array**, to force elements to be stored on **different cache lines**.

## Reduction

`reduction(op:var)` where `op` is an operator such as `+`, and `var` is the variable where the reduction should happen. Other operators include arithmetic operators as well as `min` and `max`.

# Synchronization

## Barriers

A barrier is used to forces the program to wait for all threads to reach it before continuing with the execution. The effect is similar to joining threads and creating new ones, but without the overhead of creating new threads many times.

```C
// threads are created at the beginning of the block
#pragma omp parallel
{
	// parallel code...
	
	#pragma omp barrier
	// parallel execution starts again
}
// threads are joined at the end of the block

```
Barriers are still somewhat expensive, especially when there are many threads, and they should not be used if not strictly necessary.

## Single thread execution

Allows to run a block by only one thread. Any thread can run this block, not necessarily the master thread. This has less impact on the performance than barriers.
- question investigate how this works with respects to barriers

```C
// threads are created at the beginning of the block
#pragma omp parallel
{
	// parallel code...
	#pragma omp single
	{
		// this is only run by one of the threads
	}
	// parallel execution starts again
}
// threads are joined at the end of the block
```

## Critical regions

Critical regions are portions of code that should not be executed in parallel: once one thread starts executing a critical region, if any other thread reaches the critical region they will pause until the thread that is inside the critical region has left.

This is useful when each thread needs to access a shared resource, such as writing to a file or to a shared memory area, in order to avoid race conditions.
```C
float res; // define a shared variable

#pragma omp parallel
{
	// parallel code...
	float partial_res = some_function();
	
	// merging the results happens in a parallel area
	// only one thread at a time can write on res
	#pragma omp critical
	{
		// sequential code...
		res += partial_res;
	}
}

// here res is the sum of the partial_res computed by every thread
```

## Atomic operations

Atomic operations are equivalent to critical regions, but they're only applied on one single line of code, such as a read or a write.

```C
float res; // define a shared variable
#pragma omp parallel
{
	// parallel code...
	float partial_res = some_function();
	
	// merging the results is an atomic write operation
	// only one thread at a time can write on res
	#pragma omp atomic write
	res += partial_res;
}
// here res is the sum of the partial_res computed by every thread
  ```
  
# OpenMP data environment

## Default behavior

The following variables are **shared** by default:
	- Variables **declared before the parallel region**.
	- **Global** variables.
	- `static` variables.
	- **Heap** variables.
	
Shared variables can lead to race conditions.

The following variables are **private** by default:
- Variables **declared inside the parallel region**.
- **Indexes** of parallel `for` loops.

## Setting variable visibility

The clauses `shared(<list>)`, `private(<list>)` and `firstprivate(<list>)` can be used to **set the visibility** of variables:

- `shared`:
	- The variable is **shared**.

- `private`:
	- A **new private copy** of the variable is created for each thread.
	- The copies have **uninitialized values**.
	- When the parallel region ends, all changes to the variable are lost, and the original variable is kept with the same value.

- `firstprivate`:
	- A **new private copy** of the variable is created for each thread.
	- The copies have the **same value** as the original variable.
	- When the parallel region ends, all changes to the variable are lost, and the original variable is kept with the same value.

The default behavior can be set with `default`. Testing code with `default none` is a good practice.

## Consistency of shared variables

Sequential consistency: read, write and synchronize operations are executed in order.

This is a problem in OpenMP because updates to memory might not happen immediately, they might remain inside registers or cache levels. If other threads reference this variable, they might not get the right value.

`flush(<var1>, <var2>, ...)` operations are used to force all threads to update memory.
- `flush` operations are automatically executed by entry and exit of `parallel`, `critical` and `atomic`.
- All variables to be flushed should be flushed with the same `flush` call.

# Tasks

Sequential code can be split into a sequence of ***tasks***, each task can be executed in parallel.

Not a huge speedup, but still better.

Structured block of code with a data environment (such as a function).

Created with `#pragma omp task` inside a single region of a parallel region.

A thread (the master) creates the tasks that are then picked up by the other idle threads.

```C
// Tasks are created inside a parallel region
#pragma omp parallel
{
	// One thread only should create the tasks
	#pragma omp single
	{
		#pragma omp task
		task1();
		#pragma omp task
		task2();
		
		// Create more tasks in the same way ...
	}
}
```

Tasks are executed in parallel, they don't run in a specific order.

Tasks are guaranteed to be completed at thread barriers.
- A more lightweight option is `#pragma omp taskwait`.

Variables used by the task are `firstprivate` by default.
- Tasks are usually created for one element, and that element should not change (just like the index of a `for` loop is private by default).

## Example: list traversal

List traversals cannot be parallelized like `for` loops:
- The memory is not contiguous.
- The number of elements it not known: number of iterations not known.

```C
p = head;
while (p) {
	process(p);
	p->p.next;
}
```

```C
#pragma omp parallel
{
	# pragma omp single
	{
		node * p = head;
		while (p) {
			#pragma omp task
			process(p);
			p = p->next;
		}
	}
}
```

## Example: Recursive Fibonacci

```C
int fib(int n) {
	int x, y;
	
	if (n < 2) return n;
	#pragma omp task shared(x)
	x = fib(n-1);
	#pragma omp task shared(y)
	y = fib(n-2);
	#pragma omp taskwait
	return x+y;
}
```
Variables `x` and `y` should be made shared, if they were private their value would not get updated, because copies would be created for every task.

A binary tree of tasks and sub-tasks is created.

> Of course this is very inefficient, it's just an example to show parallelization of a recursive function.

## Data dependency

Tasks can depend on results from other tasks. Use `depend(in:<var>)` or `depend(out:<var>)` to define a dependency graph on the tasks.