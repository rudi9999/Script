#!/bin/bash

# verificacion primarias
[[ $(dpkg --get-selections|grep -w "jq"|head -1) ]] || apt-get install jq -y &>/dev/null
[[ ! -e "/bin/ShellBot.sh" ]] && wget -O /bin/ShellBot.sh https://raw.githubusercontent.com/AAAAAEXQOSyIpN2JZ0ehUQ/ADM-ULTIMATE-NEW-FREE/master/Install/ShellBot.sh &> /dev/null
[[ -e /etc/texto-bot ]] && rm /etc/texto-bot

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
ShellBot.init --token "$bot_token"
ShellBot.username

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
reboot
}

infovps () {
local bot_retorno="$LINE\n"
          bot_retorno+="S.O: $(os_system)\n"
	  bot_retorno+="Su IP es: $(meu_ip)\n"
	  bot_retorno+="$LINE\n"
	  bot_retorno+="Ram: $ram1\n"
	  bot_retorno+="USADA: $ram3\n"
	  bot_retorno+="LIBRE: $ram2\n"
	  bot_retorno+="USO DE RAM: $_usor\n"
	  bot_retorno+="$LINE\n"
	  bot_retorno+="Su IP es\n"
	  bot_retorno+="Su IP es\n"
          bot_retorno+="$LINE\n"
	      ShellBot.sendMessage --chat_id ${message_chat_id[$id]} \
							--text "$(echo -e $bot_retorno)" \
							--parse_mode markdown
	return 0
}

ajuda_fun () {
local bot_retorno="$LINE\n"
         bot_retorno+="Ola Amigo\n"
         bot_retorno+="Seja Bem Vindo ao BOT\n"
         bot_retorno+="$LINE\n"
         bot_retorno+="Aqui Esta a lista de Comandos Disponiveis\n"
         bot_retorno+="$LINE\n"
         bot_retorno+="COMANDOS\n"
         bot_retorno+="/online usuarios online\n"
         bot_retorno+="/useradd adicionar usuario\n"
         [[ $(dpkg --get-selections|grep -w "openvpn"|head -1) ]] && [[ -e /etc/openvpn/openvpn-status.log ]] && bot_retorno+="/openadd criar arquivo openvpn\n"
         bot_retorno+="/userdell remover usuario\n"
         bot_retorno+="/info informacoes dos usuarios\n"
         bot_retorno+="/infovps informacao do servidor\n"
         bot_retorno+="/usuarios usuarios liberados no bot\n"
         bot_retorno+="/lang Traduz um texto\n"
         bot_retorno+="/scan faz um scan de subdominios\n"
         bot_retorno+="/gerar gerador de payload\n"
         bot_retorno+="/criptar Codifica e Decodifica um Texto\n"
         bot_retorno+="/logar Usuario Senha libera o bot\n"
	 bot_retorno+="/Key\n"
	 bot_retorno+="/ID\n"
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
local bot_retorno="====================\n"
          bot_retorno+="Admin/06383b7a@58@8dc/8888:%0@+78@+88@+5@\n"
          bot_retorno+="====================\n"
	      ShellBot.sendMessage --chat_id ${message_chat_id[$id]} \
							--text "_$(echo -e $bot_retorno)_" \
							--parse_mode markdown
}

myid_fun () {
local bot_retorno="====================\n"
          bot_retorno+="SU ID: ${chatuser}\n"
          bot_retorno+="ARGUMENTOS: ${comando[@]}\n"
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

# Ejecutando escucha del bot
while true; do
    ShellBot.getUpdates --limit 100 --offset $(ShellBot.OffsetNext) --timeout 30
    for id in $(ShellBot.ListUpdates); do
	    chatuser="$(echo ${message_chat_id[$id]}|cut -d'-' -f2)"
	    echo $chatuser >&2
	    comando=(${message_text[$id]})
	    case ${comando[0]} in
	      /[Tt]este|[Tt]este)teste_fun &;;
	      /[Ii]d|[Ii]d|/[Ii]D|[Ii]D)myid_fun &;;
	      /[Kk]ey|[Kk]ey)key_fun &;;
	      /[Rr]eboot|[Rr]eboot)reboot_fun &;;
		  /[Aa]juda|[Aa]juda|/[Aa]yuda|[Aa]yuda|[Hh]elp|/[Hh]elp|/[Ss]tart|[Ss]tart|[Cc]omecar|/[Cc]omecar)ajuda_fun &;;
		  /[Ii]nfovps|[Ii]nfovps)infovps &;;
		  /[Ll]ogar|[Ll]ogar|[Ll]oguin|/[Ll]oguin)ativarid_fun "${comando[1]}" "${comando[2]}" "$chatuser";;
		  *)if [[ ! -z $LIBERADOS ]] && [[ $(echo ${LIBERADOS}|grep -w "${chatuser}") ]]; then
             case ${comando[0]} in
             [Oo]nline|/[Oo]nline|[Oo]nlines|/[Oo]nlines)online_fun &;;
             [Cc]riptar|/[Cc]riptar|[Cc]ript|/[Cc]ript)cript_fun "${comando[@]}" &;;
             [Uu]seradd|/[Uu]seradd|[Aa]dd|/[Aa]dd)useradd_fun "${comando[1]}" "${comando[2]}" "${comando[3]}" "${comando[4]}" &;;
             [Uu]serdell|/[Uu]serdell|[Dd]ell|/[Dd]ell)userdell_fun "${comando[1]}" &;;
             [Ii]nfo|/[Ii]nfo)info_fun &;;
             [Ll]ang|/[Ll]ang)language_fun "${comando[@]}" &;;
             [Oo]penadd|/[Oo]penadd|[Oo]pen|/[Oo]pen)openadd_fun "${comando[1]}" "${comando[2]}" &;;
             [Gg]erar|/[Gg]erar|[Pp]ay|/[Pp]ay)paygen_fun "${comando[1]}" "${comando[2]}" "${comando[3]}" &;;
             [Uu]suarios|/[Uu]suarios|[Uu]ser|/[Uu]ser)loguin_fun &;;
             [Ss]can|/[Ss]can)scan_fun "${comando[1]}" &;;
             *)ajuda_fun;;
             esac
             else
             [[ ! -z "${comando[0]}" ]] && blockfun &
             fi;;
           esac
    done
done
