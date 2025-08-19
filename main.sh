#!/usr/bin/env bash

source ./vars.sh
source ./slib.sh
source ./mlib.sh
source ./rlib.sh

while getopts ":m:f:h" opt ;
do
    case $opt in
    m) 
        MODEM=$OPTARG;
        ;;
    f) 
        FUNCTION=$OPTARG;
        ;;
    h) 
        help
        exit
        ;;
    *) 
        echo "Неверный параметр";
        exit
        ;;
    esac
done

NET=$(echo $MODEM | awk -F'.' '{ print $3 }')
MODEM_IP="192.168.$NET.1"

if [ ! $MODEM_IP ] || [ ! $FUNCTION ] ; then
    echo ""
    echo "Одна или несколько опций не указаны."
    echo ""
    exit
fi

proxy_stop
$FUNCTION
proxy_start
echo "IP сменился"