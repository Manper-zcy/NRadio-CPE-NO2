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
        echo 0 > /sys/class/leds/hc:blue:sig1/brightness
        echo 0 > /sys/class/leds/hc:blue:sig2/brightness
        echo 0 > /sys/class/leds/hc:blue:sig3/brightness
        echo 1 > /sys/class/leds/hc:blue:int/brightness
        sleep 1
        continue
    fi
    #不和内置模块LED灯冲突
    if pgrep -f "netmodeled.sh" > /dev/null; then
    	continue
    else
        echo "内置LED灯控制器未运行，接管控制。"
    fi
    #判断不同模组执行不同的判断
    modconf=$(cat /tmp/modconf-AK68.conf)
    if [ ! -f "/tmp/ledflag.conf" ]; then
        if echo "$modconf" | grep -q "RM520N"; then
            network_mode=$(atsd_tools_cli -i cpe -c at+qnwinfo | grep '+QNWINFO' | awk -F\" '{print $2}' | tr -d '\r')
            OX=$( atsd_tools_cli -i cpe -c "AT+CSQ" |grep "+CSQ:")
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
                if [ "$RSRQ" -ge 99 ]; then
                    echo 1 > /sys/class/leds/hc:blue:sig1/brightness
                    echo 1 > /sys/class/leds/hc:blue:sig2/brightness
                    echo 1 > /sys/class/leds/hc:blue:sig3/brightness
                elif [ "$RSRQ" -ge 95 ] && [ "$RSRQ" -lt 99 ]; then
                    echo 1 > /sys/class/leds/hc:blue:sig1/brightness
                    echo 1 > /sys/class/leds/hc:blue:sig2/brightness
                    echo 1 > /sys/class/leds/hc:blue:sig3/brightness
                elif [ "$RSRQ" -ge 90 ] && [ "$RSRQ" -lt 95 ]; then
                    echo 1 > /sys/class/leds/hc:blue:sig1/brightness
                    echo 1 > /sys/class/leds/hc:blue:sig2/brightness
                    echo 1 > /sys/class/leds/hc:blue:sig3/brightness
                elif [ "$RSRQ" -ge 85 ] && [ "$RSRQ" -lt 90 ]; then
                    echo 1 > /sys/class/leds/hc:blue:sig1/brightness
                    echo 1 > /sys/class/leds/hc:blue:sig2/brightness
                    echo 1 > /sys/class/leds/hc:blue:sig3/brightness
                elif [ "$RSRQ" -ge -80 ] && [ "$RSRQ" -lt 85 ]; then
                    echo 1 > /sys/class/leds/hc:blue:sig1/brightness
                    echo 1 > /sys/class/leds/hc:blue:sig2/brightness
                    echo 1 > /sys/class/leds/hc:blue:sig3/brightness
                elif [ "$RSRQ" -ge 65 ] && [ "$RSRQ" -lt 80 ]; then
                    echo 1 > /sys/class/leds/hc:blue:sig1/brightness
                    echo 1 > /sys/class/leds/hc:blue:sig2/brightness
                    echo 0 > /sys/class/leds/hc:blue:sig3/brightness
                elif [ "$RSRQ" -ge 1 ] && [ "$RSRQ" -lt 65 ]; then
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
            if echo "$network_mode" | grep -Eq "5G|NR"; then
                # 包含TDD，点亮hc:blue:cmode5，熄灭hc:blue:cmode4
                echo 1 > /sys/class/leds/hc:blue:cmode5/brightness
                echo 0 > /sys/class/leds/hc:blue:cmode4/brightness
                echo 0 > /sys/class/leds/hc:blue:int/brightness
            elif echo "$network_mode" | grep -q "LTE"; then
                # 包含LTE，点亮hc:blue:cmode4，熄灭hc:blue:cmode5
                echo 1 > /sys/class/leds/hc:blue:cmode4/brightness
                echo 0 > /sys/class/leds/hc:blue:cmode5/brightness
                echo 0 > /sys/class/leds/hc:blue:int/brightness
            else
                # 其他网络，熄灭hc:blue:cmode5和hc:blue:cmode4
                echo 0 > /sys/class/leds/hc:blue:cmode5/brightness
                echo 0 > /sys/class/leds/hc:blue:cmode4/brightness
                echo 0 > /sys/class/leds/hc:blue:sig1/brightness
                echo 0 > /sys/class/leds/hc:blue:sig2/brightness
                echo 0 > /sys/class/leds/hc:blue:sig3/brightness
                echo 1 > /sys/class/leds/hc:blue:int/brightness
            fi
            
        elif echo "$modconf" | grep -q "MT5700"; then
            network_mode=$(atsd_tools_cli -i cpe -c 'AT^HCSQ?')
            OUTPUT=$(atsd_tools_cli -i cpe -c 'AT^MONSC' | sed -n '2p')
            # 检查输出是否包含NR（即网络类型为NR）
            echo $OUTPUT | grep 'NR' &> /dev/null
            if [ $? -ne 0 ]; then
                echo $OUTPUT | grep 'LTE' &> /dev/null
                if [ $? -ne 0 ]; then
                    echo 0 > /sys/class/leds/hc:blue:cmode5/brightness
                    echo 0 > /sys/class/leds/hc:blue:cmode4/brightness
                    echo 0 > /sys/class/leds/hc:blue:sig1/brightness
                    echo 0 > /sys/class/leds/hc:blue:sig2/brightness
                    echo 0 > /sys/class/leds/hc:blue:sig3/brightness
                    echo 1 > /sys/class/leds/hc:blue:int/brightness
                    continue
                else
                    #LTE 4G解析数据
                    RSRQ=$(echo $OUTPUT | cut -d ',' -f9)
                    RSRQ=$(echo $OUTPUT | cut -d ',' -f9 | sed 's/[^-.0-9]//g')
                    # 根据 RSRQ 的值设置 CSQ_PER
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
                fi
            else
                RSRQ=$(echo $OUTPUT | cut -d ',' -f10)
                RSRQ=$(echo $OUTPUT | cut -d ',' -f10 | sed 's/[^-.0-9]//g')
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
            fi
        # 判断网络模式并更新LED状态
        if echo "$network_mode" | grep -Eq "5G|NR"; then
            # 包含TDD，点亮hc:blue:cmode5，熄灭hc:blue:cmode4
            echo 1 > /sys/class/leds/hc:blue:cmode5/brightness
            echo 0 > /sys/class/leds/hc:blue:cmode4/brightness
            echo 0 > /sys/class/leds/hc:blue:int/brightness
        elif echo "$network_mode" | grep -q "LTE"; then
            # 包含LTE，点亮hc:blue:cmode4，熄灭hc:blue:cmode5
            echo 1 > /sys/class/leds/hc:blue:cmode4/brightness
            echo 0 > /sys/class/leds/hc:blue:cmode5/brightness
            echo 0 > /sys/class/leds/hc:blue:int/brightness
        else
            # 其他网络，熄灭hc:blue:cmode5和hc:blue:cmode4
            echo 0 > /sys/class/leds/hc:blue:cmode5/brightness
            echo 0 > /sys/class/leds/hc:blue:cmode4/brightness
            echo 0 > /sys/class/leds/hc:blue:sig1/brightness
            echo 0 > /sys/class/leds/hc:blue:sig2/brightness
            echo 0 > /sys/class/leds/hc:blue:sig3/brightness
            echo 1 > /sys/class/leds/hc:blue:int/brightness
        fi
        sleep 10
    fi
    # 等待10秒
  fi
done

# 释放锁
flock -u 200

