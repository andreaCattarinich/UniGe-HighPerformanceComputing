#!/bin/bash

# Nome del binario da eseguire
BUILD=../build/
NAME=omp3
EXEC="$BUILD""$NAME"

# Numero di esecuzioni per ciascun test
RUNS=1

# Numero massimo di thread
MIN_THREADS=4
MAX_THREADS=15

# File di output
OUTFILE="$NAME"_"$RUNS"runs_"$MIN_THREADS"-"$MAX_THREADS"threads.txt

# Svuoto il file
: > "$OUTFILE"

echo "Running $RUNS time(s) scaling from $MIN_THREADS to $MAX_THREADS thread(s)..."
echo "Executable -> $EXEC"
echo "Output -> $OUTFILE"

for threads in $(seq $MIN_THREADS $MAX_THREADS); do
    for run in $(seq 1 $RUNS); do
        echo "- Run $run | $threads threads(s)..."
        OMP_NUM_THREADS="$threads" "$EXEC" >> "$OUTFILE"
        echo -n >> "$OUTFILE"
    done
done

echo "Done"
