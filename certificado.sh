#!/bin/bash

domain_check() {
    read -rp "ingrese su dominio (Ej: midominio.com.ar):" domain
    domain_ip=$(ping "${domain}" -c 1 | sed '1{s/[^(]*(//;s/).*//;q}')
    echo -e "Obteniendo información de IP de la red pública, espere... "
    local_ip=$(curl https://api-ipv4.ip.sb/ip)
    echo -e "IP de resolucion dns de su dominio：${domain_ip}"
    echo -e "Su IP local: ${local_ip}"...
    sleep 2
    if [[ $(echo "${local_ip}" | tr '.' '+' | bc) -eq $(echo "${domain_ip}" | tr '.' '+' | bc) ]]; then
        echo -e "La IP de resolución dns de su dominio coincide con la IP local"
        sleep 2
    else
        echo -e "Asegúrese de que se agrego el registro A correcto al nombre de dominio, de lo contrario, V2ray no se puede utilizar normalmente "
        echo -e "La IP de resolución DNS de su dominio no coincide con la IP local. ¿Quieres continuar con la instalación?（y/n）" && read -r install
        case $install in
        [yY][eE][sS] | [yY])
            echo -e "Continuando con la instalacion... "
            sleep 2
            ;;
        *)
            echo -e "instalacion canselada... "
            exit 2
            ;;
        esac
    fi
}

port_exist_check() {
    if [[ 0 -eq $(lsof -i:"$1" | grep -i -c "listen") ]]; then
        echo -e "puerto $1 no esta ocupado"
        sleep 1
    else
        echo -e "Se detecto que el puerto $1 esta ocupado"
        lsof -i:"$1"
        echo -e "en 5s se intentara liberar el puerto"
        sleep 5
        lsof -i:"$1" | awk '{print $2}' | grep -v "PID" | xargs kill -9
        echo -e "el puerto se libero"
        sleep 1
    fi
}

ssl_judge_and_install() {
    if [[ -f "/data/v2ray.key" || -f "/data/v2ray.crt" ]]; then
        echo "/data Ya existe un certificado"
        echo -e "eliminar o no [Y/N]?"
        read -r ssl_delete
        case $ssl_delete in
        [yY][eE][sS] | [yY])
            rm -rf /data/*
            echo -e "eliminado"
            ;;
        *) ;;

        esac
    fi

    if [[ -f "/data/v2ray.key" || -f "/data/v2ray.crt" ]]; then
        echo "El archivo de certificado ya existe"
    elif [[ -f "$HOME/.acme.sh/${domain}_ecc/${domain}.key" && -f "$HOME/.acme.sh/${domain}_ecc/${domain}.cer" ]]; then
        echo "El archivo de certificado ya existe"
        "$HOME"/.acme.sh/acme.sh --installcert -d "${domain}" --fullchainpath /data/v2ray.crt --keypath /data/v2ray.key --ecc
        judge "Certificado aplicado"
    else
        ssl_install
        acme
    fi
}

ssl_install() {
    apt install socat netcat -y

    curl https://get.acme.sh | sh
}

acme() {
    if "$HOME"/.acme.sh/acme.sh --issue -d "${domain}" --standalone -k ec-256 --force --test; then
        echo -e "SSL La prueba del certificado se emite con éxito y comienza la emisión oficial"
        rm -rf "$HOME/.acme.sh/${domain}_ecc"
        sleep 2
    else
        echo -e "Error en la emisión de la prueba del certificado SSL"
        rm -rf "$HOME/.acme.sh/${domain}_ecc"
        exit 1
    fi

    if "$HOME"/.acme.sh/acme.sh --issue -d "${domain}" --standalone -k ec-256 --force; then
        echo -e "SSL El certificado se genera con éxito"
        sleep 2
        mkdir /data
        if "$HOME"/.acme.sh/acme.sh --installcert -d "${domain}" --fullchainpath /data/v2ray.crt --keypath /data/v2ray.key --ecc --force; then
            echo -e "La configuración del certificado es exitosa"
            sleep 2
        fi
    else
        echo -e "Error al generar el certificado SSL"
        rm -rf "$HOME/.acme.sh/${domain}_ecc"
        exit 1
    fi
}

domain_check
port_exist_check 80
port_exist_check 443
ssl_judge_and_install
