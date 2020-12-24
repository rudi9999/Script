#!/bin/bash

USRdatabase="/etc/ADMuser"

add_user () {
Fecha=`date +%d-%m-%y-%R`
#nome senha Dias limite
[[ $(cat /etc/passwd |grep $1: |grep -vi [a-z]$1 |grep -v [0-9]$1) ]] && return 1
valid=$(date '+%C%y-%m-%d' -d " +$3 days") && datexp=$(date "+%F" -d " + $3 days")
useradd -M -s /bin/false $1 -e ${valid} || return 1
(echo $2; echo $2)|passwd $1 || {
    userdel --force $1
    return 1
    }
[[ -e ${USRdatabase} ]] && {
   newbase=$(cat ${USRdatabase}|grep -w -v "$1")
   echo "$1|$2|${datexp}|$4" > ${USRdatabase}
   for value in `echo ${newbase}`; do
   echo $value >> ${USRdatabase}
   echo $value >> /etc/B-ADMuser/ADMuser-"$Fecha"
   done
   } || echo "$1|$2|${datexp}|$4" > ${USRdatabase}
}

add_user prueva123 prueva123 5 5 && echo "Usuario Creado con Exito" || echo "Error, Usuario no creado"
