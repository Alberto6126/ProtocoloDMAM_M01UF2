#!/bin/bash
PUERTO=2022
IP=$(ip a | grep "scope global" | cut -d ' ' -f6 | cut -d '/' -f1)
LINEAS=":::::::::::::::::::::::::::::::::::::::::::::::::"
HEADERFILENAME="FILENAME"
NEXTSTEP=0
ARCHIVOTEMP="TEMP.txt"
clear
echo "Puerto: "$PUERTO
echo "IP: "$IP
echo "LINEAS: "$LINEAS
echo "HeaderFilename: "$HEADERFILENAME
echo "NextStep: "$NEXTSTEP

#1: El servidor escucha
echo $LINEAS
echo "- 1 - El puerto esta en "$PUERTO", establecido en " $IP
echo $LINEAS
#2: El servidor espera el envio de paquete
echo "- 2 - Esperando conexion"
IPREC=$(ncat -l -p $PUERTO)
echo "La IP del cliente es: "$IPREC
FILENAMEREC=$(ncat -l -p $PUERTO)
echo "El paquete recibido es: "$FILENAMEREC
FILENAMERECHEADER=$(echo $FILENAMEREC | cut -c 1-8)
echo $LINEAS
echo "Header esperado: "$HEADERFILENAME
echo "Header recibido: "$FILENAMERECHEADER
echo $LINEAS
#3: El servidor verifica si el paquete recibido contiene el header filename
if [ $FILENAMERECHEADER = $HEADERFILENAME ]; then
	TARGETFILENAME=$(echo $FILENAMEREC | cut -c 10- | cut -d '&' -f1 )
	HASHREC=$(echo $FILENAMEREC | cut -c 10- | cut -d '&' -f3 | cut -d ':' -f2 | cut -c 1-32)
	echo "Hash del archivo: "$HASHREC
	echo "Nombre objetivo del archivo: "$TARGETFILENAME
	echo "- 3 - Cabecera verificada"
	echo "OK" | ncat $IPREC $PUERTO
	NEXTSTEP=1
else 
	echo "- 3 - Cabecera rechazada"
	echo "KO" | ncat $IPREC $PUERTO
	return
	#ENVIAR KO
fi
#4: El servidor espera y verifica el hash
if [ $NEXTSTEP = 1 ]; then
	#echo "- 4 - Esperando Hash"
	#HASHREC=$(ncat -l -p $PUERTO | cut -c 1-32)
	echo "	Hash recibido: "$HASHREC
	echo $LINEAS
	echo "OK" | ncat $IPREC $PUERTO
	#5: El servidor espera los datos del archivo y crea un hash
	echo "- 5 - Esperando datos"
	ncat -l -p $PUERTO > $ARCHIVOTEMP
	HASHCREADO=$(cat $ARCHIVOTEMP | md5sum | cut -c 1-32)
	echo "Hash de los datos: " $HASHCREADO
#6: El servidor verifica el hash creado anteriormente con el nuevo hash
	if [ $HASHCREADO = $HASHREC ]; then
		echo $LINEAS
		echo "- 6 - Verificando el hash"	
		echo "Se ha recibido el hash correcto"
		echo $LINEAS
		#7: El servidor envía los datos a un cliente (localhost)
		# En este punto se tendrían que enviar los datos del arcvhivo a otro cliente con 
		# cat $ARCHIVOTEMP | ncat (IP DEL CLIENTE) $PUERTO
		# en nuestro caso vamos a generar un nuevo archivo de texto en la carpeta de archivos transferidos
		echo "- 7 - Transfiriendo el archivo..."
		cat $ARCHIVOTEMP > /home/enti/ProtocoloDMAM_M01UF2/ProtocoloDMAM/archivostransferidos/$TARGETFILENAME
		rm $ARCHIVOTEMP
		echo $LINEAS
		echo "- 8 - Archivo transferido."
		echo "	Operacón realizada con exito, saliendo..."
		echo "OK" | ncat $IPREC $PUERTO
		sleep 5
	
		
	else 
		echo "Mal mal mal"


	fi
	
else 
	clear "HA OCURRIDO UN ERROR, NO TENDRIAS QUE ESTAR AQUI, SALIENDO..."
	sleep 5
	return
fi

#7: El servidor envía los datos a un cliente (localhost)
