#!/bin/bash
#19/12/2019
declare -A cor=( [0]="\033[1;37m" [1]="\033[1;34m" [2]="\033[1;31m" [3]="\033[1;33m" [4]="\033[1;32m" )
SCPfrm="/etc/ger-frm" && [[ ! -d ${SCPfrm} ]] && exit
SCPinst="/etc/ger-inst" && [[ ! -d ${SCPinst} ]] && exit
mportas () {
unset portas
portas_var=$(lsof -V -i tcp -P -n | grep -v "ESTABLISHED" |grep -v "COMMAND" | grep "LISTEN")
while read port; do
var1=$(echo $port | awk '{print $1}') && var2=$(echo $port | awk '{print $9}' | awk -F ":" '{print $2}')
[[ "$(echo -e $portas|grep "$var1 $var2")" ]] || portas+="$var1 $var2\n"
done <<< "$portas_var"
i=1
echo -e "$portas"
}
fun_ip () {
MEU_IP=$(ip addr | grep 'inet' | grep -v inet6 | grep -vE '127\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | grep -o -E '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | head -1)
MEU_IP2=$(wget -qO- ipv4.icanhazip.com)
[[ "$MEU_IP" != "$MEU_IP2" ]] && IP="$MEU_IP2" || IP="$MEU_IP"
}
fun_eth () {
eth=$(ifconfig | grep -v inet6 | grep -v lo | grep -v 127.0.0.1 | grep "encap:Ethernet" | awk '{print $1}')
    [[ $eth != "" ]] && {
    msg -bar
    echo -e "${cor[3]} $(fun_trans  "Aplicar el sistema para mejorar los paquetes SSH?")"
    echo -e "${cor[3]} $(fun_trans  "Opciones para usuarios avanzados")"
    msg -bar
    read -p " [S/N]: " -e -i n sshsn
           [[ "$sshsn" = @(s|S|y|Y) ]] && {
           echo -e "${cor[1]} $(fun_trans  "Corrección de problemas de paquetes en SSH...")"
           echo -e " $(fun_trans  "¿Cual es la tasa RX?")"
           echo -ne "[ 1 - 999999999 ]: "; read rx
           [[ "$rx" = "" ]] && rx="999999999"
           echo -e " $(fun_trans  "¿Cuál es la tarifa TX?")"
           echo -ne "[ 1 - 999999999 ]: "; read tx
           [[ "$tx" = "" ]] && tx="999999999"
           apt-get install ethtool -y > /dev/null 2>&1
           ethtool -G $eth rx $rx tx $tx > /dev/null 2>&1
           }
     msg -bar
     }
}
fun_bar () {
comando="$1"
 _=$(
$comando > /dev/null 2>&1
) & > /dev/null
pid=$!
while [[ -d /proc/$pid ]]; do
echo -ne " \033[1;33m["
   for((i=0; i<10; i++)); do
   echo -ne "\033[1;31m##"
   sleep 0.2
   done
echo -ne "\033[1;33m]"
sleep 1s
echo
tput cuu1
tput dl1
done
echo -e " \033[1;33m[\033[1;31m####################\033[1;33m] - \033[1;32m100%\033[0m"
sleep 1s
}
ssl_stunel () {
[[ $(mportas|grep stunnel4|head -1) ]] && {
echo -e "\033[1;33m $(fun_trans  "Parando Stunnel")"
msg -bar
fun_bar "apt-get purge stunnel4 -y"
msg -bar
echo -e "\033[1;33m $(fun_trans  "Parado Con Exito!")"
msg -bar
return 0
}
echo -e "\033[1;32m $(fun_trans  "INSTALADOR SSL By MOD MX")"
msg -bar
echo -e "\033[1;33m $(fun_trans  "Seleccione una puerta de redirección interna.")"
echo -e "\033[1;33m $(fun_trans  "Es decir, un puerto en su servidor para SSL")"
msg -bar
         while true; do
         echo -ne "\033[1;37m"
         read -p " Local-Port: " portx
         if [[ ! -z $portx ]]; then
             if [[ $(echo $portx|grep [0-9]) ]]; then
                [[ $(mportas|grep $portx|head -1) ]] && break || echo -e "\033[1;31m $(fun_trans  "Puerta invalida")"
             fi
         fi
         done
msg -bar
DPORT="$(mportas|grep $portx|awk '{print $2}'|head -1)"
echo -e "\033[1;33m $(fun_trans  "Ahora Prestamos Saber Que Puerta del SSL, Va a Escuchar")"
msg -bar
    while true; do
    read -p " Listen-SSL: " SSLPORT
    [[ $(mportas|grep -w "$SSLPORT") ]] || break
    echo -e "\033[1;33m $(fun_trans  "Esta puerta está en uso")"
    unset SSLPORT
    done
msg -bar
echo -e "\033[1;33m $(fun_trans  "Instalando SSL")"
msg -bar
fun_bar "apt-get install stunnel4 -y"
echo -e "client = no\n[SSL]\ncert = /etc/stunnel/stunnel.pem\naccept = ${SSLPORT}\nconnect = 127.0.0.1:${DPORT}" > /etc/stunnel/stunnel.conf
####Coreccion2.0##### 
openssl genrsa -out stunnel.key 2048 > /dev/null 2>&1

(echo "mx" ; echo "mx" ; echo "mx" ; echo "mx" ; echo "mx" ; echo "mx" ; echo "@Rufu99" )|openssl req -new -key stunnel.key -x509 -days 1000 -out stunnel.crt > /dev/null 2>&1

cat stunnel.crt stunnel.key > stunnel.pem 

mv stunnel.pem /etc/stunnel/
######-------
sed -i 's/ENABLED=0/ENABLED=1/g' /etc/default/stunnel4
service stunnel4 restart > /dev/null 2>&1
msg -bar
echo -e "\033[1;33m $(fun_trans  "INSTALADO CON EXITO")"
msg -bar
rm -rf /etc/ger-frm/stunnel.crt > /dev/null 2>&1
rm -rf /etc/ger-frm/stunnel.key > /dev/null 2>&1
rm -rf /root/stunnel.crt > /dev/null 2>&1
rm -rf /root/stunnel.key > /dev/null 2>&1
return 0
}
ssl_stunel3 () {
[[ $(mportas|grep stunnel4|head -1) ]] && {
echo -e "\033[1;33m $(fun_trans  "Parando Stunnel")"
msg -bar
fun_bar "apt-get purge stunnel4 -y"
msg -bar
echo -e "\033[1;33m $(fun_trans  "Parado Con Exito!")"
msg -bar
return 0
}
clear
msg -bar
echo -e "\033[1;32m $(fun_trans  "INSTALADOR SSL By @Rufu99")"
msg -bar
echo -e "\033[1;33m $(fun_trans  "Seleccione una puerta de redirección interna.")"
echo -e "\033[1;33m $(fun_trans  "Es decir, un puerto en su servidor para SSL")"
msg -bar
         while true; do
         echo -ne "\033[1;37m"
         read -p " Local-Port: " portx
         if [[ ! -z $portx ]]; then
             if [[ $(echo $portx|grep [0-9]) ]]; then
                [[ $(mportas|grep $portx|head -1) ]] && break || echo -e "\033[1;31m $(fun_trans  "Puerta invalida")"
             fi
         fi
         done
msg -bar
DPORT="$(mportas|grep $portx|awk '{print $2}'|head -1)"
echo -e "\033[1;33m $(fun_trans  "Ahora Prestamos Saber Que Puerta del SSL, Va a Escuchar")"
msg -bar
    while true; do
    read -p " Listen-SSL: " SSLPORT
    [[ $(mportas|grep -w "$SSLPORT") ]] || break
    echo -e "\033[1;33m $(fun_trans  "Esta puerta está en uso")"
    unset SSLPORT
    done
msg -bar
echo -e "\033[1;33m $(fun_trans  "Instalando SSL")"
msg -bar
fun_bar "apt-get install stunnel4 -y"
echo -e "client = no\n[SSL]\ncert = /etc/stunnel/stunnel.pem\naccept = ${SSLPORT}\nconnect = 127.0.0.1:${DPORT}" > /etc/stunnel/stunnel.conf
domain_check
}
#----------cerificado ssl/tls---------------------

cancelar(){

  echo -e "\n \033[3;49;31minstalacion cancelada...\033[0m"
 }

continuar(){

  echo -e " \033[3;49;32mEnter para continuar...\033[0m"
 }

domain_check() {
  ssl_install_fun
    clear
    echo -e $BARRA
    echo -e "   \033[1;49;37mgenerador de certificado ssl/tls\033[0m"
    echo -e $BARRA
    echo -e " \033[1;49;37mingrese su dominio (ej: midominio.com.ar)\033[0m"
    echo -ne ' \033[3;49;31m>>>\033[0m '
    read domain

    echo -e "\n \033[1;49;36mOteniendo resolucion dns de su dominio...\033[0m"
    domain_ip=$(ping "${domain}" -c 1 | sed '1{s/[^(]*(//;s/).*//;q}')

    echo -e "\n \033[1;49;36mOteniendo IP local...\033[0m"
    local_ip=$(wget -qO- ipv4.icanhazip.com)
    sleep 2

    while :
    do
    if [[ $(echo "${local_ip}" | tr '.' '+' | bc) -eq $(echo "${domain_ip}" | tr '.' '+' | bc) ]]; then
            clear
            echo -e $BARRA
            echo -e " \033[1;49;37mSu dominio: ${domain}\033[0m"
            echo -e $BARRA
            echo -e " \033[1;49;37mIP dominio:\033[0m  \033[1;49;32m${domain_ip}\033[0m"
            echo -e " \033[1;49;37mIP local:\033[0m    \033[1;49;32m${local_ip}\033[0m"
            echo -e $BARRA
            echo -e "      \033[1;49;32mComprovacion exitosa\033[0m"
            echo -e " \033[1;49;37mLa IP de su dominio coincide\n con la IP local, desea continuar?\033[0m"
            echo -e $BARRA
            echo -ne " \033[1;49;37msi o no [S/N]:\033[0m "
            read opcion
            case $opcion in
                [Yy]|[Ss]) port_exist_check;;
                [Nn]) cancelar && sleep 2;;
                *) echo -e "\n \033[1;49;37mselecione (S) para si o (N) para no!\033[0m" && sleep 2 && continue;;
            esac
    else
            clear
            echo -e $BARRA
            echo -e " \033[1;49;37mSu dominio: ${domain}\033[0m"
            echo -e $BARRA
            echo -e " \033[1;49;37mIP dominio:\033[0m  \033[3;49;31m${domain_ip}\033[0m"
            echo -e " \033[1;49;37mIP local:\033[0m    \033[3;49;31m${local_ip}\033[0m"
            echo -e $BARRA
            echo -e "      \033[3;49;31mComprovacion fallida\033[0m"
            echo -e " \033[4;49;97mLa IP de su dominio no coincide\033[0m\n         \033[4;49;97mcon la IP local\033[0m"
            echo -e $BARRA
            echo -e " \033[1;49;36m> Asegúrese que se agrego el registro"
            echo -e "   (A) correcto al nombre de dominio."
            echo -e " > Asegurece que su registro (A)"
            echo -e "   no posea algun tipo de seguridad"
            echo -e "   adiccional y que solo resuelva DNS."
            echo -e " > De lo contrario, ssl no se puede"
            echo -e "   utilizar normalmente...\033[0m"
            echo -e $BARRA
            echo -e " \033[1;49;37mdesea continuar?"
            echo -ne " si o no [S/N]:\033[0m "
            read opcion
            case $opcion in
                [Yy]|[Ss]) port_exist_check;;
                [Nn]) cancelar && sleep 2;;
                *) echo -e "\n \033[1;49;37mselecione (S) para si o (N) para no!\033[0m" && sleep 2 && continue;;
            esac
        fi
        break
    done
 }

port_exist_check() {
    while :
    do
    clear
    echo -e $barra
    echo -e " \033[1;49;37mPara la compilacion del certificado"
    echo -e " se requiere que los siguientes puerto"
    echo -e " esten libres."
    echo -e "        '80' '443'"
    echo -e " este script intentara detener"
    echo -e " cualquier proseso que este"
    echo -e " usando estos puertos\033[0m"
    echo -e $barra
    echo -e " \033[1;49;37mdesea continuar?"
    echo -ne " [S/N]:\033[0m "
    read opcion

    case $opcion in
        [Ss]|[Yy])         
                    ports=('80' '443')
                    clear
                        echo -e $barra
                        echo -e "      \033[1;49;37mcomprovando puertos...\033[0m"
                        echo -e $barra
                        sleep 2
                        for i in ${ports[@]}; do
                            [[ 0 -eq $(lsof -i:$i | grep -i -c "listen") ]] && {
                                echo -e "    \033[3;49;32m$i [OK]\033[0m" 
                            } || {
                                echo -e "    \033[3;49;31m$i [fail]\033[0m"
                            }
                        done
                        echo -e $barra
                        for i in ${ports[@]}; do
                            [[ 0 -ne $(lsof -i:$i | grep -i -c "listen") ]] && {
                                echo -ne "       \033[1;49;37mliberando puerto $i...\033[1;49;37m "
                                lsof -i:$i | awk '{print $2}' | grep -v "PID" | xargs kill -9
                                echo -e "\033[1;49;32m[OK]\033[0m"
                            }
                        done
                        ;;
        [Nn]) cancelar && sleep 2 && break;;
        *) echo -e "\n \033[1;49;37mselecione (S) para si o (N) para no!\033[0m" && sleep 2;;
    esac
    sleep 3
    ssl_install
    break
    done
 }

ssl_install() {
    while :
    do

    if [[ -f "/etc/stunnel/stunnel.pem" ]]; then
        clear
        echo -e $BARRA
        echo -e " \033[1;49;37mya existen archivos de certificados"
        echo -e " en el directorio asignado.\033[0m"
        echo -e $BARRA
        echo -e " \033[1;49;37mENTER para canselar la instacion."
        echo -e " 'S' para eliminar y continuar\033[0m"
        echo -e $BARRA
        echo -ne " opcion: "
        read ssl_delete
        case $ssl_delete in
        [Ss]|[Yy])
                    rm /etc/stunnel/stunnel.pem
                    echo -e " \033[3;49;32marchivos removidos..!\033[0m"
                    sleep 2
                    ;;
        *) cancelar && sleep 2 && break;;
        esac
    fi

    if [[ -f "$HOME/.acme.sh/${domain}_ecc/${domain}.key" || -f "$HOME/.acme.sh/${domain}_ecc/${domain}.cer" ]]; then
        echo -e $BARRA
        echo -e " \033[1;49;37mya existe un almacer de certificado"
        echo -e " bajo este nombre de dominio\033[0m"
        echo -e $BARRA
        echo -e " \033[1;49;37m'ENTER' cansela la instalacion"
        echo -e " 'D' para eliminar y continuar"
        echo -e " 'R' para restaurar el almacen crt\033[0m"
        echo -e $BARRA
        echo -ne " opcion: "
        read opcion
        case $opcion in
            [Dd])
                        echo -e " \033[1;49;92meliminando almacen cert...\033[0m"
                        sleep 2
                        rm -rf $HOME/.acme.sh/${domain}_ecc
                        ;;
            [Rr])
                        echo -e " \033[1;49;92mrestaurando certificados...\033[0m"
                        [[ ! -d /etc/stunnel ]] && mkdir /etc/stunnel
                        "$HOME"/.acme.sh/acme.sh --installcert -d "${domain}" --fullchainpath /root/ssl.crt --keypath /root/ssl.key --ecc
                        cat /root/ssl.crt /root/ssl.key > /etc/stunnel/stunnel.pem
                        rm /root/ssl.crt
                        rm /root/ssl.key
                        echo -e " \033[1;49;37mrestauracion completa...\033[0m\033[1;49;92m[ok]\033[0m"
                        
                        sed -i 's/ENABLED=0/ENABLED=1/g' /etc/default/stunnel4
                        service stunnel4 restart > /dev/null 2>&1
                        msg -bar
                        echo -e "\033[1;33m $(fun_trans  "INSTALADO CON EXITO")"
                        msg -bar
                        sleep 2
                        return 0
                        break
                        ;;
            *) cancelar && sleep 2 && break;;
        esac
    fi
    acme
    break
    done 
 }

ssl_install_fun() {
    apt install socat netcat -y
    curl -s "https://get.acme.sh" | sh &>/dev/null
 }

acme() {
    clear
    echo -e $BARRA
    echo -e " \033[1;49;37mcreando nuevos certificado ssl/tls\033[0m"
    echo -e $BARRA
    if "$HOME"/.acme.sh/acme.sh --issue -d "${domain}" --standalone -k ec-256 --force --test; then
        echo -e "\n           \033[1;49;37mSSL La prueba del certificado\n se emite con éxito y comienza la emisión oficial\033[0m\n"
        rm -rf "$HOME/.acme.sh/${domain}_ecc"
        sleep 2
    else
        echo -e "\n \033[4;49;31mError en la emisión de la prueba del certificado SSL\033[0m"
        echo -e $BARRA
        rm -rf "$HOME/.acme.sh/${domain}_ecc"
        stop=1
    fi

    if [[ 0 -eq $stop ]]; then

    if "$HOME"/.acme.sh/acme.sh --issue -d "${domain}" --standalone -k ec-256 --force; then
        echo -e "\n \033[1;49;37mSSL El certificado se genero con éxito\033[0m"
        echo -e $BARRA
        sleep 2
        [[ ! -d /etc/stunnel ]] && mkdir /etc/stunnel
        if "$HOME"/.acme.sh/acme.sh --installcert -d "${domain}" --fullchainpath /root/ssl.crt --keypath /root/ssl.key --ecc --force; then
            cat /root/ssl.crt /root/ssl.key > /etc/stunnel/stunnel.pem
            rm /root/ssl.crt
            rm /root/ssl.key
            echo -e $BARRA
            echo -e "\n \033[1;49;37mLa configuración del certificado es exitosa\033[0m"
            echo -e $BARRA
            echo -e "      /etc/stunnel/stunnel.pem"
            echo -e $BARRA
            sleep 2
        fi
    else
        echo -e "\n \033[4;49;31mError al generar el certificado SSL\033[0m"
        echo -e $BARRA
        rm -rf "$HOME/.acme.sh/${domain}_ecc"
    fi
    fi
    continuar
    read foo

    sed -i 's/ENABLED=0/ENABLED=1/g' /etc/default/stunnel4
    service stunnel4 restart > /dev/null 2>&1
    msg -bar
    echo -e "\033[1;33m $(fun_trans  "INSTALADO CON EXITO")"
    msg -bar
    return 0
 }

##################################################

ssl_inst(){
  clear
  msg -bar
  echo -e "${cor[1]} Escoja la opcion deseada."
  msg -bar
  echo "1).- SSL CON CERTIFICACION LOCAL"
  echo "2).- SSL CON CERTIFICACION BAJO UN DOMINIO"
  msg -bar
  echo -n "Digite solo el numero segun su respuesta: "
  read cert
  case $cert in
    1) ssl_stunel;;
    2)ssl_stunel3;;
  esac
}

ssl_stunel_2 () {
echo -e "\033[1;32m $(fun_trans  "INSTALADOR SSL By @Rufu99")"
msg -bar
echo -e "\033[1;33m $(fun_trans  "Seleccione una puerta de redirección interna.")"
echo -e "\033[1;33m $(fun_trans  "Es decir, un puerto en su servidor para SSL")"
msg -bar
         while true; do
         echo -ne "\033[1;37m"
         read -p " Local-Port: " portx
         if [[ ! -z $portx ]]; then
             if [[ $(echo $portx|grep [0-9]) ]]; then
                [[ $(mportas|grep $portx|head -1) ]] && break || echo -e "\033[1;31m $(fun_trans  "Puerta invalida")"
             fi
         fi
         done
msg -bar
DPORT="$(mportas|grep $portx|awk '{print $2}'|head -1)"
echo -e "\033[1;33m $(fun_trans  "Ahora Prestamos Saber Que Puerta del SSL, Va a Escuchar")"
msg -bar
    while true; do
    read -p " Listen-SSL: " SSLPORT
    [[ $(mportas|grep -w "$SSLPORT") ]] || break
    echo -e "\033[1;33m $(fun_trans  "Esta puerta está en uso")"
    unset SSLPORT
    done
msg -bar
echo -e "\033[1;33m $(fun_trans  "Instalando SSL")"
msg -bar
fun_bar "apt-get install stunnel4 -y"
echo -e "client = no\n[SSL+]\ncert = /etc/stunnel/stunnel.pem\naccept = ${SSLPORT}\nconnect = 127.0.0.1:${DPORT}" >> /etc/stunnel/stunnel.conf
######-------
sed -i 's/ENABLED=0/ENABLED=1/g' /etc/default/stunnel4
service stunnel4 restart > /dev/null 2>&1
msg -bar
echo -e "\033[1;33m $(fun_trans  "INSTALADO CON EXITO")"
msg -bar
rm -rf /etc/ger-frm/stunnel.crt > /dev/null 2>&1
rm -rf /etc/ger-frm/stunnel.key > /dev/null 2>&1
rm -rf /root/stunnel.crt > /dev/null 2>&1
rm -rf /root/stunnel.key > /dev/null 2>&1
return 0
}

echo -e "${cor[3]}INSTALADOR SSL By @Rufu99"
msg -bar
echo -e "${cor[1]} Escoja la opcion deseada."
msg -bar
echo "1).- ININICIAR O PARAR SSL"
echo "2).- AGREGAR PUERTOS SSL"
msg -bar
echo -n "Digite solo el numero segun su respuesta: "
read opcao
case $opcao in
1)
msg -bar
ssl_stunel
;;
2)
msg -bar
echo -e "\033[1;93m  AGREGAR SSL EXTRA  ..."
msg -bar
ssl_stunel_2
sleep 3
exit
;;
esac
