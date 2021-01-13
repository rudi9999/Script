#!/bin/bash
var=$(pwd)
cd /etc/newadm
mv menu menu.back
wget https://github.com/rudi9999/Script/raw/master/menu
chmod +x menu
cd $var
rm menu_update.sh
echo " actulizacion completa"
echo -ne " enter para terminar"
read foo
