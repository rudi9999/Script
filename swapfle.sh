#!/bin/bash
echo "creando archivo swap"
dd if=/dev/zero of=/swapfile bs=1MB count=2048
sleep 3
echo "comprovando tamaño del archivo"
ls -hl /swapfile
sleep 3
echo "asignando permisos"
chmod 600 /swapfile
sleep 3
echo "dando formato al achivo"
mkswap /swapfile
sleep 3
echo "Activando"
swapon /swapfile
sleep 3
echo "activado permanente"
echo "/swapfile none swap sw 0 0" >> /etc/fstab
sleep 3
echo "prioridad permanente"
echo "vm.swappiness=20" >> /etc/sysctl.conf
sleep 3
