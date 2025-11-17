#!/bin/bash

# Nome del binario da eseguire
EXEC=../build/hotspots_identification

# Numero di esecuzioni per ciascun test
RUNS=10

# Numero massimo di thread
MAX_THREADS=1

# File di output
OUTFILE=hotspots_identification.txt

# Svuoto il file
: > "$OUTFILE"

echo "Running $RUNS time scaling from 1 to $MAX_THREADS threads..."
echo "Output -> $OUTFILE"

for run in $(seq 1 $RUNS); do
    for threads in $(seq 1 $MAX_THREADS); do
        echo "- Run $run | $threads threads(s)..."
        OMP_NUM_THREADS="$threads" "$EXEC" >> "$OUTFILE"
        echo >> "$OUTFILE"
    done
    echo "-----" >> "$OUTFILE"
done

echo "Done!"
