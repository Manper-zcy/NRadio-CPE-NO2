#!/bin/sh
# 检查是否已经有锁文件存在
lock_file="/var/run/network_status_update.lock"
exec 200>$lock_file
flock -n 200 || exit 1
while true
do
    # 获取网络模式信息
    if [ ! -f "/tmp/ledflag.conf" ]; then
        network_mode=$(sendat 2 'at+qnwinfo' | grep '+QNWINFO' | awk -F\" '{print $2}' | tr -d '\r\n')
        OX=$( sendat 2 "AT+CSQ" |grep "+CSQ:")
        OX=$(echo $OX | tr 'a-z' 'A-Z')
        CSQ=$(echo "$OX" | grep -o "+CSQ: [0-9]\{1,2\}" | grep -o "[0-9]\{1,2\}")
        if [ $CSQ = "99" ]; then
            CSQ="0"
            echo 0 > /sys/class/leds/hc:blue:cmode5/brightness
            echo 0 > /sys/class/leds/hc:blue:cmode4/brightness
            echo 0 > /sys/class/leds/hc:blue:sig1/brightness
            echo 0 > /sys/class/leds/hc:blue:sig2/brightness
            echo 0 > /sys/class/leds/hc:blue:sig3/brightness
            echo 1 > /sys/class/leds/hc:blue:int/brightness
        fi
        if [ -n "$CSQ" ]; then
            RSRQ=$(($CSQ * 100/31))
            if [ "$RSRQ" -ge -3 ]; then
                echo 1 > /sys/class/leds/hc:blue:sig1/brightness
                echo 1 > /sys/class/leds/hc:blue:sig2/brightness
                echo 1 > /sys/class/leds/hc:blue:sig3/brightness
            elif [ "$RSRQ" -ge -5 ] && [ "$RSRQ" -lt -3 ]; then
                echo 1 > /sys/class/leds/hc:blue:sig1/brightness
                echo 1 > /sys/class/leds/hc:blue:sig2/brightness
                echo 1 > /sys/class/leds/hc:blue:sig3/brightness
            elif [ "$RSRQ" -ge -10 ] && [ "$RSRQ" -lt -5 ]; then
                echo 1 > /sys/class/leds/hc:blue:sig1/brightness
                echo 1 > /sys/class/leds/hc:blue:sig2/brightness
                echo 1 > /sys/class/leds/hc:blue:sig3/brightness
            elif [ "$RSRQ" -ge -11 ] && [ "$RSRQ" -lt -10 ]; then
                echo 1 > /sys/class/leds/hc:blue:sig1/brightness
                echo 1 > /sys/class/leds/hc:blue:sig2/brightness
                echo 1 > /sys/class/leds/hc:blue:sig3/brightness
            elif [ "$RSRQ" -ge -12 ] && [ "$RSRQ" -lt -11 ]; then
                echo 1 > /sys/class/leds/hc:blue:sig1/brightness
                echo 1 > /sys/class/leds/hc:blue:sig2/brightness
                echo 1 > /sys/class/leds/hc:blue:sig3/brightness
            elif [ "$RSRQ" -ge -15 ] && [ "$RSRQ" -lt -12 ]; then
                echo 1 > /sys/class/leds/hc:blue:sig1/brightness
                echo 1 > /sys/class/leds/hc:blue:sig2/brightness
                echo 0 > /sys/class/leds/hc:blue:sig3/brightness
            elif [ "$RSRQ" -ge -17 ] && [ "$RSRQ" -lt -15 ]; then
                echo 1 > /sys/class/leds/hc:blue:sig1/brightness
                echo 0 > /sys/class/leds/hc:blue:sig2/brightness
                echo 0 > /sys/class/leds/hc:blue:sig3/brightness
            else
                echo 1 > /sys/class/leds/hc:blue:sig1/brightness
                echo 0 > /sys/class/leds/hc:blue:sig2/brightness
                echo 0 > /sys/class/leds/hc:blue:sig3/brightness
            fi
        else
            echo 0 > /sys/class/leds/hc:blue:cmode5/brightness
            echo 0 > /sys/class/leds/hc:blue:cmode4/brightness
            echo 0 > /sys/class/leds/hc:blue:sig1/brightness
            echo 0 > /sys/class/leds/hc:blue:sig2/brightness
            echo 0 > /sys/class/leds/hc:blue:sig3/brightness
            echo 1 > /sys/class/leds/hc:blue:int/brightness
        fi

        # 判断网络模式并更新LED状态
        if echo "$network_mode" | grep -qE "5G|NR5G"; then
            # 包含TDD，点亮hc:blue:cmode5，熄灭hc:blue:cmode4
            echo 1 > /sys/class/leds/hc:blue:cmode5/brightness
            echo 0 > /sys/class/leds/hc:blue:cmode4/brightness
        elif echo "$network_mode" | grep -q "LTE"; then
            # 包含LTE，点亮hc:blue:cmode4，熄灭hc:blue:cmode5
            echo 1 > /sys/class/leds/hc:blue:cmode4/brightness
            echo 0 > /sys/class/leds/hc:blue:cmode5/brightness
        else
            # 其他网络，熄灭hc:blue:cmode5和hc:blue:cmode4
            echo 0 > /sys/class/leds/hc:blue:cmode5/brightness
            echo 0 > /sys/class/leds/hc:blue:cmode4/brightness
        fi
    fi
    # 等待5秒
    sleep 5
done
# 释放锁
flock -u 200
