#!/bin/bash
echo "creando archivo swap"
dd if=/dev/zero of=/swapfile bs=1MB count=2048
echo "comprovando tamaño del archivo"
ls -hl /swapfile
echo "asignando permisos"
chmod 600 /swapfile
echo "dando formato al achivo"
mkswap /swapfile
echo "Activando"
swapon /swapfile
echo "activado permanente"
echo "/swapfile none swap sw 0 0" >> /etc/fstab
echo "prioridad permanente"
echo "vm.swappiness=20" >> /etc/sysctl.conf
