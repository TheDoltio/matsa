#!/bin/bash

# Colocar aquí la fecha de inicio de la toma de datos en formato YYMMDDhhmm
fecha = 2409051113

archivo_origen_1="/ruta/al/raw_${fecha}.dat"
archivo_origen_2="/ruta/al/cuentas_por_minuto_trad_${fecha}.dat"
archivo_destino_local_1="/home/respaldo/raw_${fecha}.dat"
archivo_destino_local_2="/home/respaldo/cuentas_por_minuto_trad_${fecha}.dat"
archivo_remoto_1="escaramujo8@148.222.47.225:/home/escaramujo8/datos_flujo_escaramujo/raw_${fecha}.dat"
archivo_remoto_2="escaramujo8@148.222.47.225:/home/escaramujo8/datos_flujo_escaramujo/cuentas_por_minuto_trad_${fecha}.dat"
intervalo=3600  # Tiempo de espera entre cada ejecución (3600 segundos = 1 hora)

# Función para manejar la señal de interrupción (Ctrl+C)
trap "detener_script" SIGINT

detener_script() {
    echo "Deteniendo el script..."

    # Eliminar los archivos originales si existen
    if [ -f "$archivo_origen_1" ]; then
        rm "$archivo_origen_1"
        echo "Archivo original $archivo_origen_1 eliminado."
    else
        echo "Archivo original $archivo_origen_1 no encontrado o ya eliminado."
    fi

    if [ -f "$archivo_origen_2" ]; then
        rm "$archivo_origen_2"
        echo "Archivo original $archivo_origen_2 eliminado."
    else
        echo "Archivo original $archivo_origen_2 no encontrado o ya eliminado."
    fi

    exit 0
}

# Bucle principal que se ejecuta indefinidamente
while true; do
    # Manejar el primer archivo
    if [ -f "$archivo_origen_1" ]; then
        scp "$archivo_origen_1" "$archivo_remoto_1"
        if [ $? -eq 0 ]; then
            echo "Primer archivo subido correctamente a $archivo_remoto_1."
            cp "$archivo_origen_1" "$archivo_destino_local_1"
            echo "Primer archivo copiado a $archivo_destino_local_1."
        else
            echo "Error al subir el primer archivo al clúster."
        fi
    else
        echo "Primer archivo $archivo_origen_1 no encontrado."
    fi

    # Manejar el segundo archivo
    if [ -f "$archivo_origen_2" ]; then
        scp "$archivo_origen_2" "$archivo_remoto_2"
        if [ $? -eq 0 ]; then
            echo "Segundo archivo subido correctamente a $archivo_remoto_2."
            cp "$archivo_origen_2" "$archivo_destino_local_2"
            echo "Segundo archivo copiado a $archivo_destino_local_2."
        else
            echo "Error al subir el segundo archivo al clúster."
        fi
    else
        echo "Segundo archivo $archivo_origen_2 no encontrado."
    fi

    # Esperar antes de la siguiente ejecución
    echo "Esperando $((intervalo/60)) minutos antes de la próxima ejecución..."
    sleep $intervalo  # Esperar el intervalo de 1 hora
done

