Come eseguire la compilazione:

TODO: choose between `-O2 -O3`
- **Google Colab (T4)**: `nvcc -O2 -arch=sm_75 ...`
- **PC (GTX 950M)**: `nvcc -O2 -arch=sm_50 ...`

TODO: aggiungere al report
## ICX reports
See [seq_icx.optrpt](/homework2/reports/seq_icx.optrpt)

```text
L’analisi di vettorizzazione con ICX sul kernel step_kernel_ref mostra che il loop principale alla riga 49 è stato vettorizzato con vector length 8. Il costo scalare stimato era 132, mentre il costo vettoriale è di 22, con un potenziale speedup di ~5.8×. Il remainder loop è anch’esso vettorizzato, sebbene con masking e vector length inferiore (8 o 4), a causa della gestione dei dati non multipli della larghezza del vettore. Alcuni loop non sono stati vettorizzati per motivi di dipendenze dati o perché era presente il pragma novector. Questo indica che, pur avendo ottimizzazione vettoriale significativa, non tutte le iterazioni beneficiano della SIMD.
```