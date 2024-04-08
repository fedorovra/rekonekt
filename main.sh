#!/usr/bin/env bash

source ./vars.sh
source ./slib.sh
source ./mlib.sh
source ./rlib.sh

while getopts ":m:f:h" opt ;
do
    case $opt in
    m) 
        MODEM_IP=$OPTARG;
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