#!/bin/sh
#rebiuld for C8 NO2\NB68 by Manper 20241028
#By Manper MT5700
LOCKFILE="/tmp/MT5700-AK68.lock"
{
    flock -n 200 || {
        echo "脚本已经运行..."
        exit 1
    }
    echo "Script is running..."
    trap cleanup INT TERM EXIT
    FILE135="/tmp/modconf-AK68.conf"
    if [ ! -f "$FILE135" ]; then
    	echo "文件不存在: $FILE135"
        exit 0
    fi
    # 检查文件是否包含字符串 "MT5700"
    if grep -q "MT5700" "$FILE135"; then
        echo ""
    else
        exit 1
    fi
    echo "AK68-巴龙MT5700套件SIM卡初始化..." >/tmp/simcardstat-AK68

    PROGRAM="MT5700_MODEM"
    printMsg() {
        local msg="$1"
        logger -t "${PROGRAM}" "${msg}"
    } #日志输出调用API
    printMsg "AK68-巴龙MT5700套件SIM卡初始化..."
    Modem_Enable=`uci -q get modem-AK68.@ndis[0].enable` || Modem_Enable=1
    #模块启动
    #模块开关
    if [ "$Modem_Enable" == 0 ]; then
        printMsg "禁用模块"
        exit 0
    else
        printMsg "模块启用"
    fi

    sleep 10
    Sim_Sel=`uci -q get modem-AK68.@ndis[0].simsel`|| Sim_Sel=0
    echo "0" >> /tmp/sim_sel_AK68
    echo "simsel: $Sim_Sel" >> /tmp/moduleInit-AK68
    echo "simsel: $Sim_Sel"
    #SIM选择
    Enable_IMEI=`uci -q get modem-AK68.@ndis[0].enable_imei` || Enable_IMEI=0
    echo "Enable_IMEI $Enable_IMEI"
    #IMEI修改开关
    RF_Mode=`uci -q get modem-AK68.@ndis[0].smode` || RF_Mode=0
    echo "RF_Mode $RF_Mode"
    #网络制式 0: Auto, 1: 4G, 2: 5G
    NR_Mode=`uci -q get modem-AK68.@ndis[0].nrmode` || NR_Mode=0
    echo "NR_Mode $NR_Mode"
    #0: Auto, 1: SA, 2: NSA
    Band_LTE=`uci -q get modem-AK68.@ndis[0].bandlist_lte` || Band_LTE=0
    echo "Band_LTE $Band_LT"
    Band_SA=`uci -q get modem-AK68.@ndis[0].bandlist_sa` || Band_SA=0
    echo "Band_SA $Band_SA"
    Band_NSA=`uci -q get modem-AK68.@ndis[0].bandlist_nsa` || Band_NSA=0
    echo "Band_NSA $Band_NSA"
    #FCN CI LOCK
    Earfcn=`uci -q get modem-AK68.@ndis[0].earfcn` || Earfcn=0
    echo "Earfcn $Earfcn"
    Cellid=` uci -q get modem-AK68.@ndis[0].cellid` || Cellid=0
    echo "Cellid $Cellid"
    #-----------------SIM Card switch
    #attention！ims enable and autosel enable will make some card work under 4G network

    case "$Sim_Sel" in
        0)
            printMsg "外置SIM卡"
            atsd_tools_cli -i cpe -c 'AT^SCICHG=0,1'
            atsd_tools_cli -i cpe -c 'AT^HVSST=1,0'
            sleep 3
            atsd_tools_cli -i cpe -c 'AT^HVSST=1,1'
            echo "外置SIM卡1" >> /tmp/moduleInit-AK68
            echo "外置SIM卡1切换完成"
            echo "SIN卡UCI标识：$Sim_Sel"
            echo 0 > /tmp/sim_sel_AK68
        ;;
        1)
            printMsg "内置SIM卡"
            atsd_tools_cli -i cpe -c 'AT^SCICHG=1,0'
            atsd_tools_cli -i cpe -c 'AT^HVSST=1,0'
            sleep 3
            atsd_tools_cli -i cpe -c 'AT^HVSST=1,1'
            echo "内置SIM卡1" >> /tmp/moduleInit-AK68
            echo "内置SIM卡1切换完成"
            echo "SIN卡UCI标识：$Sim_Sel"
            echo 1 > /tmp/sim_sel_AK68
        ;;
        *)
            atsd_tools_cli -i cpe -c 'AT^SCICHG=0,1'
            atsd_tools_cli -i cpe -c 'AT^HVSST=1,0'
            sleep 3
            atsd_tools_cli -i cpe -c 'AT^HVSST=1,1'
            printMsg "卡槽错误状态"
            echo 6 > /tmp/sim_sel_AK68
            echo "卡槽未识别" >> /tmp/moduleInit-AK68
        ;;
        esac

   #MT5700-IMEI
    if [ ${Enable_IMEI} == 1 ];then
        IMEI_file="/tmp/IMEI-AK68"
        if [ -e "$IMEI_file" ]; then
            last_IMEI=$(cat "$IMEI_file")
        else
            last_IMEI=-1
        fi
        IMEI=`uci -q get modem-AK68.@ndis[0].modify_imei`
        if [ "$IMEI" != "$last_IMEI" ]; then
            atsd_tools_cli -i cpe -c "AT^PHYNUM=IMEI,$IMEI" >> /tmp/moduleInit-AK68
            printMsg "IMEI: ${IMEI}"
            echo "修改IMEI $IMEI" >> /tmp/moduleInit-AK68
            echo "$IMEI" > "$IMEI_file"
        else
            echo "IMEI未变动, 不执行操作" >> /tmp/moduleInit-AK68
        fi
    fi
    # 网络模式选择
    #---------------------------------
    RF_Mode_file="/tmp/RF_Mode-AK68"
    if [ -e "$RF_Mode_file" ]; then
        last_RF_Mode=$(cat "$RF_Mode_file")
    else
        last_RF_Mode=-1
    fi
    #--
    if [ "$RF_Mode" != "$last_RF_Mode" ]; then
        if [ "$RF_Mode" == 0 ]; then
            echo "RF_Mode: $RF_Mode 自动网络" >> /tmp/moduleInit-AK68
            atsd_tools_cli -i cpe -c 'AT^SYSCFGEX="080302",2000000680380,1,2,1E200000095,,' >> /tmp/moduleInit-AK68
            echo "RF_Mode: $RF_Mode 4G网络"
        elif [ "$RF_Mode" == 1 ]; then
            echo "RF_Mode: $RF_Mode 4G网络" >> /tmp/moduleInit-AK68
            atsd_tools_cli -i cpe -c 'AT^SYSCFGEX="03",2000000680380,1,2,1E200000095,,' >> /tmp/moduleInit-AK68
            echo "RF_Mode: $RF_Mode 4G网络"
        elif [ "$RF_Mode" = 2 ]; then
            echo "RF_Mode: $RF_Mode 5G网络" >> /tmp/moduleInit-AK68
            atsd_tools_cli -i cpe -c 'AT^SYSCFGEX="08",2000000680380,1,2,1E200000095,,' >> /tmp/moduleInit-AK68
            echo "RF_Mode: $RF_Mode 4G网络"
        fi
        echo "$RF_Mode" > "$RF_Mode_file"
    else
        echo "RF_Mode未变动, 不执行操作" >> /tmp/moduleInit-AK68
    fi
    #-------------------------
 # LTE锁频
    #-------------------------
    if [ "$RF_Mode" == 1 ]; then

        Band_LTE_file="/tmp/Band_LTE-AK68"
        if [ -e "$Band_LTE_file" ]; then
            last_Band_LTE=$(cat "$Band_LTE_file")
        else
            last_Band_LTE=-1
        fi
        #--
        if [ "$Band_LTE" != "$last_Band_LTE" ]; then
            if [ "$Band_LTE" == 0 ]; then
                sendat_command='AT^SYSCFGEX="03",2000000680380,1,2,1E200000095,,'
                sendat_result=$(atsd_tools_cli -i cpe -c "$sendat_command")
                echo "LTE自动: $sendat_result" >> /tmp/moduleInit-AK68
            else
                sendat_command="AT^LTEFREQLOCK=3,1,1,\"$Band_LTE\""
                sendat_result=$(atsd_tools_cli -i cpe -c "$sendat_command")
                echo "LTE锁频: $sendat_result" >> /tmp/moduleInit-AK68
            fi
            echo "$Band_LTE" > "$Band_LTE_file"
        else
            echo "Band_LTE未变动, 不执行操作" >> /tmp/moduleInit-AK68
        fi
    fi
    #----------------------

    # SA/NSA模式切换
    #----------------------
    if [ "$RF_Mode" == 2 ]; then
        #----------------------
        # SA锁频
        #----------------------
        band_sa_file="/tmp/Band_SA-AK68"
        if [ -e "$band_sa_file" ]; then
            last_Band_SA=$(cat "$band_sa_file")
        else
            last_Band_SA=-1
        fi
        #--
        if [ "$Band_SA" != "$last_Band_SA" ]; then
            if [ "$Band_SA" == 0 ]; then
                sendat_command='AT^SYSCFGEX="08",2000000680380,1,2,1E200000095,,'
                sendat_result=$(atsd_tools_cli -i cpe -c "$sendat_command")
                echo "SA自动: $sendat_result" >> /tmp/moduleInit-AK68
            else
                sendat_command="AT^NRFREQLOCK=3,1,1,\"$Band_SA\""
                sendat_result=$(atsd_tools_cli -i cpe -c "$sendat_command")
                echo "SA锁频: $sendat_result" >> /tmp/moduleInit-AK68
            fi
            echo "$Band_SA" > "$band_sa_file"
        else
            echo "Band_SA未变动, 不执行操作" >> /tmp/moduleInit-AK68
        fi

    fi
    #-------------------
    #锁定频率
    unlock() {
        printMsg "Unlock Band"
        atsd_tools_cli -i cpe -c 'AT^LTEFREQLOCK=0'
        sleep 1
        atsd_tools_cli -i cpe -c 'AT^NRFREQLOCK=0'
        return 0
    }

    band_lock() {
        printMsg "Start Band Lock"
        if [ "$Freqlock" -eq 0 ]; then
            if [ ! -e "/tmp/freq-AK68.run" ]; then
                if [ "$Band_SA" == 0 ] && [ "$Band_LTE" == 0 ]; then
                    printMsg "Restore band lock at boot"
                    unlock
                fi
                return 0
            fi
            printMsg "Setting Will restore at next boot"
        fi 
            case "$RF_Mode" in
                0)
                    return 0
                    ;;
                1)
                    if [ "$Band_LTE" -ne 0 ] && [ "$Earfcn" -ne 0 ] && [ "$Cellid" -ne 0 ]; then
                        printMsg "BAND LOCK AT COMMON4G $Cellid,$Earfcn"
                        atsd_tools_cli -i cpe -c "AT^LTEFREQLOCK=2,0,1,\"$Band_LTE\",\"$Earfcn\",\"$Cellid\""
                        sleep 1
                    else
                        unlock
                    fi
                    ;;
                2)
                    if [ "$NR_Mode" -ne 0 ] && [ "$Band_SA" -ne 0 -o "$Band_NSA" -ne 0 ] && [ "$Earfcn" -ne 0 ] && [ "$Cellid" -ne 0 ]; then
                            case "$Band_SA" in
                                1|2|3|5|7|8|12|20|25|28|66|71|75|76)
                                    scs=0
                                    ;;
                                38|40|41|48|77|78|79)
                                    scs=1
                                    ;;
                                257|258|260|261)
                                    scs=2
                                    ;;
                                *)
                                    printMsg "BANDLOCKFAILURE"
                                    return 0
                                    ;;
                            esac
                        printMsg "BAND LOCK AT COMMON5G $Cellid,$Earfcn,$scs,$Band_SA"
                        atsd_tools_cli -i cpe -c "AT^NRFREQLOCK=2,0,1,\"$Band_SA\",\"$Earfcn\",\"$scs\",\"$Cellid\""
                        sleep 1
                    else
                        unlock
                    fi
                    ;;
                *)
                    printMsg "BANDLOCKFAILURE"
                    return 0
                    ;;
            esac
    }    

    #Check if SIM or esim exist
    chkSimExt() {
        sleep 5
        simStat=$(/usr/bin/atsd_tools_cli -i cpe -c 'AT^SIMSQ?' | awk '/^\^SIMSQ:/ {split($0, a, ","); print a[2]}'| tr -d '\r\n')
        echo "状态码：$simStat"
        sleep 5
        case $simStat in
            0)
                printMsg "SIM卡未插入."
                echo "SIM卡未插入" > /tmp/simcardstat-AK68
                echo "SIM卡未插入"
                printMsg "SIM卡未插入"
                ;;
            1)
                printMsg "SIM卡插入."
                echo "SIM卡已插入" > /tmp/simcardstat-AK68
                echo "SIM卡已插入"
                printMsg "SIM卡已插入"
                ;;
            2)
                echo "SIM卡被锁" > /tmp/simcardstat-AK68
                echo "SIM卡被锁"
                ;;
            3)
                echo "SIMLOCK 锁定(暂不支持上报)" > /tmp/simcardstat-AK68
                echo "SIMLOCK 锁定(暂不支持上报)"
                ;;
            10)
                echo "卡文件正在初始化 SIM Initializing" > /tmp/simcardstat-AK68
                ;;
            11)
                echo "卡初始化完成 （可接入网络）" > /tmp/simcardstat-AK68
                echo "卡初始化完成 （可接入网络）"
                printMsg "状态码11,卡初始化完成 （可接入网络）"
                ;;
            12)
                printMsg "SIM卡正常工作."
                echo "SIM卡正常工作" > /tmp/simcardstat-AK68
                echo "SIM卡正常工作"
                 printMsg "状态码12,SIM卡正常工作"
                ;;
            98)
                echo "卡物理失效 （PUK锁死或者卡物理失效）" > /tmp/simcardstat-AK68
                ;;
            99)
                echo "卡移除 SIM removed" > /tmp/simcardstat-AK68
                ;;
            Note2)
                echo "不支持虚拟SIM卡" > /tmp/simcardstat-AK68
                ;;
            100)
                echo "卡错误（初始化过程中，卡失败）" > /tmp/simcardstat-AK68
                ;;
            *)
                echo "未知SIM卡状态" > /tmp/simcardstat-AK68
                echo "未知SIM卡状态 状态码：$simStat"
                printMsg "未知SIM卡状态 状态码：$simStat"
                ;;
        esac
    }

    moduleStartCheckLine(){
        sleep 5 #Must wait 15 seconds for sim init itself 
        chkSimExt
        sim_pin_chk
        echo "chkSimExt $?" 
        moduleSetChk
        band_lock
        echo "moduleSetChk $?" 
    }

    #start
    moduleStartCheckLine
    exit
} 200>"$LOCKFILE"

