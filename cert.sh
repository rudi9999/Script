#!/bin/bash

barra="==========================================="

domain_check() {
    clear
    echo $barra
    echo "   generador de certificado ssl/tls"
    echo $barra
    echo -e " ingrese su dominio (ej: midominio.com.ar)"
    read -rp " >>> " domain

    echo -e "\n Oteniendo resolucion dns de su dominio..."
    domain_ip=$(ping "${domain}" -c 1 | sed '1{s/[^(]*(//;s/).*//;q}')

    echo -e "\n Oteniendo IP local..."
    local_ip=$(wget -qO- ipv4.icanhazip.com)
    sleep 2

    if [[ $(echo "${local_ip}" | tr '.' '+' | bc) -eq $(echo "${domain_ip}" | tr '.' '+' | bc) ]]; then
        while :
        do
            clear
            echo $barra
            echo " Su dominio: ${domain}"
            echo $barra
            echo -e " IP dominio:  \033[1;49;32m${domain_ip}\033[0m"
            echo -e " IP local:    \033[1;49;32m${local_ip}\033[0m"
            echo $barra
            echo -e "      \033[1;49;32mComprovacion exitosa\033[0m"
            echo -e " La IP de su dominio coincide\n con la IP local, desea continuar?"
            echo -ne " si o no [S/N]: "
            read opcion
            case $opcion in
                [Yy]|[Ss]) break;;
                [Nn]) echo -e "\n instalacion cancelada..." && sleep 2 && exit;;
                *) echo -e "\n selecione (S) para si o (N) para no!" && sleep 2;;
            esac
        done
    else
        while :
        do
            clear
            echo $barra
            echo " Su dominio: ${domain}"
            echo $barra
            echo -e " IP dominio:  \033[3;49;31m${domain_ip}\033[0m"
            echo -e " IP local:    \033[3;49;33m${local_ip}\033[0m"
            echo $barra
            echo -e "      \033[3;49;31mComprovacion fallida\033[0m"
            echo -e " La IP de su dominio no coincide\n con la IP local"
            echo $barra
            echo -e " > Asegúrese que se agrego el registro"
            echo -e "   (A) correcto al nombre de dominio."
            echo -e " > Asegurece que su registro (A)"
            echo -e "   no posea algun tipo de seguridad"
            echo -e "   adiccional y que solo resuelva DNS."
            echo -e " > De lo contrario, V2ray no se puede"
            echo -e "   utilizar normalmente..."
            echo $barra
            echo -e " desea continuar?"
            echo -ne " si o no [S/N]: "
            read opcion
            case $opcion in
                [Yy]|[Ss]) break;;
                [Nn]) echo -e "\n instalacion cancelada..." && sleep 2 && exit;;
                *) echo -e "\n selecione (S) para si o (N) para no!" && sleep 2;;
            esac
        done
    fi
}

port_exist_check() {
    while :
    do
    clear
    echo $barra
    echo " Para la compilacion del certificado"
    echo " se requiere que los siguientes puerto"
    echo " esten libres."
    echo "        '80' '443'"
    echo " este script intentara detener"
    echo " cualquier proseso que este"
    echo " usando estos puertos"
    echo $barra
    echo " desea continuar?"
    echo -ne " [S/N]:"
    read opcion

    case $opcion in
        [Ss]|[Yy])         
                    ports=('80' '443')
                    clear
                        echo $barra
                        echo "      comprovando puertos..."
                        echo $barra
                        sleep 2
                        for i in ${ports[@]}; do
                            [[ 0 -eq $(lsof -i:$i | grep -i -c "listen") ]] && {
                                echo -e "    \033[3;49;32m$i [OK]\033[0m" 
                            } || {
                                echo -e "    \033[3;49;31m$i [fail]\033[0m"
                            }
                        done
                        echo $barra
                        for i in ${ports[@]}; do
                            [[ 0 -ne $(lsof -i:$i | grep -i -c "listen") ]] && {
                                echo -ne "       liberando puerto $i ... "
                                lsof -i:$i | awk '{print $2}' | grep -v "PID" | xargs kill -9
                                echo -e "[OK]"
                            }
                        done;;
        [Nn]) echo -e "\n instalacion cancelada..." && sleep 2 && exit;;
        *) echo -e "\n selecione (S) para si o (N) para no!" && sleep 2;;
    esac
    echo " ENTER continuar, CRTL + C para canselar..."
    read foo
    break
    done
}

ssl_judge_and_install() {
    while :
    do

    if [[ -f "/data/v2ray.key" || -f "/data/v2ray.crt" ]]; then
        clear
        echo $barra
        echo " ya existen archivos de certificados"
        echo " en el directorio asignado."
        echo $barra
        echo " ENTER para canselar la instacion."
        echo " 'S' para eliminar y continuar"
        echo $barra
        echo -ne " opcion: "
        read -r ssl_delete
        case $ssl_delete in
        [Ss]|[Yy])
                    rm -rf /data/*
                    echo -e " archivos removidos..!"
                    sleep 2
                    ;;
        *) break;;
        esac
    fi

    if [[ -f "$HOME/.acme.sh/${domain}_ecc/${domain}.key" || -f "$HOME/.acme.sh/${domain}_ecc/${domain}.cer" ]]; then
        echo $barra
        echo " ya existe un almacer de certificado"
        echo " bajo este nombre de dominio"
        echo $barra
        echo " ENTER canselar instalacion"
        echo " D para eliminar"
        echo " R para restaurar"
        echo $barra
        echo -ne " opcion: "
        read opcion
        case $opcion in
            [Dd])
                        echo " eliminando almacen cert..."
                        rm -rf $HOME/.acme.sh/${domain}_ecc
                        ;;
            [Rr])
                        echo " restaurando certificados..."
                        sleep 2
                        "$HOME"/.acme.sh/acme.sh --installcert -d "${domain}" --fullchainpath /data/v2ray.crt --keypath /data/v2ray.key --ecc
                        ;;
            *) break;;
        esac
    fi
    acme
    done
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
        echo -e "SSL El certificado se genero con éxito"
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
ssl_install
domain_check
port_exist_check
ssl_judge_and_install
