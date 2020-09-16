#!/bin/bash

# verificacion primarias
CIDdir=/etc/ADM-db && [[ ! -d ${CIDdir} ]] && mkdir ${CIDdir}
CID="${CIDdir}/Control-ID" && [[ ! -e ${CID} ]] && wget -O ${CID} https://raw.githubusercontent.com/rudi9999/Script/master/Control-ID &> /dev/null
[[ $(dpkg --get-selections|grep -w "jq"|head -1) ]] || apt-get install jq -y &>/dev/null
[[ ! -e "/bin/ShellBot.sh" ]] && wget -O /bin/ShellBot.sh https://raw.githubusercontent.com/shellscriptx/shellbot/master/ShellBot.sh &> /dev/null
[[ -e /etc/texto-bot ]] && rm /etc/texto-bot
LINE="==========================="

#HORA Y FECHA
_hora=$(printf '%(%H:%M:%S)T') 
_fecha=$(printf '%(%D)T') 

#PROCESSADOR
_core=$(printf '%-1s' "$(grep -c cpu[0-9] /proc/stat)")
_usop=$(printf '%-1s' "$(top -bn1 | awk '/Cpu/ { cpu = "" 100 - $8 "%" }; END { print cpu }')")

#SISTEMA-USO DA CPU-MEMORIA RAM
ram1=$(free -h | grep -i mem | awk {'print $2'})
ram2=$(free -h | grep -i mem | awk {'print $4'})
ram3=$(free -h | grep -i mem | awk {'print $3'})

_ram=$(printf ' %-9s' "$(free -h | grep -i mem | awk {'print $2'})")
_usor=$(printf '%-8s' "$(free -m | awk 'NR==2{printf "%.2f%%", $3*100/$2 }')")

#info del sistema
os_system () {
system=$(echo $(cat -n /etc/issue |grep 1 |cut -d' ' -f6,7,8 |sed 's/1//' |sed 's/      //')) && echo $system|awk '{print $1, $2}'
}

# Importando API
source ShellBot.sh

# Token del bot
bot_token='1249652996:AAE7VsdIppmjKq4O-eX3tk70WdHvPVzz7wA'

# Inicializando el bot
ShellBot.init --token "$bot_token" --monitor --return map
ShellBot.username

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
		# Obtém informações do arquivo, incluindo sua localização nos servidores do Telegram.
		ShellBot.getFile --file_id $file_id

		# Baixa o arquivo do diretório remoto contido em '{return[file_path]}' após
		# a chamada do método 'ShellBot.getFile'.
		# Obs: Recurso disponível somente no modo de retorno 'map'.
		if ShellBot.downloadFile --file_path ${return[file_path]} --dir $HOME; then
			ShellBot.sendMessage	--chat_id "${message_chat_id[$id]}" \
									--reply_to_message_id "${message_message_id[$id]}" \
									--text "Arquivo baixado com sucesso!!\n\nSalvo em: ${return[file_path]}"
		fi
	fi

	return 0
}


listID_fun () {
lsid=$(cat -n ${CID})
local bot_retorno="$LINE\n"
          bot_retorno+="Lista de id permitidos\n"
          bot_retorno+="$LINE\n"
          bot_retorno+="${lsid}\n"
          bot_retorno+="$LINE\n"
	      ShellBot.sendMessage --chat_id ${message_chat_id[$id]} \
							--text "_$(echo -e $bot_retorno)_" \
							--parse_mode markdown
}

addID_fun () {
[[ $(cat ${CID}|grep "${1}") = "" ]] && {
echo "/${1}" >> ${CID}
local bot_retorno="$LINE\n"
          bot_retorno+="ID agregado con exito\n"
          bot_retorno+="$LINE\n"
	      ShellBot.sendMessage --chat_id ${message_chat_id[$id]} \
							--text "_$(echo -e $bot_retorno)_" \
							--parse_mode markdown
ID-db_fun
  } || {
local bot_retorno="$LINE\n"
          bot_retorno+="====ERROR====\n"
          bot_retorno+="Este ID ya existe\n"
          bot_retorno+="$LINE\n"
	      ShellBot.sendMessage --chat_id ${message_chat_id[$id]} \
							--text "_$(echo -e $bot_retorno)_" \
							--parse_mode markdown
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
							--text "_$(echo -e $bot_retorno)_" \
							--parse_mode markdown
ID-db_fun
}

ID-db_fun () {
cp ${CID} $HOME/
local bot_retorno2
          ShellBot.sendDocument --chat_id ${message_chat_id[$id]} \
                             --document @$HOME/Control-ID
rm $HOME/Control-ID
}

meu_ip () {
if [[ -e /etc/MEUIPADM ]]; then
echo "$(cat /etc/MEUIPADM)"
else
MEU_IP=$(ip addr | grep 'inet' | grep -v inet6 | grep -vE '127\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | grep -o -E '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | head -1)
MEU_IP2=$(wget -qO- ipv4.icanhazip.com)
[[ "$MEU_IP" != "$MEU_IP2" ]] && echo "$MEU_IP2" || echo "$MEU_IP"
echo "$MEU_IP2" > /etc/MEUIPADM
fi
}

reboot_fun () {
  permited=$(curl -sSL "https://raw.githubusercontent.com/rudi9999/Script/master/Control-Admin")
  [[ $(echo $permited|grep "${chatuser}") = "" ]] && {
  local bot_retorno="$LINE\n"
          bot_retorno+="Solo el administrador tiene acceso a este comando\n"
          bot_retorno+="$LINE\n"
	      ShellBot.sendMessage --chat_id ${message_chat_id[$id]} \
							--text "_$(echo -e $bot_retorno)_" \
							--parse_mode markdown
  } || {
  ShellBot.sendMessage --chat_id ${message_chat_id[$id]} --text Reiniciando...
  sleep 2
  reboot
  }
}

infosys_fun () {
local bot_retorno="$LINE\n"
          bot_retorno+="S.O: $(os_system)\n"
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
							--text "$(echo -e $bot_retorno)" \
							--parse_mode markdown
	return 0
}

blockfun () {
local bot_retorno="$LINE\n"
          bot_retorno+="Usted no tiene permitdo usar este bot\n"
          bot_retorno+="$LINE\n"
          bot_retorno+="Comandos Bloqueados\n"
          bot_retorno+="$LINE\n"
	      ShellBot.sendMessage --chat_id ${message_chat_id[$id]} \
							--text "$(echo -e $bot_retorno)" \
							--parse_mode markdown
	return 0
}

key_fun () {
  # unset permited
  # permited=$(curl -sSL "https://raw.githubusercontent.com/rudi9999/Script/master/Control-ID")
  [[ $(cat ${CID}|grep "${chatuser}") = "" ]] && {
  local bot_retorno="$LINE\n"
          bot_retorno+="Tu ID de Telegram no esta autorizado\n"
          bot_retorno+="CONTACTA A @Rufu99\n"
          bot_retorno+="$LINE\n"
	      ShellBot.sendMessage --chat_id ${message_chat_id[$id]} \
							--text "_$(echo -e $bot_retorno)_" \
							--parse_mode markdown
  } || {
  local bot_retorno="====================\n"
          bot_retorno+="Admin/06383b7a@58@8dc/8888:%0@+78@+88@+5@\n"
          bot_retorno+="====================\n"
	      ShellBot.sendMessage --chat_id ${message_chat_id[$id]} \
							--text "_$(echo -e $bot_retorno)_" \
							--parse_mode markdown
  }
}

myid_fun () {
local bot_retorno="====================\n"
          bot_retorno+="SU ID: ${chatuser}\n"
          bot_retorno+="====================\n"
	      ShellBot.sendMessage --chat_id ${message_chat_id[$id]} \
							--text "_$(echo -e $bot_retorno)_" \
							--parse_mode markdown
}

teste_fun () {
local bot_retorno="$LINE\n"
          bot_retorno+="USUARIO: ${chatuser}\n"
          bot_retorno+="ARGUMENTOS: ${comando[@]}\n"
          bot_retorno+="$LINE\n"
	      ShellBot.sendMessage --chat_id ${message_chat_id[$id]} \
							--text "_$(echo -e $bot_retorno)_" \
							--parse_mode markdown
}

invalido () {
local bot_retorno="$LINE\n"
         bot_retorno+="Comando invalido!\n"
         bot_retorno+="$LINE\n"
	     ShellBot.sendMessage --chat_id ${message_chat_id[$id]} \
							--text "$(echo -e $bot_retorno)" \
							--parse_mode markdown
	return 0	
}

ajuda_fun () {
local bot_retorno="$LINE\n"
         bot_retorno+="COMANDOS\n"
         bot_retorno+="/infosys (informacion del sistema)\n"
	 bot_retorno+="/ID (muestra sus ID)\n"
	 bot_retorno+="/Key (requiere permisos)\n"
	 bot_retorno+="$LINE\n"
	 bot_retorno+="Comandos solo admin\n"
	 bot_retorno+="/addid (añadir nuevas ID)\n"
	 bot_retorno+="/del (quitar un ID)\n"
	 bot_retorno+="/list (lista de ID permitidas)\n"
	 bot_retorno+="/reboot (solo administrador)\n"
         bot_retorno+="$LINE\n"
	     ShellBot.sendMessage --chat_id ${message_chat_id[$id]} \
							--text "$(echo -e $bot_retorno)" \
							--parse_mode markdown
	return 0	
}

# Ejecutando escucha del bot
while true; do
    ShellBot.getUpdates --limit 100 --offset $(ShellBot.OffsetNext) --timeout 30
    for id in $(ShellBot.ListUpdates); do
	    chatuser="$(echo ${message_chat_id[$id]}|cut -d'-' -f2)"
	    echo $chatuser >&2
	    comando=(${message_text[$id]})
	    case ${comando[0]} in
	      /[Tt]este)teste_fun &;;
	      /[Ii]d|/[Ii]D)myid_fun &;;
	      /[Kk]ey)key_fun &;;
	      /[Rr]eboot)reboot_fun &;;
	      /[Ff]oto)download_file &;;
		  /[Aa]yuda|[Aa]yuda|[Hh]elp|/[Hh]elp|/[Ss]tart|[Ss]tart|[Cc]omensar|/[Cc]omensar)ajuda_fun &;;
		  /[Ii]nfosys)infosys_fun &;;
		  /[Aa]ddid|/[Aa]dd)addID_fun "${comando[1]}" &;;
		  /[Dd]el|/[Dd]elid)deleteID_fun "${comando[1]}" &;;
		  /[Ll]istid|/[Ll]ist)listID_fun &;;
		  /[Ll]ogar|[Ll]ogar|[Ll]oguin|/[Ll]oguin)ativarid_fun "${comando[1]}" "${comando[2]}" "$chatuser";;
		  /*)invalido &;;
           esac
    done
done
