# Advisor

## How to use
- set vars `source /opt/intel/oneapi/setvars.sh`
- open advisor: `advisor-gui`
- new project
- select: Trip Counts & FLOP Analysis
- run

---
## Roofline Analysis

Represent how much efficient is your program by comparison with the hardware limitation of the machine.

It allows you to analyse your application and figure out *where you can optimize code* in order to run faster.

There are two theoric limits:
- Oblique line that represents **Memory Cap** (N GByte/S * X FLOPs/Byte = Y GFLOPs/S)
- Horizontal line that represents the **CPU Cap**

--- 
Components:
- FLOPS: Floating-Point Operations Per Second
- FLOPs: Floating-Point Operations
- **Performance (y-axis)**: FLOPs/Second (Floating-Point Operations per Second)
- **Arithmetic Intensity (x-axis)**: FLOPs/Byte Accessed.
---

### Commands:
- Analisi preliminare del codice: `adviser --collect=survey --project-dir=./advisor_proj ./v1`
- Raccolta dati (tripcounts + FLOPs) per roofline: `adviser --collect=tripcounts --flops --project-dir=./advisor_proj ./v1`
- Roofline: `adviser --report=roofline --project-dir=./advisor_proj`

---
### Video YT
[LINK](https://www.youtube.com/watch?v=k7m_A1j81g0)

I puntini sono i loop e se vado sui punti posso vedere alcune caratteristiche (es. Self Time)

In alto posso vedere quanti core

In basso posso vedere le **raccomandazioni** per l'ottimizzazione.
Se viene visualizzato "Assumed depencency present (WAR or RAW)", allora bisognerà avviare la *Dependence analysis* per confermare la presenza di questa dipendenza.

A sinistra della roofline analysis c'è un rettangolo verticale (SURVEY-ROOFLINE).
Se schiaccio su di esso, posso andare in una nuova sezione in cui posso controllare le performance (es: Efficiency, che dice quanto è efficiente il loop) di tutte le funzioni/loop.

Inoltre, le raccomandazioni, possono consigliarci *altri flag di compilazione* .


Schiacciando a sx su *2.2 Check dependencies -> Collect*, posso ottenere un'analisi completa (Refinement Reports) che contiene dei suggerimenti (direttive) da aggiungere al codice per migliorare la vettorizzazione.

