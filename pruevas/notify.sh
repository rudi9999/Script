#!/bin/bash

TOKEN="1469111562:AAFQ1bhxQCgdwarbsq4M4QP-Q_JaegOGak4"
ID="813491965"
MENSAJE="Servidor G reiniciado"
URL="https://api.telegram.org/bot$TOKEN/sendMessage"
curl -s -X POST $URL -d chat_id=$ID -d text="$MENSAJE"
