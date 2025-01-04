#!/bin/bash

# Aquí se colocan las rutas de respaldo de los archivos, una ruta a un disco físico y una a un servidor
ruta_fisica="/media/escaramujo/ADATA UFD/datos"
ruta_server="/home/escaramujo8/datos_flujo_escaramujo"

cluster="148.222.27.225"
user_cluster="escaramujo8"

# # # # # # # # # # # 
# Zona de no tocar  #
# # # # # # # # # # # 

escaramujo="\e[93mE\e[91ms\e[95mc\e[94ma\e[92mr\e[97ma\e[93mm\e[91mu\e[95mj\e[94mo"

quince_dias=$(( 15 * 24 * 3600))
diferencia=$(( 0 ))

check_respaldo="true"
check_clus="true"
check_fis="true"

name_raw=""
name_trad=""
origen_raw=""
origen_trad=""

respaldo_raw=""
respaldo_trad=""
destino_raw=""
destino_trad=""

origen=$(pwd)

archivos() {
    
    local fecha="$1"
    
    name_raw="raw_${fecha}.dat"
    name_trad="trad_${fecha}.dat"
    origen_raw="${origen}/${name_raw}"
    origen_trad="${origen}/${name_trad}"
    
    respaldo_raw="${ruta_fisica}/${name_raw}"
    respaldo_trad="${ruta_fisica}/${name_trad}"
    destino_raw="${ruta_server}/${name_raw}"
    destino_trad="${ruta_server}/${name_trad}"
    
}

respaldo() {
    local origen="$1"
    local destino="$2"
    local tipo="$3"
    local mensaje_success="$4"
    local mensaje_error="$5"
    
    if [ -f "$origen" ]; then
        if [[ "$tipo" == "scp" ]]; then
            scp "$origen" "$destino"
        elif [[ "$tipo" == "cp" ]]; then
            cp "$origen" "$destino"
        fi

        if [ $? -eq 0 ]; then
            echo -e "\e[1m\e[32m$mensaje_success\e[0m"
        else
            echo -e "\e[1m\e[31m$mensaje_error\e[0m"
        fi
    fi
}

# Esta función es la bienvenida al usuario, comprueba que la conexión al clúster y la ruta física sean funcionales

bienvenida() {
    
echo -e "\e[93m ____    ____  ________  _________   ______        _       \e[0m"
echo -e "\e[91m|_   \  /   _||_   __  ||  _   _  |.' ____ \      / \      \e[0m"
echo -e "\e[95m  |   \/   |    | |_ \_||_/ | | \_|| (___ \_|    / _ \     \e[0m"
echo -e "\e[94m  | |\  /| |    |  _| _     | |     _.____\`.    / ___ \    \e[0m"
echo -e "\e[92m _| |_\/_| |_  _| |__/ |   _| |_   | \____) | _/ /   \ \_  \e[0m"
echo -e "\e[97m|_____||_____||________|  |_____|   \______.'|____| |____|  \e[0m"
echo -e "\e[1m\e[97m\e[1m"
cat << 'EOF'
Simplificando el uso de Escaramujo, Quarknet y Minicom.
Por: Daniel Alberto García Sánchez - dan030502@gmail.com
EOF
echo -e "\e[0m"

# # # # # # # # # # # # # # # # # # # # # 
# Zona de comprobar que todo esté bien  #
# # # # # # # # # # # # # # # # # # # # #

# Comprobar la existencia y validez del clúster

echo -e "\e[1m\e[33mComprobando conexión con el clúster\e[0m"

if ! ping -c 1 ${cluster} &> /dev/null; then
	echo -e "\033[F\e[1m\e[31mNo se puede conectar a ${ruta_server%:*}. \e[0m"
	
	while true; do
    		
        echo -e "\e[1m\e[33m¿Continuar? (s/n): \e[0m"
        read -p "" continuar_clus

        if [[ "$continuar_clus" == "s" || "$continuar_clus" == "S" ]]; then
            echo -e "\e[1m\e[32mContinuando...\e[0m"
            check_clus=false
            break
        elif [[ "$continuar_clus" == "n" || "$continuar_clus" == "N" ]]; then
            echo -e "\e[1m\e[31mDeteniendo...\e[0m"
            exit 1
        else
            echo -e "\e[1m\e[33mOpción inválida. Por favor, ingresa 's' para sí o 'n' para no.\e[0m"
        fi
        
    done
else
    echo -e "\033[F\e[1m\e[32mConexión con ${ruta_server%:*} exitosa...\e[0m"
fi

# Comprobar que se puede efectuar un respaldo físico

echo -e "\e[1m\e[33mValidando ruta de respaldo local...\e[0m"
if ! mountpoint -q "${ruta_fisica%/datos*}"; then
    echo -e "\033[F\e[1m\e[31mNo se encuentra la ruta ${ruta_fisica}. \e[0m"
    
    while true; do
    		
        echo -e "\e[1m\e[33m¿Continuar? (s/n): \e[0m"
        read -p "" continuar_fis

        if [[ "$continuar_fis" == "s" || "$continuar_fis" == "S" ]]; then
            echo -e "\e[1m\e[32mContinuando...\e[0m"
            check_fis=false
            break
        elif [[ "$continuar_fis" == "n" || "$continuar_fis" == "N" ]]; then
            echo -e "\e[1m\e[31mDeteniendo...\e[0m"
            exit 1
        else
            echo -e "\e[1m\e[33mOpción inválida. Por favor, ingresa 's' para sí o 'n' para no.\e[0m"
        fi
    
    done
else
    echo -e "\033[F\e[1m\e[32mRuta de respaldo local validada...\e[0m"
fi

# Revisamos si el sistema de respaldo funciona

if [[ "$check_clus" == "false" && "$check_fis" == "false" ]]; then
    echo -e "\e[1m\e[31mNo se han proporcionado una ruta o servidor de respaldo válidos. No se crearán respaldos de los datos.\e[0m"
    
    while true; do
    		
        echo -e "\e[1m\e[33m¿Continuar? (s/n): \e[0m"
        read -p "" continuar_res

        # Comprobar si la entrada es válida
        if [[ "$continuar_res" == "s" || "$continuar_res" == "S" ]]; then
            echo -e "\e[1m\e[32mContinuando...\e[0m"
            echo -e "\e[41m\e[93m\e[1m\e[5mADVERTENCIA: NO se respaldarán los datos en nungún lado, se generará un archivo dentro de la carpeta de trabajo.\e[0m"
            check_respaldo=false
            break
        elif [[ "$continuar_res" == "n" || "$continuar_res" == "N" ]]; then
            echo -e "\e[1m\e[31mDeteniendo...\e[0m"
            exit 1
        else
            # Mensaje de error para entrada inválida
            echo -e "\e[1m\e[33mOpción inválida. Por favor, ingresa 's' para sí o 'n' para no.\e[0m"
        fi
    
    done
else
    check_respaldo=true
fi

}

# Esta función es el loop de inicio del detector, una vez se pone a trabajar espera a que se configure la placa QuarkNet

loop_principal() {

bienvenida

# Inicia el protocolo de respaldo, traducción y toma de datos

echo -e "\n\e[1m\e[92mIniciando ${escaramujo}\e[92m...\e[0m"

echo -e "\e[1m\e[35mPara comenzar, ingrese los parámetros del periodo para la traducción y respaldo de los datos generados por minicom.\n\e[0m"

# Solicitar periodo para la traducción
echo -e "\e[1m\e[36mIngrese el periodo en minutos para la traducción de datos: \e[0m"
read -p "" periodo_trad

# Solicitar periodo para el respaldo
echo -e "\e[1m\e[36mIngrese el periodo en minutos para el respaldado de datos: \e[0m"
read -p "" periodo_resp

# # # # # # # # # # # # # # # # # # # # # # # 
# Zona de cuentitas y creación de archivos  #
# # # # # # # # # # # # # # # # # # # # # # #

periodo_resp=$((periodo_resp * 60))

fecha=$(date +"%y%m%d%H%M")
medicion_inicial=$(date +"%s")
medicion=$(date +"%s")

# Creación de los archivos de control
archivos "$fecha"

echo -e "$name_raw\n$name_trad\n$periodo_trad" > temp

echo -e "\e[1m\e[33m\nPreparando toma de datos, configure la tarjeta QuarkNet.\e[0m"

sudo sh -c "lxterminal -e 'minicom -C $origen_raw'" &

echo -e "\e[33m\e[1m\e[5mPresione ENTER cuando haya terminado de configurar la tarjeta QuarkNet.\e[0m"
read -p ""

echo -e "\033[F\033[F\033[F"
echo -e "\e[32m\e[1mPresione ENTER cuando haya terminado de configurar la tarjeta QuarkNet.\e[0m"

sleep 1
pid_minicom=$(pgrep -f minicom)

g++ -o wono wono.cpp
lxterminal -e "./wono < temp"

echo -e "\e[33m\e[1m\e[5mIniciando traducción y recopilado de datos.\e[0m"

sleep 1
pid_wono=$(pgrep -f "./wono")

rm temp

trap "detener" SIGINT

echo -e "$medicion_inicial\n$fecha\n$periodo_trad\n$periodo_resp\n$medicion" > killcheck

# Ciclo de respaldo 
while true; do
    
    subida
    
    # Aquí guardamos una fecha para el killcheck, así tenemos un registro en caso de que la máquina truene, por seguridad para evitar la sobrecarga de la raspberry el sistema se reinicia cada 15 días
    
    medicion=$(date +"%s")
    sed -i '$s/.*/'"$medicion"'/' killcheck 

    diferencia=$(( medicion - medicion_inicial ))

    if (( diferencia >= quince_dias )); then
        echo -e "\n\e[1m\e[44m\e[93mHan pasado 15 días desde que inició la medición, iniciando reinicio de seguridad...\e[0m"
        reinicio
        break
    fi
    
    sleep $periodo_resp
    
done

}

# Esta función reinicia el detector en caso de ser necesario

reinicio() {
    
    read -r medicion_inicial < <(sed -n '1p' killcheck)
    read -r medicion < <(sed -n '5p' killcheck)
    diferencia=$(( medicion - medicion_inicial ))
    
    if (( diferencia <= quince_dias )); then 
        echo -e "\e[33m\e[1mParece ser que ocurrió una interrupción del detector Escaramujo, reiniciando la medición.\e[0m"
        duranterior=$(( diferencia / (24 * 3600) ))
        echo -e "\e[33m\e[1mLa última medición duró \e[35m${duranterior} \e[33mdías.\e[0m"
        read -r fecha < <(sed -n '2p' killcheck)
        read -r periodo_trad < <(sed -n '3p' killcheck)
        read -r periodo_resp < <(sed -n '4p' killcheck)
        
        archivos "$fecha"
        
        echo -e "\e[33m\e[1mBuscando y respaldando archivos anteriores.\e[0m"
        
        subida
        
    fi
    
    trap "detener" SIGINT
    
    rm -f killcheck
    
    echo -e "\n\e[1m\e[92mReiniciando ${escaramujo}\e[92m...\e[0m"
    
    fecha=$(date +"%y%m%d%H%M")
    medicion_inicial=$(date +"%s")
    medicion=$(date +"%s")
    
    echo -e "$medicion_inicial\n$fecha\n$periodo_trad\n$periodo_resp\n$medicion" > killcheck
    
    archivos "$fecha"

    echo -e "$name_raw\n$name_trad\n$periodo_trad" > temp

    sudo sh -c "lxterminal -e 'minicom -C $origen_raw'" &

    echo -e "\e[33m\e[1m\e[5mReiniciando minicom.\e[0m"
    sleep 300
    echo -e "\033[F\e[92m\e[1mMinicom se ha iniciado exitosamente.\e[0m"
    
    sleep 1
    pid_minicom=$(pgrep -f minicom)
    
    echo -e "\e[33m\e[1mReiniciando traducción y recopilado de datos.\e[0m"
    
    g++ -o wono wono.cpp
    lxterminal -e "./wono < temp"

    sleep 1
    pid_wono=$(pgrep -f "./wono")
    
    while true; do
        
        subida 
        
        medicion=$(date +"%s")
        sed -i '$s/.*/'"$medicion"'/' killcheck 

        diferencia=$(( medicion - medicion_inicial ))
        
        
        if (( diferencia >= quince_dias )); then
            echo -e "\n\e[1m\e[44m\e[93mHan pasado 15 días desde que inició la medición, iniciando reinicio de seguridad...\e[0m"
            reinicio
            break
        fi
    
        sleep $periodo_resp
    
    done
}

subida() {

# Respaldo en el clúster (si está habilitado)
if [[ "$check_clus" == "true" ]]; then
    respaldo "$origen_raw" "$destino_raw" "scp" \
    "Datos en bruto subidos correctamente a: $destino_raw" \
    "No se pudieron subir los datos en bruto a $destino_raw"

    respaldo "$origen_trad" "$destino_trad" "scp" \
    "Datos traducidos subidos correctamente a: $destino_trad" \
    "No se pudieron subir los datos traducidos a $destino_trad"
fi

# Respaldo físico (si está habilitado)
if [[ "$check_fis" == "true" ]]; then
    respaldo "$origen_raw" "$respaldo_raw" "cp" \
    "Datos en bruto respaldados correctamente en: $respaldo_raw" \
    "No se pudieron respaldar los datos en bruto en $respaldo_raw"
                    
    respaldo "$origen_trad" "$respaldo_trad" "cp" \
    "Datos traducidos respaldados correctamente en: $respaldo_trad" \
    "No se pudieron respaldar los datos traducidos en $respaldo_trad"
fi

}

# Función para detener la traducción y respaldo de la toma de datos, hace un último respaldo antes de detener cualquier cosa

detener() {
    echo -e "\n\e[1m\e[93m\e[41mADVERTENCIA: está a punto de detener la toma, traducción y respaldo de datos. ¿Continuar? (s/n) \e[0m"
    read -p "" cerrar
    rm -f killcheck
    
    if [[ $cerrar == "s" ]]; then
        echo "Deteniendo minicom, traducción y respaldo de datos..."
        
        echo "Cerrando minicom..."
        kill -9 $pid_minicom
        
        echo "Deteniendo traducción de datos..."
        kill -9 $pid_wono
        
        if [[ $check_respaldo == "true" ]]; then
            echo "Ejecutando función de respaldo final..."

            subida
            
        fi

        echo "Proceso finalizado."
        exit 0
    else
        echo "Operación cancelada."
    fi
}

if [[ ! -f killcheck ]]; then
    loop_principal
else
    reinicio
fi
