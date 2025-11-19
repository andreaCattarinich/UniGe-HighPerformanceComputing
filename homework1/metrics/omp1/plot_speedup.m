import matplotlib.pyplot as plt

# Nome del file contenente i valori
# filename = "omp1_5runs_1-32threads.txt"
filename = "data.txt"

# Legge i valori dal file
with open(filename, "r") as f:
    values = [float(line.strip()) for line in f if line.strip()]

# Crea il grafico
plt.plot(values, marker='o')
plt.title("Grafico dei valori")
plt.xlabel("threads")
plt.ylabel("speedup")
plt.grid(True)
plt.show()
