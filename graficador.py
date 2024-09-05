import matplotlib.pyplot as plt
import matplotlib.dates as mdates
import pandas as pd
import numpy as np

def format_func(value, tick_number):
    date = mdates.num2date(value)
    return f'{date.day}\n{date.strftime("%b")}\n{date.year}'
    
#df = pd.read_csv('per_15min_ctn.dat', delim_whitespace=True, header=None, names=["Fecha", "Hora", "ch0", "ch0std", "ch1", "ch1std", "ch2", "ch2std", "ch3", "ch3std", "coincidencias", "coincidenciasstd"])

df = pd.read_csv('per_min_ctn0409241511.dat', delim_whitespace=True, header=None, names=["Fecha", "Hora", "ch0", "ch1", "ch2", "ch3", "coincidencias"])

df['FechaHora'] = pd.to_datetime(df['Fecha'] + ' ' + df['Hora'], format="%d-%m-%Y %H:%M:%S")

#promedio = sum(df['ch0'])/len(df['ch0'])
#stdsigma = np.std(df['ch0'])

#print(promedio)
#print(stdsigma)

df = df.drop(columns=['Fecha', 'Hora'])

# Graficar

plt.figure(figsize=(15, 6))

plt.errorbar(df['FechaHora'], df['coincidencias'], color="black", label="coincidencias", linestyle='--', marker='o', markersize=4, capsize=5)

xaxis = plt.gca().xaxis
xaxis.set_major_locator(mdates.DayLocator())  

xaxis.set_major_formatter(plt.FuncFormatter(format_func))

plt.xlabel("Fecha")
plt.ylabel("Coincidencias/minuto")
plt.title("Coincidencias entre el canal 0 y el canal 1.")

plt.grid(True, which='both', axis='y', linestyle='--', alpha=0.7)  

plt.legend()
plt.tight_layout()

# Graficar

plt.figure(figsize=(15, 6))

plt.plot(df['FechaHora'], df['ch0'], color="red", label="CH0", linestyle='-', marker='o', markersize=4)

xaxis = plt.gca().xaxis
xaxis.set_major_locator(mdates.DayLocator())  

xaxis.set_major_formatter(plt.FuncFormatter(format_func))

plt.xlabel("Fecha")
plt.ylabel("Cuentas/minuto")
plt.title("Cuentas por minuto en el canal 0")

plt.grid(True, which='both', axis='y', linestyle='--', alpha=0.7)  

plt.legend()
plt.tight_layout() 

# Graficar

plt.figure(figsize=(15, 6))

plt.plot(df['FechaHora'], df['ch1'], color="blue", label="CH1", linestyle='-', marker='s', markersize=4)

xaxis = plt.gca().xaxis
xaxis.set_major_locator(mdates.DayLocator())  

xaxis.set_major_formatter(plt.FuncFormatter(format_func))

plt.xlabel("Fecha")
plt.ylabel("Cuentas/minuto")
plt.title("Cuentas por minuto en el canal 1")

plt.grid(True, which='both', axis='y', linestyle='--', alpha=0.7)  

plt.legend()
plt.tight_layout() 

# Graficar

plt.figure(figsize=(15, 6))

plt.plot(df['FechaHora'], df['ch0'], color="red", label="CH0", linestyle='-', marker='o', markersize=4)
plt.plot(df['FechaHora'], df['ch1'], color="blue", label="CH1", linestyle='-', marker='s', markersize=4)

xaxis = plt.gca().xaxis
xaxis.set_major_locator(mdates.DayLocator())  

xaxis.set_major_formatter(plt.FuncFormatter(format_func))

plt.xlabel("Fecha")
plt.ylabel("Cuentas/minuto")
plt.title("Cuentas por minuto en ambos canales")

plt.grid(True, which='both', axis='y', linestyle='--', alpha=0.7)  
plt.ylim(bottom=0)

plt.legend()
plt.tight_layout() 

plt.show()





