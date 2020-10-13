#!/bin/bash
# -*- ENCODING: UTF-8 -*-
# @reboot /root/Proxy.sh
sleep 30
BARRA="\e[0;31m➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖\e[0m"
echo -e "\e[0;31m➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖\e[0m"
echo ""
if [[ ! -e /usr/bin/python ]]; then
apt-get install python python-pip cowsay figlet lolcat -y
clear
echo -e "$BARRA"
echo -e "Ejecute de nuevo el script"
echo -e "$BARRA"
exit
fi
clear
cowsay -f tux "Esta herramienta le cambia y da color al status de conexion y agrega una contrasena a tu payload para mayor seguridad...." | lolcat 
figlet __TELLO__ | lolcat

echo -e "$BARRA"
echo -e "\033[1;31mPUERTO PROXY PYTHON\033[0m"
echo -e "$BARRA"
echo -ne "Introduzca puerto proxy: "
port=8080

echo -e "$BARRA"
echo -e "\033[1;31mPUERTO LOCAL\033[0m"
echo -e "$BARRA"
echo -ne "Introduzca puerto local OpenSSH o Dropbear: "
portlocal=443

echo -e "$BARRA"
echo -e "\033[1;31mAÑADIR CONTRASEÑA AL PAYLOAD\033[0m"
echo -e "$BARRA"
echo -ne "Contraseña o Enter para omitor: "
# read ipdns
if [[ ! -z $ipdns ]]; then
echo -e "$BARRA"
echo -e "\033[1;31mATENCION:\n\033[1;34mPara Utilizar Este Proxy Es Necesario Agregar Una Linea A Su Payload\033[0m"
echo -e "\033[1;34mAGREGUE ESTA LINEA A SU PAYLOAD:\n\033[1;36m[crlf]X-Pass: $ipdns[crlf]\n\033[0m"
echo -e "\033[1;31mEJEMPLO 1:\n\033[1;33m\033[1;36m[crlf]X-Pass: $ipdns[crlf]GET http://tuhost.com/ HTTP/1.0 [cr|f]\033[0m"
echo -e "\033[1;31mEJEMPLO 2:\n\033[1;33m\033[1;36mGET http://tuhost.com/ HTTP/1.0 [crlf][crlf]X-Pass: $ipdns[crlf]\033[0m"
fi
while [[ -z $FMSG || $FMSG = @(s|S|y|Y) ]]; do
echo -e "$BARRA"
echo -ne "Introduzca Un Mensaje De Status: "
mensage="VPS"
echo -e "$BARRA"
echo -e "Seleccione El Color De Mensaje: "
echo -e "$BARRA"
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
echo -e "$BARRA"
# read -p "Opcion: " cor
case 1 in
"1")corx="<font color="red">${mensage}</font>";;
"2")corx="<font color="green">${mensage}</font>";;
"3")corx="<font color="purple">${mensage}</font";;
"4")corx="<font color="Teal">${mensage}</font>";;
"5")corx="<font color="aqua">${mensage}</font>";;
"6")corx="<font color="yellow">${mensage}</font>";;
"7")corx="<font color="blue">${mensage}</font>";;
"8")corx="<font color="black">${mensage}</font>";;
"9")corx="<font color="Fuchsia">${mensage}</font>";;
"10")corx="<font color="maroon">${mensage}</font>";;
*)corx="<font color="red">${mensage}</font>";;
esac
if [[ ! -z ${RETORNO} ]]; then
RETORNO="${RETORNO} ${corx}"
else
RETORNO="${corx}"
fi
echo -e "$BARRA"
echo -ne "Agregar Mas Mensajes? [S/N]: "
FMSG="N"
done
echo -e "$BARRA"
# read -p "Enter..."
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
msg = "HTTP/1.1 200 <strong>$RETORNO</strong>\r\nContent-length: 0\r\n\r\nHTTP/1.1 200 !!!conexion exitosa!!!\r\n\r\n"
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
echo -e "$BARRA"
echo -e "\e[1;31mProxy Iniciado Con Exito\e[0m"
echo ""
echo
