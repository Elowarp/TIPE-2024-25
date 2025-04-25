import numpy as np
import matplotlib.pyplot as plt

size, elapV1, elapV2 = np.loadtxt("times_cmpx_60.dat", unpack=True)

plt.plot(size, elapV1, label="Avant optimisation", linestyle="-", color="black")
plt.plot(size, elapV2, label="Après optimisation", linestyle="--", color="black")

plt.xlabel("Nombre de points")
plt.ylabel("Temps (s)")
plt.legend()
plt.savefig("images/analyse_cmpx.png")