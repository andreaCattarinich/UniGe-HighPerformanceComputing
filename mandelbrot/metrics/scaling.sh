#!/bin/bash

# Nome del binario da eseguire
BUILD=../build210/
NAME=omp3
EXEC="$BUILD""$NAME"

# Numero di esecuzioni per ciascun test
RUNS=1

# Numero massimo di thread
MIN_POW=0      # 2^2 = 4 thread
MAX_POW=7      # 2^7 = 128 thread

# File di output
MIN_THREADS=$((2**MIN_POW))
MAX_THREADS=$((2**MAX_POW))

OUTFILE="${NAME}_${RUNS}runs_${MIN_THREADS}-${MAX_THREADS}threads.txt"

# Svuoto il file
: > "$OUTFILE"

echo "Running $RUNS time(s) scaling from $MIN_THREADS to $MAX_THREADS thread(s)..."
echo "Executable -> $EXEC"
echo "Output -> $OUTFILE"

for p in $(seq $MIN_POW $MAX_POW); do
    threads=$((2**p))
    for run in $(seq 1 $RUNS); do
        echo "- Run $run | $threads threads(s)..."
        OMP_NUM_THREADS="$threads" "$EXEC" >> "$OUTFILE"
        echo -n >> "$OUTFILE"
    done
done

echo "Done"
