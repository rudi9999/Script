#!/bin/bash

# verificacion primarias
[[ -e /etc/newadm-instalacao ]] && BASICINST="$(cat /etc/newadm-instalacao)" || BASICINST="ADMbot.sh C-SSR.sh Crear-Demo.sh PDirect.py PGet.py POpen.py PPriv.py PPub.py Shadowsocks-R.sh Shadowsocks-libev.sh Unlock-Pass-VULTR.sh apacheon.sh blockBT.sh budp.sh dns-netflix.sh dropbear.sh fai2ban.sh gestor.sh menu message.txt openvpn.sh paysnd.sh ports.sh shadowsocks.sh sockspy.sh speed.sh speedtest.py squid.sh squidpass.sh ssl.sh tcp.sh ultrahost usercodes utils.sh v2ray.sh"
SCPT_DIR="/etc/SCRIPT"
[[ ! -e ${SCPT_DIR} ]] && mkdir ${SCPT_DIR}
INSTA_ARQUIVOS="ADMVPS.zip"
DIR="/etc/http-shell"
LIST="lista-arq"

CIDdir=/etc/ADM-db && [[ ! -d ${CIDdir} ]] && mkdir ${CIDdir}
CID="${CIDdir}/Control-ID" && [[ ! -e ${CID} ]] && echo > ${CID}
[[ $(dpkg --get-selections|grep -w "jq"|head -1) ]] || apt-get install jq -y &>/dev/null
[[ ! -e "/bin/ShellBot.sh" ]] && wget -O /bin/ShellBot.sh https://raw.githubusercontent.com/shellscriptx/shellbot/master/ShellBot.sh &> /dev/null
[[ -e /etc/texto-bot ]] && rm /etc/texto-bot
LINE="==========================="

# Importando API
source ShellBot.sh

# Token del bot
bot_token='1249652996:AAE7VsdIppmjKq4O-eX3tk70WdHvPVzz7wA'

# Inicializando el bot
ShellBot.init --token "$bot_token" --monitor --return map
ShellBot.username

start_gen () {
unset PIDGEN
PIDGEN=$(ps aux|grep -v grep|grep "http-server.sh")
if [[ ! $PIDGEN ]]; then
screen -dmS generador /bin/http-server.sh -start
local bot_retorno="$LINE\n"
          bot_retorno+="Generador: <u>Online</u>\n"
	  bot_retorno+="$LINE\n"
	     ShellBot.sendMessage --chat_id ${message_chat_id[$id]} \
							--text "<i>$(echo -e $bot_retorno)</i>" \
							--parse_mode html
else
killall http-server.sh
local bot_retorno="$LINE\n"
          bot_retorno+="Generador: <u>Offline</u>\n"
	  bot_retorno+="$LINE\n"
	     ShellBot.sendMessage --chat_id ${message_chat_id[$id]} \
							--text "<i>$(echo -e $bot_retorno)</i>" \
							--parse_mode html
fi
}

ofus () {
unset server
server=$(echo ${txt_ofuscatw}|cut -d':' -f1)
unset txtofus
number=$(expr length $1)
for((i=1; i<$number+1; i++)); do
txt[$i]=$(echo "$1" | cut -b $i)
case ${txt[$i]} in
".")txt[$i]="*";;
"*")txt[$i]=".";;
"1")txt[$i]="@";;
"@")txt[$i]="1";;
"2")txt[$i]="?";;
"?")txt[$i]="2";;
"4")txt[$i]="%";;
"%")txt[$i]="4";;
"-")txt[$i]="K";;
"K")txt[$i]="-";;
esac
txtofus+="${txt[$i]}"
done
echo "$txtofus" | rev
}

fun_list () {
rm ${SCPT_DIR}/*.x.c &> /dev/null
unset KEY
KEY="$1"
#CRIA DIR
[[ ! -e ${DIR} ]] && mkdir ${DIR}
#ENVIA ARQS
i=0
VALUE+="gerar.sh instgerador.sh http-server.py lista-arq $BASICINST"
for arqx in `ls ${SCPT_DIR}`; do
[[ $(echo $VALUE|grep -w "${arqx}") ]] && continue 
echo -e "[$i] -> ${arqx}"
arq_list[$i]="${arqx}"
let i++
done
clear
#CRIA KEY
[[ ! -e ${DIR}/${KEY} ]] && mkdir ${DIR}/${KEY}
#PASSA ARQS
nombrevalue="${chatuser}"
#ADM BASIC
arqslist="$BASICINST"
for arqx in `echo "${arqslist}"`; do
[[ -e ${DIR}/${KEY}/$arqx ]] && continue #ANULA ARQUIVO CASO EXISTA
cp ${SCPT_DIR}/$arqx ${DIR}/${KEY}/
echo "$arqx" >> ${DIR}/${KEY}/${LIST}
done
rm ${SCPT_DIR}/*.x.c &> /dev/null
echo "$nombrevalue" > ${DIR}/${KEY}.name
[[ ! -z $IPFIX ]] && echo "$IPFIX" > ${DIR}/${KEY}/keyfixa
}

link_fun () {
link="sudo apt update -y; apt upgrade -y; wget https://raw.githubusercontent.com/rudi9999/VPS-MX-8.0/master/instalscript.sh &> /dev/null; chmod 777 instalscript.sh && ./instalscript.sh"
local bot_retorno="$LINE\n"
	bot_retorno+="${escapeHtml(link)}\n"
	bot_retorno+="$LINE\n"
	      ShellBot.sendMessage --chat_id ${message_chat_id[$id]} \
							--text "<i>$(echo -e $bot_retorno)</i>" \
							--parse_mode html
}

gerar_key () {
meu_ip_fun
valuekey="$(date | md5sum | head -c10)"
valuekey+="$(echo $(($RANDOM*10))|head -c 5)"
fun_list "$valuekey"
keyfinal=$(ofus "$IP:8888/$valuekey/$LIST")
local bot_retorno="$LINE\n"
bot_retorno+="Key Generada Con Exito!\n"
bot_retorno+="$LINE\n"
bot_retorno+="${keyfinal}\n"
bot_retorno+="$LINE\n"
# bot_retorno+="sudo apt update -y; apt upgrade -y; wget https://raw.githubusercontent.com/rudi9999/VPS-MX-8.0/master/instalscript.sh &> /dev/null; chmod 777 instalscript.sh && ./instalscript.sh\n"
bot_retorno+="$LINE\n"
ShellBot.sendMessage --chat_id ${message_chat_id[$id]} \
--text "<i>$(echo -e $bot_retorno)</i>" \
--parse_mode html
}

download_file () {
	local file_id

	if [[ ${message_photo_file_id[$id]} ]]; then
		# Em alguns arquivos de imagem o telegram aplica uma escala de tamanho
		# gerando id's para diferentes resoluções da mesma iagem. São elas (baixa, média, alta).
		# Os id's são armazenados e separados pelo delimitador '|' (padrão).
		#
		# Exemplo:
		#     baixa_id|media_id|alta_id
		
		# Extrai o id da imagem com melhor resolução.
		file_id=${message_photo_file_id[$id]##*|}
	else 
		# Outros objetos.
		# Extrai o id do objeto da mensagem.
		# document, audio, sticker, voice
		file_id=$(cat << _eof
${message_document_file_id[$id]}
${message_audio_file_id[$id]}
${message_sticker_file_id[$id]}
${message_voice_file_id[$id]}
_eof
)
	fi

	# Verifica se 'file_id' contém um id válido.	
	if [[ $file_id ]]; then
	[[ ! -d $HOME/db ]] && mkdir $HOME/db
		# Obtém informações do arquivo, incluindo sua localização nos servidores do Telegram.
		ShellBot.getFile --file_id $file_id

		# Baixa o arquivo do diretório remoto contido em '{return[file_path]}' após
		# a chamada do método 'ShellBot.getFile'.
		# Obs: Recurso disponível somente no modo de retorno 'map'.
		if ShellBot.downloadFile --file_path "${return[file_path]}" --dir "$HOME/db"; then
			ShellBot.sendMessage	--chat_id "${message_chat_id[$id]}" \
									--reply_to_message_id "${message_message_id[$id]}" \
									--text "Arquivo baixado com sucesso!!\n\nSalvo em: ${return[file_path]}"

		fi
	fi

	return 0
cd $HOME/db
mv *.dat Control-ID
}

listID_fun () {
lsid=$(cat -n ${CID})
local bot_retorno="$LINE\n"
          bot_retorno+="Lista de id permitidos\n"
          bot_retorno+="$LINE\n"
          bot_retorno+="${lsid}\n"
          bot_retorno+="$LINE\n"
	      ShellBot.sendMessage --chat_id ${message_chat_id[$id]} \
							--text "<i>$(echo -e $bot_retorno)</i>" \
							--parse_mode html
}

addID_fun () {
[[ $(cat ${CID}|grep "${1}") = "" ]] && {
echo "/${1}" >> ${CID}
local bot_retorno="$LINE\n"
          bot_retorno+="ID agregado con exito\n"
          bot_retorno+="$LINE\n"
	      ShellBot.sendMessage --chat_id ${message_chat_id[$id]} \
							--text "<i>$(echo -e $bot_retorno)</i>" \
							--parse_mode html
local bot_retor="$LINE\n"
          bot_retor+="El Administrador te autoriso\n"
	  bot_retor+="para usar el comando /keygen\n"
	  bot_retor+="$LINE\n"
	      ShellBot.sendMessage --chat_id ${1} \
							--text "<i>$(echo -e $bot_retor)</i>" \
							--parse_mode html
ID-db_fun
  } || {
local bot_retorno="$LINE\n"
          bot_retorno+="====ERROR====\n"
          bot_retorno+="Este ID ya existe\n"
          bot_retorno+="$LINE\n"
	      ShellBot.sendMessage --chat_id ${message_chat_id[$id]} \
							--text "<i>$(echo -e $bot_retorno)</i>" \
							--parse_mode html
  }
}

deleteID_fun () {
delid=$(sed -n ${1}p ${CID})
sed -i "${1}d" ${CID}
local bot_retorno="$LINE\n"
          bot_retorno+="ID eliminado con exito!\n"
          bot_retorno+="ID: ${delid}\n"
          bot_retorno+="$LINE\n"
	      ShellBot.sendMessage --chat_id ${message_chat_id[$id]} \
							--text "<i>$(echo -e $bot_retorno)</i>" \
							--parse_mode html
ID-db_fun
}

ID-db_fun () {
cp ${CID} $HOME/
local bot_retorno2
          ShellBot.sendDocument --chat_id ${message_chat_id[$id]} \
                             --document @$HOME/Control-ID
rm $HOME/Control-ID
}

myid_fun () {
local bot_retorno="====================\n"
          bot_retorno+="SU ID: ${chatuser}\n"
          bot_retorno+="====================\n"
	      ShellBot.sendMessage --chat_id ${message_chat_id[$id]} \
							--text "<i>$(echo -e $bot_retorno)</i>" \
							--parse_mode html
}

meu_ip_fun () {
MIP=$(ip addr | grep 'inet' | grep -v inet6 | grep -vE '127\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | grep -o -E '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | head -1)
MIP2=$(wget -qO- ipv4.icanhazip.com)
[[ "$MIP" != "$MIP2" ]] && IP="$MIP2" || IP="$MIP"
}

meu_ip () {
MIP=$(ip addr | grep 'inet' | grep -v inet6 | grep -vE '127\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | grep -o -E '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | head -1)
MIP2=$(wget -qO- ipv4.icanhazip.com)
[[ "$MIP" != "$MIP2" ]] && echo "$MIP2" || echo "$MIP"
}

reboot_fun () {
  local bot_retorno="$LINE\n"
          bot_retorno+="Reiniciando servidor VPS\n"
          bot_retorno+="$LINE\n"
	      ShellBot.sendMessage --chat_id ${message_chat_id[$id]} \
							--text "<i>$(echo -e $bot_retorno)</i>" \
							--parse_mode html
sleep 2
reboot
}

infosys_fun () {

#HORA Y FECHA
unset _hora
unset _fecha
_hora=$(printf '%(%H:%M:%S)T') 
_fecha=$(printf '%(%D)T') 

#PROCESSADOR
unset _core
unset _usop
_core=$(printf '%-1s' "$(grep -c cpu[0-9] /proc/stat)")
_usop=$(printf '%-1s' "$(top -bn1 | awk '/Cpu/ { cpu = "" 100 - $8 "%" }; END { print cpu }')")

#SISTEMA-USO DA CPU-MEMORIA RAM
unset ram1
unset ram2
unset ram3
ram1=$(free -h | grep -i mem | awk {'print $2'})
ram2=$(free -h | grep -i mem | awk {'print $4'})
ram3=$(free -h | grep -i mem | awk {'print $3'})

unset _ram
unset _usor
_ram=$(printf ' %-9s' "$(free -h | grep -i mem | awk {'print $2'})")
_usor=$(printf '%-8s' "$(free -m | awk 'NR==2{printf "%.2f%%", $3*100/$2 }')")

unset os_sys
os_sys=$(echo $(cat -n /etc/issue |grep 1 |cut -d' ' -f6,7,8 |sed 's/1//' |sed 's/      //')) && echo $system|awk '{print $1, $2}'

local bot_retorno="$LINE\n"
          bot_retorno+="S.O: $os_sys\n"
	  bot_retorno+="Su IP es: $(meu_ip)\n"
	  bot_retorno+="$LINE\n"
	  bot_retorno+="Ram: $ram1\n"
	  bot_retorno+="USADA: $ram3\n"
	  bot_retorno+="LIBRE: $ram2\n"
	  bot_retorno+="USO DE RAM: $_usor\n"
	  bot_retorno+="$LINE\n"
	  bot_retorno+="CPU: $_core\n"
	  bot_retorno+="USO DE CPU: $_usop\n"
	  bot_retorno+="$LINE\n"
	  bot_retorno+="FECHA: $_fecha\n"
	  bot_retorno+="HORA: $_hora\n"
          bot_retorno+="$LINE\n"
	      ShellBot.sendMessage --chat_id ${message_chat_id[$id]} \
							--text "<i>$(echo -e $bot_retorno)</i>" \
							--parse_mode html
	return 0
}

invalido () {
local bot_retorno="$LINE\n"
         bot_retorno+="Comando invalido!\n"
         bot_retorno+="$LINE\n"
	     ShellBot.sendMessage --chat_id ${message_chat_id[$id]} \
							--text "<i>$(echo -e $bot_retorno)</i>" \
							--parse_mode html
	return 0	
}

ayuda_fun () {
local bot_retorno="===========AYUDA===========\n"
	 if [[ $(echo $permited|grep "${chatuser}") = "" ]]; then
		 if [[ $(cat ${CID}|grep "${chatuser}") = "" ]]; then
			 bot_retorno+="/ID\n muestra sus ID de telegram\n para tener acceso al /keygen\n deve enviar su ID al admin\n"
			 bot_retorno+="$LINE\n"
			 bot_retorno+="/Keygen\n genera una key para\n el instalador del script\n para tener acceso\n deve enviar su ID al admin\n"
			 bot_retorno+="$LINE\n"
			 bot_retorno+="/menu\n muestra el menu\n de comandos disponibles\n"
			 bot_retorno+="$LINE\n"
			 bot_retorno+="/ayuda\n muestra este menu de ayuda\n"
			 bot_retorno+="$LINE\n"
		 else
			 bot_retorno+="/ID\n muestra sus ID de telegram\n para tener acceso al /keygen\n deve enviar su ID al admin\n"
			 bot_retorno+="$LINE\n"
			 bot_retorno+="/Keygen\n genera una key para\n el instalador del script\n para tener acceso\n deve enviar su ID al admin\n"
			 bot_retorno+="$LINE\n"
			 # bot_retorno+="/script\n muestra el link de instalacion\n del script para usar sus key\n"
			 #bot_retorno+="$LINE\n"
			 bot_retorno+="/menu\n muestra el menu\n de comandos disponibles\n"
			 bot_retorno+="$LINE\n"
			 bot_retorno+="/ayuda\n muestra este menu de ayuda\n"
			 bot_retorno+="$LINE\n"
		 fi
	 else
		 bot_retorno+="/infosys\n muestra informacion del sistema\n Ram, Cpu, Fecha y Hora\n"
		 bot_retorno+="$LINE\n"
		 bot_retorno+="/ID\n muestra sus ID de telegram\n para tener acceso al /keygen\n deve enviar su ID al admin\n"
		 bot_retorno+="$LINE\n"
		 bot_retorno+="/add\n añade nuevo ID\n para dar acceso /keygen\n <u>modo de uso</u>\n /add 123456789 \n"
		 bot_retorno+="$LINE\n"
		 bot_retorno+="/del\n elimina los ID\n antes deves usar /list\n <u>modo de uso</u>\n /del 4\n /del 6\n etc\n"
		 bot_retorno+="$LINE\n"
		 bot_retorno+="/list\n muestra una lista de id\n"
		 bot_retorno+="$LINE\n"
		 bot_retorno+="/Keygen\n genera una key para\n el instalador del script\n para tener acceso\n deve enviar su ID al admin\n"
		 bot_retorno+="$LINE\n"
		 # bot_retorno+="/script\n muestra el link de instalacion\n del script para usar sus key\n"
		 # bot_retorno+="$LINE\n"
		 bot_retorno+="/power\n poner o sacar de linea el generador\n"
		 bot_retorno+="$LINE\n"
		 bot_retorno+="/menu\n muestra el menu\n de comandos disponibles\n"
		 bot_retorno+="$LINE\n"
		 bot_retorno+="/ayuda\n muestra este menu de ayuda\n"
		 bot_retorno+="$LINE\n"
		 bot_retorno+="/reboot\n Reinicia el servidor vps\n"
		 bot_retorno+="$LINE\n"
	 fi
	     ShellBot.sendMessage --chat_id ${message_chat_id[$id]} \
							--text "<i>$(echo -e $bot_retorno)</i>" \
							--parse_mode html
	return 0	
}

menu_fun () {
local bot_retorno="=========COMANDOS=========\n"
	 if [[ $(echo $permited|grep "${chatuser}") = "" ]]; then
		 if [[ $(cat ${CID}|grep "${chatuser}") = "" ]]; then
			 bot_retorno+="/ID (muestra sus ID)\n"
			 bot_retorno+="/menu (muestra este menu)\n"
			 bot_retorno+="/ayuda (muestra ayuda de los comandos)\n"
			 bot_retorno+="$LINE\n"
		 else
			 bot_retorno+="/ID (muestra sus ID)\n"
			 bot_retorno+="/Keygen (genera una key)\n"
			 # bot_retorno+="/script (link install script)\n"
			 bot_retorno+="/menu (muestra este menu)\n"
			 bot_retorno+="/ayuda (muestra ayuda de los comandos)\n"
			 bot_retorno+="$LINE\n"
		 fi
	 else
		 unset PID_GEN
		 PID_GEN=$(ps x|grep -v grep|grep "http-server.sh")
		 [[ ! $PID_GEN ]] && PID_GEN=Off || PID_GEN=On
		 
		 bot_retorno+="/infosys (informacion del sistema)\n"
		 bot_retorno+="/ID (muestra sus ID)\n"
		 bot_retorno+="/add [id](añadir nuevas ID)\n"
		 bot_retorno+="/del [id](quitar un ID)\n"
		 bot_retorno+="/list (lista de ID permitidas)\n"
		 bot_retorno+="/Keygen (genera una key)\n"
		 # bot_retorno+="/script (link install script)\n"
		 bot_retorno+="/power (online/offline) ($PID_GEN)\n"
		 bot_retorno+="/menu (muestra este menu)\n"
		 bot_retorno+="/ayuda (muestra ayuda de los comandos)\n"
		 bot_retorno+="/reboot (Reinicia el servidor vps)\n"
		 bot_retorno+="$LINE\n"
	 fi
	     ShellBot.sendMessage --chat_id ${message_chat_id[$id]} \
							--text "<i>$(echo -e $bot_retorno)</i>" \
							--parse_mode html
	return 0	
}

# Ejecutando escucha del bot
while true; do
    ShellBot.getUpdates --limit 100 --offset $(ShellBot.OffsetNext) --timeout 30
    for id in $(ShellBot.ListUpdates); do
	    chatuser="$(echo ${message_chat_id[$id]}|cut -d'-' -f2)"
	    echo $chatuser >&2
	    comando=(${message_text[$id]})
	    permited=$(curl -sSL "https://raw.githubusercontent.com/rudi9999/Script/master/Control-Admin")
	    if [[ $(echo $permited|grep "${chatuser}") = "" ]]; then
		 if [[ $(cat ${CID}|grep "${chatuser}") = "" ]]; then
			 case ${comando[0]} in
				 /[Ii]d|/[Ii]D)myid_fun &;;
				 /[Mm]enu|[Mm]enu|/[Ss]tart|[Ss]tart|[Cc]omensar|/[Cc]omensar)menu_fun &;;
				 /[Aa]yuda|[Aa]yuda|[Hh]elp|/[Hh]elp)ayuda_fun &;;
				 *)invalido &;;
			 esac
		 else
			 case ${comando[0]} in
				 /[Mm]enu|[Mm]enu|/[Ss]tart|[Ss]tart|[Cc]omensar|/[Cc]omensar)menu_fun &;;
				 /[Aa]yuda|[Aa]yuda|[Hh]elp|/[Hh]elp)ayuda_fun &;;
				 /[Ii]d|/[Ii]D)myid_fun &;;
				 /[Kk]eygen)gerar_key &;;
				 # /[Ss]cript)link_fun &;;
				 *)invalido &;;
			 esac
		 fi
	    else
		 case ${comando[0]} in
			 /[Mm]enu|[Mm]enu|/[Ss]tart|[Ss]tart|[Cc]omensar|/[Cc]omensar)menu_fun &;;
			 /[Aa]yuda|[Aa]yuda|[Hh]elp|/[Hh]elp)ayuda_fun &;;
			 /[Ii]d|/[Ii]D)myid_fun &;;
			 /[Kk]eygen)gerar_key &;;
			 /[Pp]ower)start_gen &;;
			 /[Ii]nfosys)infosys_fun &;;
			 /[Ll]ist)listID_fun &;;
			 /[Aa]dd)addID_fun "${comando[1]}" &;;
			 /[Dd]el|/[Dd]elid)deleteID_fun "${comando[1]}" &;;
			 /[Rr]eboot)reboot_fun &;;
			 /[Ss]cript)link_fun &;;
			 *)download_file &;;
			 /*)invalido &;;
		 esac
	    fi
    done
done
