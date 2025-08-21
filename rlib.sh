#!/usr/bin/env bash

function a() {
    IP_BEFORE=$(get_ip)
    for i in {1..3}
    do
        counter=$i
        set_mode >/dev/null 2>&1 ; sleep 3
        IP_AFTER=$(get_ip)
        if [ $IP_AFTER ]; then
            if [ $IP_BEFORE != $IP_AFTER ]; then
                break
            fi
        fi
    done
    if [ $counter == 3 ]; then
        modem_reboot >/dev/null 2>&1
    fi
}

function aa() {
    IP_BEFORE=$(get_ip)
    for i in {1..3}
    do
        counter=$i
        modem_connection_reload ; sleep 3
        IP_AFTER=$(get_ip)
        if [ $IP_AFTER ]; then
            if [ $IP_BEFORE != $IP_AFTER ]; then
                break
            fi
        fi
    done
    if [ $counter == 3 ]; then
        modem_connection_reset
    fi
}

function aaa() {
    IP_BEFORE=$(get_ip)
    SYSCFGEX2=$( (echo "atc 'AT^SYSCFGEX?'" && \
                sleep 1 && \
                echo "quit") | telnet $MODEM_IP | grep -o "800C5" | wc -l ) 
    if [ $SYSCFGEX2 == 1 ]; then
        ( echo "atc 'AT+CFUN=7'"; \
        sleep 1; \
        echo "atc 'AT+CFUN=1'"; \
        sleep 1; \
        echo "atc 'AT^SYSCFGEX=\"03\",400000,1,2,4,,'"; \
        sleep 1; \
        echo "quit"; ) | telnet $MODEM_IP >/dev/null 2>&1
    fi
    if [ $SYSCFGEX2 == 0 ]; then
        ( echo "atc 'AT+CFUN=7'"; \
        sleep 1; \
        echo "atc 'AT+CFUN=1'"; \
        sleep 1; \
        echo "atc 'AT^SYSCFGEX=\"03\",400000,1,2,800C5,,'"; \
        sleep 1; \
        echo "quit"; ) | telnet $MODEM_IP >/dev/null 2>&1
    fi
    for i in {1..3}
    do
        counter=$i
        IP_AFTER=$(get_ip)
        if [ $IP_AFTER ]; then
            if [ $IP_BEFORE != $IP_AFTER ]; then
                break
            else
                modem_connection_reload
                sleep 3
            fi
        fi
    done
    if [ $counter == 3 ]; then
        modem_connection_reset
    fi
}

function b() {
    let PROXY_PORT=9000+$(echo $MODEM_IP | awk -F'.' '{ print $3 }')
    export http_proxy=http://$PROXY_LOGIN:$PROXY_PASSWORD@localhost:$PROXY_PORT
    MODEM_IP_TMP=$MODEM_IP    
    MODEM_IP="192.168.8.1"
    a
    MODEM_IP=$MODEM_IP_TMP
}

function c() {
    $SSH -o StrictHostKeyChecking=no root@$MODEM_IP "modem 0 restart" >/dev/null 2>&1
    $SSH -o StrictHostKeyChecking=no root@$MODEM_IP "modem restart" >/dev/null 2>&1
}

function d() {
    $SSH -o StrictHostKeyChecking=no root@$MODEM_IP "echo -en 'AT+CFUN=4\r\n' > /dev/ttyUSB2 && \
                                                    sleep 2 && \
                                                    echo -en 'AT+CFUN=1\r\n' > /dev/ttyUSB2 && \
                                                    sleep 2 && \
                                                    echo -en 'AT+CFUN=1\r\n' > /dev/ttyUSB2 && \
                                                    sleep 1 && \
                                                    ifup modem1"
}

function e() {
    $SSH -o StrictHostKeyChecking=no root@$MODEM_IP "echo -en 'AT+CFUN=4\r\n' > /dev/ttyUSB2 && \
                                                    sleep 2 && \
                                                    echo -en 'AT+CFUN=1\r\n' > /dev/ttyUSB2 && \
                                                    ifup LTE"
}

function f() {
    $SSH -o StrictHostKeyChecking=no root@$MODEM_IP "echo -en 'AT+CFUN=4\r\n' > /dev/ttyUSB1 && \
                                                    sleep 2 && \
                                                    echo -en 'AT+CFUN=1\r\n' > /dev/ttyUSB1 && \
                                                    ifup LTE"
}

function g() {
    $SSH -o StrictHostKeyChecking=no root@$MODEM_IP "echo -en 'AT+QCFG=\"nwscanmode\",2,1\r\n' > /dev/ttyUSB2 && \
                                                    sleep 5 && \
                                                    echo -en 'AT+QCFG=\"nwscanmode\",3,1\r\n' > /dev/ttyUSB2 && \
                                                    sleep 1 && \
                                                    ifup modem1"
}

