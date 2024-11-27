#!/bin/sh
#rebiuld for C8 NO2\NB68 by Manper 20241028
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
    Sim_Sel=`uci -q get modem-AK68.@ndis[0].simsel`|| Sim_Sel=0
    echo "0" >> /tmp/sim_sel-AK68
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


    #网络制式切换
    sleep 10
    echo "开始网络制式切换..."
    printMsg "开始网络制式切换..."
    if [ "$RF_Mode" == 0 ]; then
        /usr/bin/atsd_tools_cli -i cpe -c 'AT^SYSCFGEX="080302",2000000680380,1,2,1E200000095,,' >> /tmp/moduleInit-AK68
        sleep 1
        /usr/bin/atsd_tools_cli -i cpe -c "AT+CFUN=0"
        /usr/bin/atsd_tools_cli -i cpe -c "AT+CFUN=1"
        sleep 1
        echo "RF_Mode: $RF_Mode 自动网络" >> /tmp/moduleInit-AK68
        printMsg "RF_Mode: $RF_Mode 自动网络切换完成"
        echo "RF_Mode: $RF_Mode 自动网络切换完成"
    elif [ "$RF_Mode" == 1 ]; then
        /usr/bin/atsd_tools_cli -i cpe -c 'AT^SYSCFGEX="03",2000000680380,1,2,1E200000095,,' >> /tmp/moduleInit-AK68
        sleep 1
        /usr/bin/atsd_tools_cli -i cpe -c "AT+CFUN=0"
        /usr/bin/atsd_tools_cli -i cpe -c "AT+CFUN=1"
        sleep 1
        echo "RF_Mode: $RF_Mode 4G网络" >> /tmp/moduleInit-AK68
        printMsg "RF_Mode: $RF_Mode 4G网络切换完成"
        echo "RF_Mode: $RF_Mode 4G网络切换完成"
    elif [ "$RF_Mode" = 2 ]; then
        /usr/bin/atsd_tools_cli -i cpe -c 'AT^SYSCFGEX="08",2000000680380,1,2,1E200000095,,' >> /tmp/moduleInit-AK68
        sleep 1
        /usr/bin/atsd_tools_cli -i cpe -c "AT+CFUN=0"
        /usr/bin/atsd_tools_cli -i cpe -c "AT+CFUN=1"
        sleep 1
        #/usr/bin/atsd_tools_cli -i cpe -c 'AT^C5GOPTION=1,1,1'
        echo "RF_Mode: $RF_Mode 5G网络" >> /tmp/moduleInit-AK68
        printMsg "RF_Mode: $RF_Mode 5G网络切换完成"
        echo "RF_Mode: $RF_Mode 5G网络切换完成"
    fi

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
        echo "chkSimExt $?" 
        printMsg "MT5700完成执行！"
    }

    #start
    moduleStartCheckLine
    exit
} 200>"$LOCKFILE"