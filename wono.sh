#!/bin/bash

# Parámetros para el manejo, subida y respaldo del archivo.

fecha=2409051113 # Colocar aquí la fecha de inicio de la toma de datos en formato YYMMDDhhmm 
cluster="escaramujo8@148.222.47.225" # Colocar aquí el nombre del clúster destino
intervalo=3600 # Colocar cada cuántos segundos se respaldarán los archivos

# Rutas de origen, respaldo y destino de los archivos

origen_raw="/home/escaramujo/datosPrueba/raw_${fecha}.dat"
origen_trad="/home/escaramujo/datosPrueba/cuentas_por_minuto_trad_${fecha}.dat"
respaldo_raw="/media/escaramujo/ADATA UFD/data/raw_${fecha}.dat"
respaldo_trad="/media/escaramujo/ADATA UFD/data/cuentas_por_minuto_trad_${fecha}.dat"
destino_raw="${cluster}:/home/escaramujo8/datos_flujo_escaramujo/raw_${fecha}.dat"
destino_trad="${cluster}:/home/escaramujo8/datos_flujo_escaramujo/cuentas_por_minuto_trad_${fecha}.dat"

# # # # # # # # # # # #
#  Zona de no tocar   #
# # # # # # # # # # # #

trap "detener_script" SIGINT

detener_script() {
    echo -e "Deteniendo el script..."
    
    # Respaldo antes de eliminar archivos
    if [ -f "$origen_raw" ]; then
        echo -e "\e[33mRespaldando datos antes de eliminar...\e[0m"
        scp "$origen_raw" "$destino_raw"
        if [ $? -eq 0 ]; then
            echo -e "\e[32mDatos en bruto subidos correctamente a \e[45m$destino_raw.\e[0m"
            cp "$origen_raw" "$respaldo_raw"
            echo -e "\e[32mDatos en bruto respaldados en \e[45m$respaldo_raw.\e[0m"
        else
            echo -e "\e[31mError al subir datos en bruto al clúster.\e[0m"
        fi
        
        rm "$origen_raw"
        echo -e "\e[33m\e[46mArchivo original \e[47m$origen_raw eliminado.\e[0m"
    else
        echo -e "\e[31mArchivo original \e[47m$origen_raw no encontrado o ya eliminado.\e[0m"
    fi

    if [ -f "$origen_trad" ]; then
        echo -e "\e[33mRespaldando datos antes de eliminar...\e[0m"
        scp "$origen_trad" "$destino_trad"
        if [ $? -eq 0 ]; then
            echo -e "\e[32mDatos traducidos subidos correctamente a \e[45m$destino_trad.\e[0m"
            cp "$origen_trad" "$respaldo_trad"
            echo -e "\e[32mDatos traducidos respaldados en \e[45m$respaldo_trad.\e[0m"
        else
            echo -e "\e[31mError al subir los datos traducidos al clúster.\e[0m"
        fi
        
        rm "$origen_trad"
        echo -e "\e[33m\e[46mArchivo original \e[47m$origen_trad eliminado.\e[0m"
    else
        echo -e "\e[31mArchivo original \e[47m$origen_trad no encontrado o ya eliminado.\e[0m"
    fi

    exit 0
}


while true; do

    echo -e "\e[33m\e[44mFecha y hora de ejecución: $(date "+%d-%m-%Y %H:%M:%S")\e[0m"

    if [ -f "$origen_raw" ]; then
        scp "$origen_raw" "$destino_raw"
        if [ $? -eq 0 ]; then
            echo -e "\e[32mDatos en bruto subidos correctamente a \e[45m$destino_raw.\e[0m"
            cp "$origen_raw" "$respaldo_raw"
            echo -e "\e[32mDatos en bruto respaldados en \e[45m$respaldo_raw.\e[0m"
        else
            echo -e "\e[31mError al subir datos en bruto al clúster.\e[0m"
        fi
    else
        echo -e "\e[31mDatos en bruto $origen_raw no encontrado.\e[0m"
    fi

    if [ -f "$origen_trad" ]; then
        scp "$origen_trad" "$destino_trad"
        if [ $? -eq 0 ]; then
            echo -e "\e[32mDatos traducidos subidos correctamente a \e[45m$destino_trad.\e[0m"
            cp "$origen_trad" "$respaldo_trad"
            echo -e "\e[32mDatos traducidos respaldados en \e[45m$respaldo_trad.\e[0m"
        else
            echo -e "\e[31mError al subir los datos traducidos al clúster.\e[0m"
        fi
    else
        echo -e "\e[31mSegundo archivo $origen_trad no encontrado.\e[0m"
    fi

    sleep $intervalo 
done

