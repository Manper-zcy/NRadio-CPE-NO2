#!/bin/sh
# 检查是否已经有锁文件存在
lock_file="/var/run/network_status_update-AK68.lock"
exec 200>$lock_file
flock -n 200 || exit 1

while true
do
    # 检测192.168.225.1是否可达
    if ping -c 1 192.168.225.1 > /dev/null 2>&1; then
        echo "RM520N" > /tmp/modconf-AK68.conf

    elif ping -c 1 192.168.8.1 > /dev/null 2>&1; then
        echo "MT5700" > /tmp/modconf-AK68.conf
    else
        echo "AK68套件断开或未接入！" > /tmp/modconf-AK68.conf
        echo "设备检测中..." > /tmp/devck.conf
        echo 0 > /sys/class/leds/hc:blue:cmode5/brightness
        echo 0 > /sys/class/leds/hc:blue:cmode4/brightness
        sleep 1
        continue
    fi

    modconf=$(cat /tmp/modconf-AK68.conf)
    if [ ! -f "/tmp/ledflag-AK68.conf" ]; then
        if [ "$modconf" = "RM520N" ]; then
            network_mode=$(atsd_tools_cli -i cpe -c at+qnwinfo | grep '+QNWINFO' | awk -F\" '{print $2}' | tr -d '\r')
        elif [ "$modconf" = "MT5700" ]; then
            network_mode=$(atsd_tools_cli -i cpe -c 'AT^HCSQ?')
        fi
        # 判断网络模式并更新LED状态
        if echo "$network_mode" | grep -Eq "5G|NR"; then
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
        sleep 10
    fi
    # 等待10秒
done

# 释放锁
flock -u 200
