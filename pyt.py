import time
from datetime import datetime
import board
import busio
from adafruit_bmp280 import Adafruit_BMP280_I2C

with open("temp", 'r') as temp_file:
    lines = temp_file.readlines()
    archivo = lines[2].strip()

def cartelito(temp, pres):
    if temp < 15:
        print(f'\r\033[37m{temp:.0f} C {pres:.0f} hbar   ', end='', flush=True)   
    elif 15 <= temp < 23:
        print(f'\r\033[36m{temp:.0f} C {pres:.0f} hbar   ', end='', flush=True)    
    elif 23 <= temp < 30:
        print(f'\r\033[32m{temp:.0f} C {pres:.0f} hbar   ', end='', flush=True)
    elif 30 <= temp < 40:
        print(f'\r\033[38;5;214m{temp:.0f} C {pres:.0f} hbar   ', end='', flush=True)
    elif temp >= 40:
        print(f'\r\033[31m{temp:.0f} C {pres:.0f} hbar    ', end='', flush=True)

i2c = busio.I2C(board.SCL, board.SDA)

bmp280 = Adafruit_BMP280_I2C(i2c)

while True:

    fecha = datetime.now().strftime("%d-%m-%Y %H:%M")
    temperatura = bmp280.temperature
    presion = bmp280.pressure  
    
    cartelito(temperatura, presion)
    linea = f"{fecha} {temperatura:.5f} {presion:.5f}\n"

    with open(archivo, 'a') as f:  # 'a' para agregar texto al final del archivo
        f.write(linea)
    
    time.sleep(60)
