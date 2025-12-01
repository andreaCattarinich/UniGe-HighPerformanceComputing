#!/bin/bash

# Lista dei nomi dei binari
BINARIES=("omp1" "omp2" "omp3")

# Numero di esecuzioni per ciascun test
RUNS=10

# Range delle potenze di due (2^MIN_POW ... 2^MAX_POW)
MIN_POW=0    # 2^0 = 1 thread
MAX_POW=7    # 2^7 = 128 thread

for NAME in "${BINARIES[@]}"; do
    BUILD="../build210/"
    EXEC="$BUILD$NAME"

    # Calcolo reale dei thread per nome del file
    MIN_THREADS=$((2**MIN_POW))
    MAX_THREADS=$((2**MAX_POW))
    OUTFILE="${NAME}_${RUNS}runs_${MIN_THREADS}-${MAX_THREADS}threads.txt"

    # Svuoto il file
    : > "$OUTFILE"

    echo "Running $RUNS run(s) for $NAME with threads 2^$MIN_POW to 2^$MAX_POW..."
    echo "Output -> $OUTFILE"

    for p in $(seq $MIN_POW $MAX_POW); do
        threads=$((2**p))
        for run in $(seq 1 $RUNS); do
            echo "- Run $run | $threads thread(s)..."
            OMP_NUM_THREADS="$threads" "$EXEC" >> "$OUTFILE"
            echo "" >> "$OUTFILE"
        done
    done

    echo "Done with $NAME"
    echo "-----------------------------"
done

echo "All done!"
