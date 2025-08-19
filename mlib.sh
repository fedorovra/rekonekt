#!/usr/bin/env bash

function get_token() {
    DATA=$(curl -s http://$MODEM_IP/api/webserver/SesTokInfo)
    SESSION_ID=$(echo "$DATA" | grep "SesInfo" | awk -F'[<>]' '/SesInfo/{print $3}')
    TOKEN=$(echo "$DATA" | grep "TokInfo" | awk -F'[<>]' '/TokInfo/{print $3}')

    if [ ! $TOKEN ]; then
        DATA=$(curl -s http://$MODEM_IP/api/webserver/token)
        TOKEN=$(echo "$DATA" | grep "token" |  awk -F'[<>]' '/token/{print $3}')
    fi
}

function modem_reboot() {
    get_token
    curl -s -X POST \
                        -H "Cookie: $SESSION_ID" \
                        -H "__RequestVerificationToken: $TOKEN" \
                        -d "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
                            <request>
                                <Control>1</Control>
                            </request>" \
                        http://$MODEM_IP/api/device/control
}

function get_mode() {
    get_token
    if [ ! $TOKEN ]; then
        curl -s \
                        -H "Referer: http://$MODEM_IP/index.html" \
                        "http://$MODEM_IP/goform/goform_get_cmd_process?cmd=network_type"
    else
        curl -s \
                        -H "Cookie: $SESSION_ID" \
                        -H "__RequestVerificationToken: $TOKEN" \
                        http://$MODEM_IP/api/net/net-mode
    fi
}

function set_mode() {
    get_token
    if [ ! $TOKEN ]; then
        MODE=$(get_mode | python3 -c "import sys, json; print(json.load(sys.stdin)['network_type'])")
        if [ $MODE != 'LTE' ]; then
            MODE="Only_LTE"
        else
            MODE="Only_WCDMA"
        fi
        curl -s -X POST \
                        -H "Referer: http://$MODEM_IP/index.html" \
                        -d "isTest=false&goformId=SET_BEARER_PREFERENCE&BearerPreference=$MODE" \
                        "http://$MODEM_IP/goform/goform_set_cmd_process"
    else
        MODE=$(get_mode | grep NetworkMode | cut -b 14-15)
        if [ $MODE != '03' ]; then
            MODE="03"
        else
            MODE="00"
        fi
        get_token
        curl -s -X POST \
                        -H "Cookie: $SESSION_ID" \
                        -H "__RequestVerificationToken: $TOKEN" \
                        -d "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
                            <request>
                                <NetworkMode>$MODE</NetworkMode>
                            </request>" \
                        http://$MODEM_IP/api/net/net-mode
    fi
}

function modem_connection_reload() {
    ( echo "atc 'AT+CFUN=7'"; \
    sleep 1; \
    echo "atc 'AT+CFUN=1'"; \
    sleep 1; \
    echo "atc 'AT+CFUN=1'"; \
    sleep 1; \
    echo "atc 'AT+CFUN=1'"; \
    sleep 1; \
    echo "quit"; ) | telnet $MODEM_IP #>/dev/null 2>&1
}

function modem_connection_reset() {
    ( echo "atc 'AT^RESET'"; \
    sleep 1; \
    echo "quit"; ) | telnet $MODEM_IP >/dev/null 2>&1
}