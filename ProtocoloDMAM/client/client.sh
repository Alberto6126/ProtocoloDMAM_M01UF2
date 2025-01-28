#!/bin/bash

PUERTO=2022
IP=$(ip a | grep "scope global" | cut -d ' ' -f6 | cut -d '/' -f1)
IPSERVER=localhost
LINEAS="::::::::::::::::::::::::::::::::::::::"
FILENAME="pepito23"
SEPARADORHEADER="&&"
MD5=$(cat /home/enti/ProtocoloDMAM_M01UF2/ProtocoloDMAM/client/imacow.txt | md5sum | cut -c 1-32)
OK="OK"
KO="KO"
RUTA="/home/enti/ProtocoloDMAM_M01UF2/ProtocoloDMAM/client/imacow.txt"

clear
echo "IP: "$IP

echo $IP | ncat $IPSERVER $PUERTO
echo "FILENAME:"$FILENAME$SEPARADORHEADER"MD5:"$MD5 | ncat $IPSERVER $PUERTO

SERVERCONFIRM=$(ncat -l $PUERTO)
echo $SERVERCONFIRM

if [ $SERVERCONFIRM = $OK ]; then
	echo "Exito en el envio de cabecera"
	echo $LINEAS
	#echo "Enviando Hash"
	#HASH=$(cat $RUTA | md5sum | cut -c 1-32)
	#echo "Enviando: "$HASH "a" $IPSERVER "por el puerto" $PUERTO
       	#echo $HASH | ncat $IPSERVER $PUERTO
	SERVERCONFIRM=$(ncat -l $PUERTO)
	if [ $SERVERCONFIRM = $OK ]; then
		echo $LINEAS
		echo "Enviando datos del archivo"
		cat $RUTA | ncat $IPSERVER $PUERTO
		$SERVERCONFIRM=$(ncat -l $PUERTO)
		if [ $SERVERCONFIRM = $OK ]; then
			echo $LINEAS 
			echo "Operacion completada con exito, saliendo..."
			sleep 5
			clear
		else 
			echo "Ha habido un error, saliendo..."
			sleep 5
			clear
		fi
	else 
		echo "Ha habido un error, saliendo..."
		sleep 5
		clear	
	fi			
else 
	echo "Error en el envio de cabecera"
	return
fi
