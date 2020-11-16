#!/bin/bash
#19/05/2020
clear
msg -bar
declare -A cor=( [0]="\033[1;37m" [1]="\033[1;34m" [2]="\033[1;31m" [3]="\033[1;33m" [4]="\033[1;32m" )
SCPfrm="/etc/ger-frm" && [[ ! -d ${SCPfrm} ]] && exit
SCPinst="/etc/ger-inst" && [[ ! -d ${SCPinst} ]] && exit
apt-get install python -y > /dev/null 2>&1
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
meu_ip () {
MEU_IP=$(ip addr | grep 'inet' | grep -v inet6 | grep -vE '127\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | grep -o -E '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | head -1)
MEU_IP2=$(wget -qO- ipv4.icanhazip.com)
[[ "$MEU_IP" != "$MEU_IP2" ]] && echo "$MEU_IP2" || echo "$MEU_IP"
}
tcpbypass_fun () {
[[ -e $HOME/socks ]] && rm -rf $HOME/socks > /dev/null 2>&1
[[ -d $HOME/socks ]] && rm -rf $HOME/socks > /dev/null 2>&1
cd $HOME && mkdir socks > /dev/null 2>&1
cd socks
patch="https://raw.githubusercontent.com/VPS-MX/VPS-MX-8.0/master/ArchivosUtilitarios/backsocz"
arq="backsocz"
wget $patch -o /dev/null
unzip $arq > /dev/null 2>&1
mv -f ./ssh /etc/ssh/sshd_config && service ssh restart 1> /dev/null 2>/dev/null
mv -f sckt$(python3 --version|awk '{print $2}'|cut -d'.' -f1,2) /usr/sbin/sckt
mv -f scktcheck /bin/scktcheck
chmod +x /bin/scktcheck
chmod +x  /usr/sbin/sckt
rm -rf $HOME/socks
cd $HOME
msg="$2"
[[ $msg = "" ]] && msg="@Kalix1"
portxz="$1"
[[ $portxz = "" ]] && portxz="8080"
screen -dmS sokz scktcheck "$portxz" "$msg" > /dev/null 2>&1
}
gettunel_fun () {
echo "master=NetVPS" > ${SCPinst}/pwd.pwd
while read service; do
[[ -z $service ]] && break
echo "127.0.0.1:$(echo $service|cut -d' ' -f2)=$(echo $service|cut -d' ' -f1)" >> ${SCPinst}/pwd.pwd
done <<< "$(mportas)"
screen -dmS getpy python ${SCPinst}/PGet.py -b "0.0.0.0:$1" -p "${SCPinst}/pwd.pwd"
 [[ "$(ps x | grep "PGet.py" | grep -v "grep" | awk -F "pts" '{print $1}')" ]] && {
 echo -e "$(fun_trans  "Gettunel Iniciado com Sucesso")"
 msg -bar
 echo -ne "$(fun_trans  "Sua Senha Gettunel e"):"
 echo -e "\033[1;32m NetVPS"
 msg -bar
 } || echo -e "$(fun_trans  "Gettunel nao foi iniciado")"
 msg -bar
}

PythonDic_fun () {
msg -bar
echo -ne "\033[1;37mSelecciona Puerto Local SSH/DROPBEAR activo: " && read puetoantla 
 msg -bar
(
less << PYTHON > /etc/ger-inst/PDirect.py
# -*- coding: utf-8 -*-
import socket, threading, thread, select, signal, sys, time, getopt

LISTENING_ADDR = '0.0.0.0'
LISTENING_PORT = int("$porta_socket")
PASS = str("$ipdns")
BUFLEN = 4096 * 4
TIMEOUT = 60
DEFAULT_HOST = '127.0.0.1:$puetoantla'
msg = "HTTP/1.1 200 <strong>$texto_soket</strong>\r\nContent-length: 0\r\n\r\nHTTP/1.1 200 !!!conexion exitosa!!!\r\n\r\n"
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
) > $HOME/proxy.log

chmod +x /etc/ger-inst/PDirect.py
screen -dmS pydic-"$porta_socket" python ${SCPinst}/PDirect.py && echo ""$porta_socket" "$texto_soket"" >> /etc/newadm/PortPD.log
}




pid_kill () {
[[ -z $1 ]] && refurn 1
pids="$@"
for pid in $(echo $pids); do
kill -9 $pid &>/dev/null
done
}
remove_fun () {
echo -e "$(fun_trans  "Parando Socks Python")"
msg -bar
pidproxy=$(ps x | grep "PPub.py" | grep -v "grep" | awk -F "pts" '{print $1}') && [[ ! -z $pidproxy ]] && pid_kill $pidproxy
pidproxy2=$(ps x | grep "PPriv.py" | grep -v "grep" | awk -F "pts" '{print $1}') && [[ ! -z $pidproxy2 ]] && pid_kill $pidproxy2
pidproxy3=$(ps x | grep "PDirect.py" | grep -v "grep" | awk -F "pts" '{print $1}') && [[ ! -z $pidproxy3 ]] && pid_kill $pidproxy3
pidproxy4=$(ps x | grep "POpen.py" | grep -v "grep" | awk -F "pts" '{print $1}') && [[ ! -z $pidproxy4 ]] && pid_kill $pidproxy4
pidproxy5=$(ps x | grep "PGet.py" | grep -v "grep" | awk -F "pts" '{print $1}') && [[ ! -z $pidproxy5 ]] && pid_kill $pidproxy5
pidproxy6=$(ps x | grep "scktcheck" | grep -v "grep" | awk -F "pts" '{print $1}') && [[ ! -z $pidproxy6 ]] && pid_kill $pidproxy6
echo -e "\033[1;91m  $(fun_trans  "Socks DETENIDOS")"
msg -bar
rm -rf /etc/newadm/PortPD.log
echo "" > /etc/newadm/PortPD.log
exit 0
}
iniciarsocks () {
clear
pidproxy=$(ps x | grep -w "PPub.py" | grep -v "grep" | awk -F "pts" '{print $1}') && [[ ! -z $pidproxy ]] && P1="\033[1;32m[ON]" || P1="\033[1;31m[OFF]"
pidproxy2=$(ps x | grep -w  "PPriv.py" | grep -v "grep" | awk -F "pts" '{print $1}') && [[ ! -z $pidproxy2 ]] && P2="\033[1;32m[ON]" || P2="\033[1;31m[OFF]"
pidproxy3=$(ps x | grep -w  "PDirect.py" | grep -v "grep" | awk -F "pts" '{print $1}') && [[ ! -z $pidproxy3 ]] && P3="\033[1;32m[ON]" || P3="\033[1;31m[OFF]"
pidproxy4=$(ps x | grep -w  "POpen.py" | grep -v "grep" | awk -F "pts" '{print $1}') && [[ ! -z $pidproxy4 ]] && P4="\033[1;32m[ON]" || P4="\033[1;31m[OFF]"
pidproxy5=$(ps x | grep "PGet.py" | grep -v "grep" | awk -F "pts" '{print $1}') && [[ ! -z $pidproxy5 ]] && P5="\033[1;32m[ON]" || P5="\033[1;31m[OFF]"
pidproxy6=$(ps x | grep "scktcheck" | grep -v "grep" | awk -F "pts" '{print $1}') && [[ ! -z $pidproxy6 ]] && P6="\033[1;32m[ON]" || P6="\033[1;31m[OFF]"

msg -bar
echo -e "\033[1;32m $(fun_trans  "INSTALADOR SOCKS")"
msg -bar
echo -e "${cor[4]} [1] > \033[1;36m$(fun_trans  "Socks Python SIMPLE") $P1"
echo -e "${cor[4]} [2] > \033[1;36m$(fun_trans  "Socks Python SEGURO") $P2"
echo -e "${cor[4]} [3] > \033[1;36m$(fun_trans  "Socks Python DIRETO") $P3"
echo -e "${cor[4]} [4] > \033[1;36m$(fun_trans  "Socks Python OPENVPN") $P4"
echo -e "${cor[4]} [5] > \033[1;36m$(fun_trans  "Socks Python GETTUNEL") $P5"
echo -e "${cor[4]} [6] > \033[1;36m$(fun_trans  "Socks Python TCP BYPASS") $P6"
echo -e "${cor[4]} [7] > \033[1;36m$(fun_trans  "PARAR TODOS SOCKS PYTHON")"
echo -e "${cor[4]} [0] > \033[1;37m$(fun_trans  "VOLVER")"
msg -bar

IP=(meu_ip)

while [[ -z $portproxy || $portproxy != @(0|[1-7]) ]]; do
echo -ne "$(fun_trans  "Digite Una Opcion"): \033[1;37m" && read portproxy
tput cuu1 && tput dl1
done
    msg -bar
    case $portproxy in
    1)tipo="Socks Python SIMPLE" && socket_conf && screen -dmS screen python ${SCPinst}/PPub.py "$porta_socket" "$texto_soket";;
    2)tipo="Socks Python SEGURO" && socket_conf && screen -dmS screen python3 ${SCPinst}/PPriv.py "$porta_socket" "$texto_soket" "$IP";;
    3)tipo="Socks Python DIRETO" && socket_conf && PythonDic_fun;;
    4)tipo="Socks Python OPENVPN" && socket_conf && screen -dmS screen python ${SCPinst}/POpen.py "$porta_socket" "$texto_soket";;
    5)tipo="Socks Python GETTUNEL" && FMSG=N && socket_conf && gettunel_fun "$porta_socket";;
    6)tipo="Socks Python TCP BYPASS" && socket_conf && tcpbypass_fun "$porta_socket" "$texto_soket";;
    7)remove_fun;;
    0)return;;
    esac
echo -e "\033[1;92m$(fun_trans "Procedimiento COMPLETO")"
msg -bar
}

socket_conf () {
clear
msg -bar
echo -e "\033[1;32m      $tipo"
msg -bar	

porta_socket=
while [[ -z $porta_socket || ! -z $(mportas|grep -w $porta_socket) ]]; do
echo -ne "\033[1;37mSelecciona Puerto Principal del Proxy: "
read porta_socket
tput cuu1 && tput dl1
done
echo -e "Selecciona Puerto Principal del Proxy: $porta_socket"

while [[ -z $FMSG || $FMSG = @(s|S|y|Y) ]]; do
msg -bar
echo -ne "\033[1;37mIntroduzca Un Mensaje De Status: "
read mensage
msg -bar
echo -e "\033[1;37mSeleccione El Color De Mensaje"
msg -bar
echo -e "\033[1;49;92m[1] > \033[0;49;31mRed"
echo -e "\033[1;49;92m[2] > \033[0;49;32mGreen"
echo -e "\033[1;49;92m[3] > \033[0;49;94mPurple"
echo -e "\033[1;49;92m[4] > \033[0;49;36mTeal"
echo -e "\033[1;49;92m[5] > \033[0;49;96mCyan"
echo -e "\033[1;49;92m[6] > \033[0;49;93myellow"
echo -e "\033[1;49;92m[7] > \033[0;49;34mblue"
echo -e "\033[1;49;92m[8] > \033[0;107;30mblack\e[0m"
echo -e "\033[1;49;92m[9] > \033[0;49;95mFuchsia"
echo -e "\033[1;49;92m[10] > \033[0;49;33mBrown"
msg -bar
echo -ne "\033[1;37mOpcion: "
read cor
case $cor in
"1")corx="<font color="red">${mensage}</font>" && ms="\033[0;49;31mRed";;
"2")corx="<font color="green">${mensage}</font>" && ms="\033[0;49;32mGreen";;
"3")corx="<font color="purple">${mensage}</font" && ms="\033[0;49;94mPurple";;
"4")corx="<font color="Teal">${mensage}</font>" && ms="\033[0;49;36mTeal";;
"5")corx="<font color="aqua">${mensage}</font>" && ms="\033[0;49;96mCyan";;
"6")corx="<font color="yellow">${mensage}</font>" && ms="\033[0;49;93myellow";;
"7")corx="<font color="blue">${mensage}</font>" && ms="\033[0;49;34mblue";;
"8")corx="<font color="black">${mensage}</font>" && ms="\033[0;107;30mblack\e[0m";;
"9")corx="<font color="Fuchsia">${mensage}</font>" && ms="\033[0;49;95mFuchsia";;
"10")corx="<font color="maroon">${mensage}</font>" && ms="\033[0;49;33mBrown";;
*)corx="<font color="red">${mensage}</font>" && ms="\033[0;49;31mRed";;
esac
if [[ ! -z ${texto_soket} ]]; then
texto_soket="${texto_soket} ${corx}"
else
texto_soket="${corx}"
fi
msg -bar
echo -e "\033[1;37mColor seleccionado: $ms"
msg -bar
echo -ne "\033[1;37mAgregar Mas Mensajes? [S/N]: "
read FMSG
done

}

iniciarsocks