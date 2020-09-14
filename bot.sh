#!/bin/bash

# Importando API
source ShellBot.sh

# Token del bot
bot_token='1249652996:AAE7VsdIppmjKq4O-eX3tk70WdHvPVzz7wA'

# Inicializando el bot
ShellBot.init --token "$bot_token"
ShellBot.username

# boas vindas
msg_bem_vindo()
{
	local msg

	# Texto da mensagem
	msg="🆔 [@${message_new_chat_member_username[$id]:-null}]\n"
    msg+="🗣 Olá *${message_new_chat_member_first_name[$id]}*"'!!\n\n'
    msg+="Seja bem-vindo(a) ao *${message_chat_title[$id]}*.\n\n"
    msg+='`Se precisar de ajuda ou informações sobre meus comandos, é só me chamar no privado.`'"[@$(ShellBot.username)]"

	# Envia a mensagem de boas vindas.
	ShellBot.sendMessage --chat_id ${message_chat_id[$id]} \
							--text "$(echo -e $msg)" \
							--parse_mode markdown

	return 0	
}

myid_fun () {
local bot_retorno="====================\n"
          bot_retorno+="Su ID: ${chatuser}\n"
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
		  /[Aa]juda|[Aa]juda|[Hh]elp|/[Hh]elp)ajuda_fun &;;
		  /[Ss]tart|[Ss]tart|[Cc]omecar|/[Cc]omecar)ajuda_fun &;;
		  /[Ll]ogar|[Ll]ogar|[Ll]oguin|/[Ll]oguin)ativarid_fun "${comando[1]}" "${comando[2]}" "$chatuser";;
		  *)if [[ ! -z $LIBERADOS ]] && [[ $(echo ${LIBERADOS}|grep -w "${chatuser}") ]]; then
             case ${comando[0]} in
             [Oo]nline|/[Oo]nline|[Oo]nlines|/[Oo]nlines)online_fun &;;
             [Cc]riptar|/[Cc]riptar|[Cc]ript|/[Cc]ript)cript_fun "${comando[@]}" &;;
             [Uu]seradd|/[Uu]seradd|[Aa]dd|/[Aa]dd)useradd_fun "${comando[1]}" "${comando[2]}" "${comando[3]}" "${comando[4]}" &;;
             [Uu]serdell|/[Uu]serdell|[Dd]ell|/[Dd]ell)userdell_fun "${comando[1]}" &;;
             [Ii]nfo|/[Ii]nfo)info_fun &;;
             [Ii]nfovps|/[Ii]nfovps)infovps &;;
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
