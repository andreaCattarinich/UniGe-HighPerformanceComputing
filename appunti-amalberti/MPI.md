---
Subject:
  - High-Performance Computing
Type:
  - Note
---

MPI is a protocol like OpenMP that provides an interface for message-passing between processes.

Processes within MPI are associated with a communicator, which is "communication group".

- The standard communicator is `MPI_COMM_WORLD`.
- All processes inside a communicator have a rank which is an id of the process.

## MPI template in C

```C
#include <stdio.h>
#include <mpi.h>
// The whole function is executed by independent processes, there is no "forking".
void main (int argc, char * argv[]) {
	int err, nproc, myid;
	
	err = MPI_Init(&argc, &argv);
	// Get the number of processes (members of the WORLD communicator).
	err = MPI_Comm_size(MPI_COMM_WORLD, &nproc);
	// Get the rank of the current process.
	err = MPI_Comm_rank(MPI_COMM_WORLD, &myid);
	
	/*** INSERT YOUR PARALLEL CODE HERE ***/
	
	err = MPI_Finalize();
}
```
The program is compiled with `mpicc` which encapsulates `gcc` or `mpiicc` which encapsulates `icc`, and is executed with `mpirun -np <number of processes> <executable>`. `mpiexec` is equivalent to `mpirun`.

# Point to point communication

Very commonly, a message has to be sent from `i` to `j`.

```C
// Process with rank i sends
if (rank == i) {
	buf = 123456;
	MPI_Send(&buf, 1, MPI_INT, 1, 0, MPI_COMM_WORLD);
// Process with rank j receives
} else if (rank == j) {
	MPI_Recv(&buf, 1, MPI_INT, 0, 0, MPI_COMM_WORLD, &status);
	printf("Received %d\n", buf);
}
```

The calls to `MPI_Send` and `MPI_Recv` require similar arguments:
- Body-related arguments, which specify the actual content of the message:
	- A pointer/reference to the data to send for `MPI_Send` or to the buffer where the data should be received `MPI_Recv`.
	- The size of the data to send (1 if scalar, otherwise array size).
	- The type of the data.
- Envelope-related arguments, used to correctly route the message:
	- The rank of the receiver process (for `MPI_Send`) or sender process (for `MPI_Recv`).
		- In the case of `MPI_Recv`, the wildcard `MPI_ANY_SOURCE` can be used to receive from any process.
	- The tag, or `MPI_ANY_TAG`.
	- The communicator.
	- In case of receive, the status of the operation which is the result.

![image.png](mpi-message-structure.png)

In case multiple elements were sent, `MPI_Get_count` is used to determine how many were successfully transferred.

`MPI_Isend` and `MPI_Irecv` are non-blocking:
- `MPI_Isend` does not wait for the message to be received by the other process.
- `MPI_Irecv` does not wait for the entire message to be received from the other process. This means the result buffer will start to be written as the program continues. In order to later retrieve the transferred data, it's possible to use:
	- `MPI_Wait` or `MPI_Waitany` to block the execution until the message has been fully received.
	- `MPI_Test` or `MPI_Testany` to check if the data transfer has finished. The received data should not be accessed until it has been fully transferred.

## Deadlock

Blocking calls can lead to deadlock. For example two processes send but none receives, which means both processes wait for their message to be received and will never receive.

This is avoided by:
- Reordering operations.
- Using non-blocking calls.