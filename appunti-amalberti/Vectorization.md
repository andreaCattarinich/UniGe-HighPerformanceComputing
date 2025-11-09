# What is vectorization?

***Vectorization*** is a technique **used by compilers** (when possible) to **speed up** the execution of **loops** by fitting **more than one variable inside a register**.

The **necessary (but not sufficient) conditions** a loop should be satisfy to be vectorizable are the following:

- The **boundaries** of the iteration variable are **known** before the loop's execution.
- The loop contains **no function calls** (except for simple math functions and some inline functions).
- The loop contains **no control-flow** statements such as `if`-`else` and `switch` (except for conditional assignments such as `a[i] = condition ? x : y`).
- In a series of nested loops, only the **inner-most** loop can be vectorized (the outer-most loop is usually parallelized with OpenMP).

# Data dependencies

***Data dependencies*** (or simply just ***dependencies***) affect correctness of the execution.

Dependencies can be **RAW**, **WAR** or **WAW**, based on the relationship between **reads and writes** of one variable:

- ***Read After Write (RAW)***:
	- An entry of the vector is **updated and later read**.
	- Also called a **flow dependency**.
	- It is **not vectorizable**.

- ***Write After Read (WAR)***
	- An entry of the vector is **read and later updated**.
	- Also called an **anti-dependency**.
	- It is **vectorizable**.

- ***Write After Write (WAW)***:
	- An entry of the vector is **updated and later updated again**.
	- Also called an **output dependency**.
	- It is **not vectorizable**.

Dependencies can also be **LCD** or **LID**, which better define the word "**later**" used so far in the definitions above:

- **Loop-Carried Dependencies (LCD)**:
	- Between entries **from different loop iterations**.
	- When two statements are only involved in LCD's, it is **possible to rearrange them** without affecting the result.

- **Loop-Independent Dependencies (LID)**:
	- Between entries **from the same loop iteration**. When two statements form a LID, it is **not possible to rearrange them** without affecting the result.

## Read after write loop-carried dependencies (RAW LCD)

An example of a RAW LCD is the following loop:

```c
  for (i = 0; i < n; i++) {
	b[i] = 8;			// S1
	a[i] = b[i-1] + 10;	// S2
  }
  ```
  
In this example, `S1` is **modifying** the value of `b[i]` **(write)**, but in the **next iteration** `S2` will **read** the value of `b[i]` **(read)** after it was modified in the **current iteration (loop-carried)**.

## Read after write loop-independent dependencies (RAW LID)

An example of a RAW LID is the following loop:

```c
  for (i = 0; i < n; i++) {
	b[i] = 8;
	a[i] = b[i] + 10;
  }
  ```
In this example, `S1` is **modifying** the value of `b[i]` **(write)**, and in the **current iteration (loop-independent)** `S2` is **reading** the value of `b[i]` **(read)** after it was modified.

## Examples

# Removing dependencies to allow for vectorization

The compiler **cannot modify** non-vectorizable code to try and make it vectorizable when it encounters data dependencies. However, it is sometimes possible to **make non-vectorizable code vectorizable** by removing dependencies. The **developer is in charge** of this task, which involves rewriting parts of the code.

## Splitting loops for LID's

A LID can be removed by placing the two statements involved in the LID into **different loops**. For example:

```c
  for (i = 0; i < n; i++) {
	b[i] = 8;
	a[i] = b[i] + 10;
  }
  ```
can become
```c
  for (i = 0; i < n; i++) {
	b[i] = 8;
  }
  
  for (i = 0; i < n; i++) {
	a[i] = b[i] + 10;
  }
  ```
Now each one of these loops can be vectorized: `b[0:n] = 8` and `a[0:n] = b[0:n] + 10`.

## Loop aligning for LCD's

Consider the following example:

```c
  a[0] = 0;
  for (i = 0; i < n-1; i++) {
	a[i+1] = b[i] * c[i];		// S1
	d[i] = a[i] + 2;			// S2
  }
```

This loop contains is a **RAW LCD**, because `S1` is **modifying** the value of `a[i+1]` in the `i`-th iteration, but `S2` is **reading the same value** of `a[i+1]` in the `i+1`-th iteration. Since this is a RAW dependency, it cannot be vectorized, and the loop cannot be splitted since it's not a LID.

This code can become vectorized by ***aligning the loop***:

```c
  a[0] = 0;
  d[0] = a[0] + 2;			// initial overhead
  for (i = 1; i < n-1; i++) {
	a[i] = b[i-1] * c[i-1];		// S1
	d[i] = a[i] + 2;				// S2
  }
  a[n-1] = b[n] * c[n];		// final overhead
  ```
This code does exactly the same thing, all we did was:
- **Shifting all the indexes** of `S1` down by `1`, such that the **LCD becomes a LID**.
	- Because of this change, `a[n-1]` **wouldn't be set** inside the loop, so we did it **manually** outside the loop, adding a **final overhead**.
- **Changing the loop start** from `i=1` instead of `i=0`.
	- Because of this change, `d[0]` **wouldn't be set** inside the loop, so we did it **manually** outside the loop, adding an **initial overhead**.

Now that the RAW LCD became a RAW LID, it's possible to make the code vectorizable by **splitting the loop**.

## Reordering

Consider the following example:

```c
  for (i = 0; i < n-1; i++) {
	a[i+1] = c[i] + k;		// S1
	b[i] = b[i] + a[i];		// S2
	c[i+1] = d[i] + w;		// S3
  }
  ```
  
This loop contains two **RAW LCD**'s:
- `S1` is **modifying** the value of `a[i+1]` in the `i`-th iteration, but `S2` is **reading** the same value of `a[i+1]` in the `i+1`-th iteration.
- `S3` is **modifying** the value of `c[i+1]` in the `i`-th iteration, but `S1` is **reading** the same value of `c[i+1]` in the `i+1`-th iteration.

We can try to **align this loop** to make both **LCD's become LID's**:
- Since `a[i+1]` is calculated in `S1`, we can change `S2` to be `b[i+1] = b[i+1] + a[i+1]`.
- Since `c[i]` is needed in `S1`, we can change `S3` to be `c[i] = d[i-1] +  w`.
- Since the index was shifted by `+1` and `-1`, we need to change the loop extremes as well as manually write the statements that don't get executed outside of the loop (omitted in order to focus on the reordering).

Inside the loop we would have:

```c
  // [...]
	a[i+1] = c[i] + k;				// S1
	b[i+1] = b[i+1] + a[i+1];		// S2
	c[i] = d[i-1] + w;				// S3
  // [...]
  ```

The problem now is that we are accessing `c[i]` in `S1` before calculating it in `S3`. Which means we should write `S3` before `S1`:

```c
  // [...]
	c[i] = d[i-1] + w;				// S3
	a[i+1] = c[i] + k;				// S1
	b[i+1] = b[i+1] + a[i+1];		// S2
  // [...]
  ```
It was possible to **reorder** these two instructions before applying the loop alignment because they are **not involved in any LID**.

# Compiler hinting

A compiler **won't automatically vectorize** portions of code that could potentially give **incorrect results**. We can tell the compiler to **vectorize code anyway** in some situations, **when we are absolutely sure** we won't run into trouble.

Here are some of those situations and how we can instruct the compiler to do the optimizations anyway.

## Aliasing

***Aliasing*** is an issue that can occur when **vectorization** is applied to data structures that **overlap** in memory, producing an incorrect result.

- For example, in the C language **arrays** are passed to functions by **passing the pointer to the first element**. In this scenario, it is possible to **pass a pointer** which points at an **element already contained** in another array).

**Compilers** are able to **detect where aliasing could happen**, and **will not automatically vectorize**.

Aliasing can be **avoided** as long as we make sure to **provide proper vectors** to the function. In that case, we can pass a vector with `v[restrict]` instead of just `v[]` to the function.

## Reduction

- Reductions are a special kind of LCD, which consist of updating a value by performing some operation on its old value.
- If the operation performed is associative, then it can be parallelized, as long as the operation is the same in every iteration.
- By adding the directive `#pragma simd`, we can tell the compiler to

# Vectorization report of the `icc` compiler

The `icc` compiler generates ***vectorization reports*** upon compilation, if the flag `-qopt-report=<n>` is added. A vectorization report file is generated **for every compiled source file**, and it has the extension `.optrpt`. It contains **information** regarding all the **vectorization operations** that were performed.

The number `n` specified inside the option refers to the **level of verbosity** of the report, and it can be one of the following values:

- `0`: **No report** is generated.
- `1`: Only lists the **vectorized loops**.
- `2`: Also lists the **non-vectorized loops**, and for what **reason** they were not vectorized.
- `3`: Adds additional information about **dependencies**.
- `4`: Also lists the **non-vectorized loops**, **without explanation** (?).
- `5`: **All the available info** is reported.

# Memory and alignment

- ***Alignment*** of data inside memory is essential to maximize the efficiency of **memory accesses**, which are very slow and **should be reduced** as much as possible. Depending on the architecture that is being used, different **alignment boundaries** should be considered. These can range from **16 bytes to 64 bytes** for AVX512.
- For example, the following vector is aligned to 16 bytes because `float`s are 16 bytes long:
  ```c
  float a[4] = { 1.0f, 1.2f, 1.4f, 1.6f };
  ```
## Alignment of static arrays

Static arrays such as a `float A[1000]` can be aligned with the following syntax:

- On Windows C/C++: `_declspec(align(64)) float A[1000];`.
- On Linux and Mac C/C++: `float A[1000] __attribute__((aligned(64)));`.

> This syntax is architecture-specific, and the reference manual of the architecture that is being used should always be referenced.

 This way, the pointer to the first element will be aligned to 64 bytes.

## Alignment of dynamic arrays

In order to allocate dynamic arrays (in heap memory) so they're aligned, functions provided by the architecture should be used in place of `malloc` and `free`, such as `_mm_malloc` and `_mm_free`.

For example, to align the same array of floats `float A[1000]` from before, we can write:

```C
float *A = (float *)_mm_malloc(sizeof(float), 64);
```

Then, before using the variable inside a loop, we need to call `__assume_aligned(A, 64);`. This way, we can let the compiler know about the alignment.

## Structs