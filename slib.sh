#!/usr/bin/env bash

function get_ip() {
    if [ $http_proxy ]; then
        echo $http_proxy
        $CURL -s -m 5 ipinfo.io/ip
    else
        echo $MODEM_IP
        $CURL -s -m 5 --interface $MODEM_IP"00" ipinfo.io/ip
    fi
}

function proxy_stop() {
    PID=`pgrep -f "[-]$MODEM_IP"00".cfg"`
    if [ $PID ]; then
        kill -9 $PID
    fi
}

function proxy_start() {
    $PROXY $CFG_DIR/server$HOST-$MODEM_IP"00".cfg
}

function help() {
     echo ""
     echo "Параметры:"
     echo " -m IP-адрес модема"
     echo " -f Функция смены IP-адреса"
     echo " -h Справка"
     echo ""
}
