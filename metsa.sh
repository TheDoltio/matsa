#!/bin/bash

# Aquí se colocan las rutas de respaldo, es decir, la ruta a un disco físico y al clúster
ruta_fisica="/media/escaramujo/ADATA UFD/datos"
ruta_nube="/home/escaramujo8/datos_flujo_escaramujo"

cluster="148.222.47.225"
user_cluster="escaramujo8"

# # # # # # # # # # # 
# Zona de no tocar  #
# # # # # # # # # # # 

echo -e "\e[1m\e[33m"
cat << 'EOF'
 ____    ____  ________  _________   ______        _       
|_   \  /   _||_   __  ||  _   _  |.' ____ \      / \      
  |   \/   |    | |_ \_||_/ | | \_|| (___ \_|    / _ \     
  | |\  /| |    |  _| _     | |     _.____`.    / ___ \    
 _| |_\/_| |_  _| |__/ |   _| |_   | \____) | _/ /   \ \_  
|_____||_____||________|  |_____|   \______.'|____| |____| 
Simplificando el uso de Escaramujo, Quarknet y Minicom.
Por: Daniel Alberto García Sánchez - dan030502@gmail.com
EOF
echo -e "\e[0m"

echo -e "\e[1m\e[35mPara comenzar, ingrese los parámetros del periodo para la traducción y respaldo de los datos generados por minicom.\n\e[0m"

# Solicitar periodo para la traducción
echo -e "\e[1m\e[36mIngrese el periodo en minutos para la traducción de datos: \e[0m"
read -p "" periodo_trad

# Solicitar periodo para el respaldo
echo -e "\e[1m\e[36mIngrese el periodo en minutos para el respaldado de datos: \e[0m"
read -p "" periodo_resp

ruta_cluster="${user_cluster}@${cluster}:${ruta_nube}"
periodo_resp=$((periodo_resp * 60))

fecha=$(date +"%y%m%d%H%M")
origen=$(pwd)

name_raw="raw_${fecha}.dat"
name_trad="trad_${fecha}.dat"
origen_raw="${origen}/${name_raw}"
origen_trad="${origen}/${name_trad}"

echo -e "\e[1m\e[33m\nPreparando toma de datos, configure la tarjeta QuarkNet.\e[0m"

# Crear un archivo temporal que servirá de input para la traducción de datos
echo -e "$name_raw\n$name_trad\n$periodo_trad" > temp

# Iniciar minicom en una nueva terminal y verificar si se abre correctamente
if ! sudo lxterminal -e "minicom -C '$origen_raw'" ; then
    echo -e "\e[1m\e[31mError al ejecutar minicom.\e[0m"
    exit 1
fi

echo -e "\e[1m\e[33mPresione ENTER cuando haya terminado de configurar la tarjeta QuarkNet.\e[0m"
read -p ""

sleep 1
pid_minicom=$(pgrep -f minicom)

g++ -o wono wono.cpp
lxterminal -e "./wono < temp"

sleep 1
pid_wono=$(pgrep -f "./wono")

rm temp

# Rutas para subir y respaldar datos
respaldo_raw="${ruta_fisica}/${name_raw}"
respaldo_trad="${ruta_fisica}/${name_trad}"
destino_raw="${ruta_cluster}/${name_raw}"
destino_trad="${ruta_cluster}/${name_trad}"

trap "detener" SIGINT

# Función para detener la traducción y respaldo de la toma de datos
detener() {
    echo -e "\e[1m\e[35m\e[41m ADVERTENCIA: está a punto de detener la toma, traducción y respaldo de datos. ¿Continuar? (s/n) \e[0m"   
    read -p "" cerrar
    
    if [[ $cerrar == "s" ]]; then
        echo "Deteniendo minicom, traducción y respaldo de datos..."
        
        echo "Cerrando minicom..."
        kill -9 $pid_minicom
        
        echo "Deteniendo traducción de datos..."
        kill -9 $pid_wono
        
        if [[ $check_respaldo == true ]]; then
            echo "Ejecutando función de respaldo final..."

            # Respaldo en el clúster (si está habilitado)
            if [[ "$check_clus" == true ]]; then
                if [ -f "$origen_raw" ]; then
                    scp "$origen_raw" "$destino_raw"
                    if [ $? -eq 0 ]; then
                        echo -e "\e[1m\e[32mDatos en bruto subidos correctamente a: \e[35m$destino_raw\e[32m.\e[0m"
                    else
                        echo -e "\e[1m\e[31mNo se pudieron subir los datos en bruto a \e[36m$destino_raw\e[31m.\e[0m"
                    fi
                fi
            fi

            # Respaldo físico (si está habilitado)
            if [[ "$check_fis" == true ]]; then
                if [ -f "$origen_raw" ]; then
                    cp "$origen_raw" "$respaldo_raw"
                    if [ $? -eq 0 ]; then
                        echo -e "\e[1m\e[32mDatos en bruto respaldados correctamente en: \e[35m$respaldo_raw\e[32m.\e[0m"
                    else
                        echo -e "\e[1m\e[31mNo se pudieron respaldar los datos en bruto en \e[36m$respaldo_raw\e[31m.\e[0m"
                    fi
                fi
            fi

            # Respaldo de datos traducidos en el clúster (si está habilitado)
            if [[ "$check_clus" == true ]]; then
                if [ -f "$origen_trad" ]; then
                    scp "$origen_trad" "$destino_trad"
                    if [ $? -eq 0 ]; then
                        echo -e "\e[1m\e[32mDatos traducidos subidos correctamente a: \e[35m$destino_trad\e[32m.\e[0m"
                    else
                        echo -e "\e[1m\e[31mNo se pudieron subir los datos traducidos a \e[36m$destino_trad\e[31m.\e[0m"
                    fi
                fi
            fi

            # Respaldo físico de datos traducidos (si está habilitado)
            if [[ "$check_fis" == true ]]; then
                if [ -f "$origen_trad" ]; then
                    cp "$origen_trad" "$respaldo_trad"
                    if [ $? -eq 0 ]; then
                        echo -e "\e[1m\e[32mDatos traducidos respaldados correctamente en: \e[35m$respaldo_trad\e[32m.\e[0m"
                    else
                        echo -e "\e[1m\e[31mNo se pudieron respaldar los datos traducidos en \e[36m$respaldo_trad\e[31m.\e[0m"
                    fi
                fi
            fi
        fi

        echo "Proceso finalizado."
        exit 0
    else
        echo "Operación cancelada."
    fi
}


echo -e "\e[1m\e[33mComprobando conexión con el clúster\e[0m"
if ! ping -c 1 ${cluster} &> /dev/null; then
    echo -e "\e[1m\e[31mNo se puede conectar a ${ruta_cluster%:*}. \e[0m"
    echo -e "\e[1m\e[33m¿Continuar? (s/n): \e[0m"
    read -p "" continuar_clus
    if [[ "$continuar_clus" != "s" && "$continuar_clus" != "S" ]]; then
        echo -e "\e[1m\e[31mDeteniendo...\e[0m"
        exit 1
    else
        echo -e "\e[1m\e[32mContinuando...\e[0m"
        check_clus=false
    fi
else
    echo -e "\e[1m\e[32mConexión con ${ruta_cluster%:*} exitosa...\e[0m"
    check_clus=true
fi

echo -e "\e[1m\e[33mValidando ruta de respaldo...\e[0m"
if ! mountpoint -q "${ruta_fisica%/datos*}"; then
    echo -e "\e[1m\e[31mNo se encuentra la ruta ${ruta_fisica}. \e[0m"
    echo -e "\e[1m\e[33m¿Continuar? (s/n): \e[0m"
    read -p "" continuar_fis
    if [[ "$continuar_fis" != "s" && "$continuar_fis" != "S" ]]; then
        echo -e "\e[1m\e[31mDeteniendo...\e[0m"
        exit 1
    else
        echo -e "\e[1m\e[32mContinuando...\e[0m"
        check_fis=false
    fi
else
    echo -e "\e[1m\e[32mRuta de respaldo ${ruta_fisica} válida.\e[0m"
    check_fis=true
fi

if [[ ! "$check_clus" && ! "$check_fis" ]]; then
    echo -e "\e[1m\e[31mNo se han proporcionado una ruta o servidor de respaldo válidos. No se crearán respaldos de los datos.\e[0m"
    read -p -e "\e[1m\e[33m¿Continuar? (s/n): \e[0m" continuar_res
    if [[ "$continuar_res" != "s" && "$continuar_res" != "S" ]]; then
        echo -e "\e[1m\e[31mDeteniendo...\e[0m"
        exit 1
    else
        echo -e "\e[1m\e[32mContinuando...\n ADVERTENCIA No se respaldarán los datos en ningún lado.\e[0m"
        check_respaldo=false 
    fi
else
    check_respaldo=true
    echo -e "\e[1m\e[35mIniciando respaldado de datos...\e[0m"
fi

while $check_respaldo; do
    echo -e "\e[1m\e[33m\e[44m\n$(date "+%d-%m-%Y %H:%M:%S")\e[0m"
    
    if [[ "$check_clus" ]]; then
        if [ -f "$origen_raw" ]; then
            scp "$origen_raw" "$destino_raw"
            if [ $? -eq 0 ]; then
                echo -e "\e[1m\e[32mDatos en bruto respaldados correctamente en: \e[35m$respaldo_raw\e[32m.\e[0m"
            else
                echo -e "\e[1m\e[31mNo se pudieron respaldar los datos en \e[36m$destino_raw\e[31m.\e[0m"
            fi
        fi
    fi
    
    if [[ "$check_fis" ]]; then
        if [ -f "$origen_raw" ]; then
            cp "$origen_raw" "$respaldo_raw"
            if [ $? -eq 0 ]; then
                echo -e "\e[1m\e[32mDatos en bruto respaldados correctamente en: \e[35m$respaldo_raw\e[32m.\e[0m"
            else
                echo -e "\e[1m\e[31mNo se pudieron respaldar los datos en \e[36m$respaldo_raw\e[31m.\e[0m"
            fi
        fi
    fi
    
    if [[ "$check_clus" ]]; then
        if [ -f "$origen_trad" ]; then
            scp "$origen_trad" "$destino_trad"
            if [ $? -eq 0 ]; then
                echo -e "\e[1m\e[32mDatos traducidos respaldados correctamente en: \e[35m$respaldo_trad\e[32m.\e[0m"
            else
                echo -e "\e[1m\e[31mNo se pudieron respaldar los datos en \e[36m$destino_trad\e[31m.\e[0m"
            fi
        fi
    fi
    
    if [[ "$check_fis" ]]; then
        if [ -f "$origen_trad" ]; then
            cp "$origen_trad" "$respaldo_trad"
            if [ $? -eq 0 ]; then
                echo -e "\e[1m\e[32mDatos traducidos respaldados correctamente en: \e[35m$respaldo_trad\e[32m.\e[0m"
            else
                echo -e "\e[1m\e[31mNo se pudieron respaldar los datos en \e[36m$respaldo_trad\e[31m.\e[0m"
            fi
        fi
    fi  
    
    sleep $periodo_resp
done

