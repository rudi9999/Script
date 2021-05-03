#!/bin/bash
# -*- ENCODING: UTF-8 -*-
BARRA="\e[0;31m➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖\e[0m"
if [[ ! -e /root/pySSL ]]; then
clear
echo -e "$BARRA"
echo -e "\033[92m El programa requiere de unas instalaciones adiccionales\n al finalizar la instalacion devera ejecutar nuevamente\n este script!"
echo -e "$BARRA"
echo -ne "\033[97m Desea continuar [s/n]: "
read instal
[[ $instal = @(s|S|y|Y) ]] && {
clear
echo -e "$BARRA"
echo -e "\033[92m           -- INSTALANDO PAQUETES NECESARIOS -- "
echo -e "$BARRA"
#python
[[ $(dpkg --get-selections|grep -w "python"|head -1) ]] || apt-get install python -y &>/dev/null
[[ $(dpkg --get-selections|grep -w "python"|head -1) ]] || ESTATUS=`echo -e "\033[91mFALLO DE INSTALACION"` &>/dev/null
[[ $(dpkg --get-selections|grep -w "python"|head -1) ]] && ESTATUS=`echo -e "\033[92mINSTALADO"` &>/dev/null
echo -e "\033[97m    # apt-get install python.......... $ESTATUS "
#python-pip
[[ $(dpkg --get-selections|grep -w "python-pip"|head -1) ]] || apt-get install python-pip -y &>/dev/null
[[ $(dpkg --get-selections|grep -w "python-pip"|head -1) ]] || ESTATUS=`echo -e "\033[91mFALLO DE INSTALACION"` &>/dev/null
[[ $(dpkg --get-selections|grep -w "python-pip"|head -1) ]] && ESTATUS=`echo -e "\033[92mINSTALADO"` &>/dev/null
echo -e "\033[97m    # apt-get install python-pip...... $ESTATUS "
#stunnel4
[[ $(dpkg --get-selections|grep -w "stunnel4"|head -1) ]] || apt-get install stunnel4 -y &>/dev/null
echo -e "client = no\n[SSL]\ncert = /etc/stunnel/stunnel.pem\naccept = 443\nconnect = 127.0.0.1:80" > /etc/stunnel/stunnel.conf
[[ $(dpkg --get-selections|grep -w "stunnel4"|head -1) ]] || ESTATUS=`echo -e "\033[91mFALLO DE INSTALACION"` &>/dev/null
[[ $(dpkg --get-selections|grep -w "stunnel4"|head -1) ]] && ESTATUS=`echo -e "\033[92mINSTALADO"` &>/dev/null
echo -e "\033[97m    # apt-get install stunnel4........ $ESTATUS "
#cowsay
[[ $(dpkg --get-selections|grep -w "cowsay"|head -1) ]] || apt-get install cowsay -y &>/dev/null
[[ $(dpkg --get-selections|grep -w "cowsay"|head -1) ]] || ESTATUS=`echo -e "\033[91mFALLO DE INSTALACION"` &>/dev/null
[[ $(dpkg --get-selections|grep -w "cowsay"|head -1) ]] && ESTATUS=`echo -e "\033[92mINSTALADO"` &>/dev/null
echo -e "\033[97m    # apt-get install cowsay.......... $ESTATUS "
#figlet
[[ $(dpkg --get-selections|grep -w "figlet"|head -1) ]] || apt-get install figlet -y &>/dev/null
[[ $(dpkg --get-selections|grep -w "figlet"|head -1) ]] || ESTATUS=`echo -e "\033[91mFALLO DE INSTALACION"` &>/dev/null
[[ $(dpkg --get-selections|grep -w "figlet"|head -1) ]] && ESTATUS=`echo -e "\033[92mINSTALADO"` &>/dev/null
echo -e "\033[97m    # apt-get install figlet.......... $ESTATUS "
#lolcat
apt-get install lolcat -y &>/dev/null
sudo gem install lolcat &>/dev/null
[[ $(dpkg --get-selections|grep -w "lolcat"|head -1) ]] || ESTATUS=`echo -e "\033[91mFALLO DE INSTALACION"` &>/dev/null
[[ $(dpkg --get-selections|grep -w "lolcat"|head -1) ]] && ESTATUS=`echo -e "\033[92mINSTALADO"` &>/dev/null
echo -e "\033[97m    # apt-get install lolcat.......... $ESTATUS "
echo -e "$BARRA"
echo -e "\033[97m Ejecute de nuevo el script"
echo -e "$BARRA"
}
echo "install 0" > /root/pySSL
exit
fi

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
            echo -e " > De lo contrario, V2ray no se puede"
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
    continuar
    read foo
    ssl_install
    break
    done
 }

ssl_install() {
    while :
    do

    if [[ -f "/data/v2ray.key" || -f "/data/v2ray.crt" ]]; then
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
                    rm -rf /data/*
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
                        sleep 2
                        "$HOME"/.acme.sh/acme.sh --installcert -d "${domain}" --fullchainpath /data/v2ray.crt --keypath /data/v2ray.key --ecc
                        echo -e " \033[1;49;37mrestauracion completa...\033[0m\033[1;49;92m[ok]\033[0m"
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
        [[ ! -d /data ]] && mkdir /data
        if "$HOME"/.acme.sh/acme.sh --installcert -d "${domain}" --fullchainpath /data/v2ray.crt --keypath /data/v2ray.key --ecc --force; then
            cat /data/v2ray.crt /data/v2ray.key > /etc/stunnel/stunnel.pem
            echo -e $BARRA
            echo -e "\n \033[1;49;37mLa configuración del certificado es exitosa\033[0m"
            echo -e $BARRA
            echo -e "      /data/v2ray.crt"
            echo -e "      /data/v2ray.key"
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
 }

##################################################

stop_ssl(){
	sed -i 's/ENABLED=1/ENABLED=0/g' /etc/default/stunnel4
	service stunnel4 restart
 }

start_ssl(){
	sed -i 's/ENABLED=0/ENABLED=1/g' /etc/default/stunnel4
	service stunnel4 restart
 }

pid_kill () {
	[[ -z $1 ]] && refurn 1
	pids="$@"
	for pid in $(echo $pids); do
		kill -9 $pid &>/dev/null
	done
 }

stop_py(){
	pidproxy3=$(ps x | grep "python -x" | grep -v "grep" | awk -F "pts" '{print $1}') && [[ ! -z $pidproxy3 ]] && pid_kill $pidproxy3
	echo -e "\033[1;91m  Socks DETENIDOS"
	read foo
	}

star_py(){
	port=80
	portlocal=22
	# Inicializando o Proxy
	(
		/usr/bin/python -x << PYTHON
# -*- coding: utf-8 -*-
import socket, threading, thread, select, signal, sys, time, getopt

LISTENING_ADDR = '0.0.0.0'
LISTENING_PORT = int("$port")
PASS = str("$ipdns")
BUFLEN = 4096 * 4
TIMEOUT = 60
DEFAULT_HOST = '127.0.0.1:$portlocal'
msg = "HTTP/1.1 101 Switching Protocols\r\nContent-length: 0\r\n\r\nHTTP/1.1 200 !!!conexion exitosa!!!\r\n\r\n"
RESPONSE = str(msg)

class Server(threading.Thread):
    def __init__(self, host, port):
        threading.Thread.__init__(self)
        self.running = False
        self.host = host
        self.port = port
        self.threads = []
        self.threadsLock = threading.Lock()
        self.logLock = threading.Lock()

    def run(self):
        self.soc = socket.socket(socket.AF_INET)
        self.soc.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
        self.soc.settimeout(2)
        self.soc.bind((self.host, self.port))
        self.soc.listen(0)
        self.running = True

        try:
            while self.running:
                try:
                    c, addr = self.soc.accept()
                    c.setblocking(1)
                except socket.timeout:
                    continue

                conn = ConnectionHandler(c, self, addr)
                conn.start()
                self.addConn(conn)
        finally:
            self.running = False
            self.soc.close()

    def printLog(self, log):
        self.logLock.acquire()
        print log
        self.logLock.release()

    def addConn(self, conn):
        try:
            self.threadsLock.acquire()
            if self.running:
                self.threads.append(conn)
        finally:
            self.threadsLock.release()

    def removeConn(self, conn):
        try:
            self.threadsLock.acquire()
            self.threads.remove(conn)
        finally:
            self.threadsLock.release()

    def close(self):
        try:
            self.running = False
            self.threadsLock.acquire()

            threads = list(self.threads)
            for c in threads:
                c.close()
        finally:
            self.threadsLock.release()


class ConnectionHandler(threading.Thread):
    def __init__(self, socClient, server, addr):
        threading.Thread.__init__(self)
        self.clientClosed = False
        self.targetClosed = True
        self.client = socClient
        self.client_buffer = ''
        self.server = server
        self.log = 'Connection: ' + str(addr)

    def close(self):
        try:
            if not self.clientClosed:
                self.client.shutdown(socket.SHUT_RDWR)
                self.client.close()
        except:
            pass
        finally:
            self.clientClosed = True

        try:
            if not self.targetClosed:
                self.target.shutdown(socket.SHUT_RDWR)
                self.target.close()
        except:
            pass
        finally:
            self.targetClosed = True

    def run(self):
        try:
            self.client_buffer = self.client.recv(BUFLEN)

            hostPort = self.findHeader(self.client_buffer, 'X-Real-Host')

            if hostPort == '':
                hostPort = DEFAULT_HOST

            split = self.findHeader(self.client_buffer, 'X-Split')

            if split != '':
                self.client.recv(BUFLEN)

            if hostPort != '':
                passwd = self.findHeader(self.client_buffer, 'X-Pass')
				
                if len(PASS) != 0 and passwd == PASS:
                    self.method_CONNECT(hostPort)
                elif len(PASS) != 0 and passwd != PASS:
                    self.client.send('HTTP/1.1 400 WrongPass!\r\n\r\n')
                elif hostPort.startswith('127.0.0.1') or hostPort.startswith('localhost'):
                    self.method_CONNECT(hostPort)
                else:
                    self.client.send('HTTP/1.1 403 Forbidden!\r\n\r\n')
            else:
                print '- No X-Real-Host!'
                self.client.send('HTTP/1.1 400 NoXRealHost!\r\n\r\n')

        except Exception as e:
            self.log += ' - error: ' + e.strerror
            self.server.printLog(self.log)
	    pass
        finally:
            self.close()
            self.server.removeConn(self)

    def findHeader(self, head, header):
        aux = head.find(header + ': ')

        if aux == -1:
            return ''

        aux = head.find(':', aux)
        head = head[aux+2:]
        aux = head.find('\r\n')

        if aux == -1:
            return ''

        return head[:aux];

    def connect_target(self, host):
        i = host.find(':')
        if i != -1:
            port = int(host[i+1:])
            host = host[:i]
        else:
            if self.method=='CONNECT':
                port = 443
            else:
                port = 80
                port = 8080
                port = 8799
                port = 3128

        (soc_family, soc_type, proto, _, address) = socket.getaddrinfo(host, port)[0]

        self.target = socket.socket(soc_family, soc_type, proto)
        self.targetClosed = False
        self.target.connect(address)

    def method_CONNECT(self, path):
        self.log += ' - CONNECT ' + path

        self.connect_target(path)
        self.client.sendall(RESPONSE)
        self.client_buffer = ''

        self.server.printLog(self.log)
        self.doCONNECT()

    def doCONNECT(self):
        socs = [self.client, self.target]
        count = 0
        error = False
        while True:
            count += 1
            (recv, _, err) = select.select(socs, [], socs, 3)
            if err:
                error = True
            if recv:
                for in_ in recv:
		    try:
                        data = in_.recv(BUFLEN)
                        if data:
			    if in_ is self.target:
				self.client.send(data)
                            else:
                                while data:
                                    byte = self.target.send(data)
                                    data = data[byte:]

                            count = 0
			else:
			    break
		    except:
                        error = True
                        break
            if count == TIMEOUT:
                error = True

            if error:
                break

def main(host=LISTENING_ADDR, port=LISTENING_PORT):

    print "\n:-------PythonProxy-------:\n"
    print "Listening addr: " + LISTENING_ADDR
    print "Listening port: " + str(LISTENING_PORT) + "\n"
    print ":-------------------------:\n"

    server = Server(LISTENING_ADDR, LISTENING_PORT)
    server.start()

    while True:
        try:
            time.sleep(2)
        except KeyboardInterrupt:
            print 'Stopping...'
            server.close()
            break

if __name__ == '__main__':
    main()
PYTHON
) > $HOME/proxy.log &
}

while :
do
	clear
	cowsay -f tux "Python + ssl + dominio" | lolcat 
	figlet __TELLO__ | lolcat
echo -e $BARRA
echo -e "	menu"
echo -e $BARRA
echo -e " 1) cerificado ssl/tls"
echo -e " 2) iniciar"
echo -e " 3) parar"
echo -e $BARRA
echo -e " 0) salir"
echo -e $BARRA
echo -ne " opcion: "
read opcion

case $opcion in
	1)domain_check;;
	2)star_py && start_ssl;;
	3)stop_ssl && stop_py;;
	0) exit;;
esac

done