#!/bin/bash

cat_users=$(cat /etc/passwd|grep 'home'|grep 'false'|grep -v 'syslog'|awk -F ':' '{print $1}')

for user in `echo "$cat_users"`; do
    userpid=$(ps -u $user |awk {'print $1'})
    kill "$userpid" 2>/dev/null
    userdel --force $user
    user2=$(printf '%-15s' "$user")
    echo "USUARIO: $user2 Eliminado"
done
