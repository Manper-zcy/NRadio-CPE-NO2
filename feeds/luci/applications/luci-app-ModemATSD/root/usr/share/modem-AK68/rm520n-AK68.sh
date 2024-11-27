    #!/bin/sh
    #By Zy143L
    #Icey:add module test function
    #rebiuld for C8 NO2\NB68 by Manper 20241028
    FILE134="/tmp/modconf-AK68.conf"
    if [ ! -f "$FILE134" ]; then
    	echo "文件不存在: $FILE134"
        exit 0
    fi
    # 检查文件是否包含字符串 "RM520N"
    if grep -q "RM520N" "$FILE134"; then
        echo ""
    else
        exit 1
    fi
    echo "AK68套件SIM卡初始化..." >/tmp/simcardstat-AK68
    PROGRAM="RM520N_MODEM"
    printMsg() {
        local msg="$1"
        logger -t "${PROGRAM}" "${msg}"
    } #日志输出调用API

    # 检查是否存在锁文件 @Icey
    lock_file="/tmp/rm520n-AK68.lock"

    if [ -e "$lock_file" ]; then
    # 锁文件存在，获取锁定的进程 ID，并终止它
    locked_pid=$(cat "$lock_file")
    if [ -n "$locked_pid" ]; then
        echo "Terminating existing rm520n.sh process (PID: $locked_pid)" 
        kill "$locked_pid"
        sleep 2  # 等待一段时间确保进程终止
    fi
    fi

    ipcheckLOCKFILE="/tmp/ipcheck-AK68.lock"
    if [ -e "$ipcheckLOCKFILE" ]; then
    # 锁文件存在，获取锁定的进程 ID，并终止它
    ipcheckLOCKFILElocked_pid=$(cat "$ipcheckLOCKFILE")
    if [ -n "$ipcheckLOCKFILElocked_pid" ]; then
        printMsg "Terminating existing ipcheck.sh process (PID: $ipcheckLOCKFILElocked_pid)" 
        kill "$ipcheckLOCKFILElocked_pid"
        sleep 2  # 等待一段时间确保进程终止
    fi
    fi


    # 创建新的锁文件，记录当前进程 ID
    echo "$$" > "$lock_file"
    sleep 2 && /sbin/uci commit
    Modem_Enable=`uci -q get modem-AK68.@ndis[0].enable` || Modem_Enable=1
    #模块启动
    #模块开关
    if [ "$Modem_Enable" == 0 ]; then
        echo 0 >/sys/class/gpio/cpe-pwr/value
        printMsg "禁用模块，退出"
        rm $lock_file
        exit 0
    else
        printMsg "模块启用"
        echo 1 >/sys/class/gpio/cpe-pwr/value
         #预先开内置卡
        echo 1 > /sys/class/gpio/cpe-sel0/value
    fi

    Sim_Sel=`uci -q get modem-AK68.@ndis[0].simsel`|| Sim_Sel=0
    echo "simsel: $Sim_Sel" >> /tmp/moduleInit-AK68
    #SIM选择

    Enable_IMEI=`uci -q get modem-AK68.@ndis[0].enable_imei` || Enable_IMEI=0
    #IMEI修改开关

    RF_Mode=`uci -q get modem-AK68.@ndis[0].smode` || RF_Mode=0
    #网络制式 0: Auto, 1: 4G, 2: 5G
    NR_Mode=`uci -q get modem-AK68.@ndis[0].nrmode` || NR_Mode=0
    #0: Auto, 1: SA, 2: NSA
    Band_LTE=`uci -q get modem-AK68.@ndis[0].bandlist_lte` || Band_LTE=0
    Band_SA=`uci -q get modem-AK68.@ndis[0].bandlist_sa` || Band_SA=0
    Band_NSA=`uci -q get modem-AK68.@ndis[0].bandlist_nsa` || Band_NSA=0
    Enable_PING=`uci -q get modem-AK68.@ndis[0].pingen` || Enable_PING=0
    PING_Addr=`uci -q get modem-AK68.@ndis[0].pingaddr` || PING_Addr="119.29.29.29"
    PING_Count=`uci -q get modem-AK68.@ndis[0].count` || PING_Count=10
    #FCN CI LOCK
    Earfcn=`uci -q get modem-AK68.@ndis[0].earfcn` || Earfcn=0
    Cellid=` uci -q get modem-AK68.@ndis[0].cellid` || Cellid=0
    Freqlock=` uci -q get modem-AK68.@ndis[0].freqlock` || Freqlock=0

    if [ ${Enable_PING} == 1 ];then
        /usr/share/modem-AK68/pingCheck-AK68.sh &
    else 
        process=`ps -ef | grep "pingCheck" | grep -v grep | awk '{print $1}'` 
        if [[ -n "$process" ]]; then
            kill -9 "$process" >/dev/null 2>&1
        fi
        rm -rf /tmp/pingCheck-AK68.lock
    fi

     #-----------------SIM Card switch
     #attention！ims enable and autosel enable will make some card work under 4G network
        case "$Sim_Sel" in
            0)
                printMsg "外置SIM卡"
                atsd_tools_cli -i cpe -c "AT+QUIMSLOT=1"
                #atsd_tools_cli -i cpe -c "AT+QUIMSLOT=1"
                echo 1 > /etc/simsel-AK68
                sleep 2
                atsd_tools_cli -i cpe -c "AT+QCFG="ims",1"
                #atsd_tools_cli -i cpe -c 'AT+QCFG="ims",1'
                atsd_tools_cli -i cpe -c "AT+QMBNCFG="autosel",1"
                #atsd_tools_cli -i cpe -c 'AT+QMBNCFG="autosel",1' 
                echo "外置SIM卡" >> /tmp/moduleInit-AK68
                echo 0 > /tmp/sim_sel-AK68
            ;;
            1)
                printMsg "内置SIM1"
                echo 1 > /sys/class/gpio/cpe-sel0/value
                atsd_tools_cli -i cpe -c "AT+QUIMSLOT=2"
                #atsd_tools_cli -i cpe -c "AT+QUIMSLOT=2"
                echo 2 > /etc/simsel-AK68
                sleep 2
                atsd_tools_cli -i cpe -c "AT+QCFG="ims",0"
                #atsd_tools_cli -i cpe -c 'AT+QCFG="ims",0'
                atsd_tools_cli -i cpe -c "AT+QMBNCFG="autosel",0"
                #atsd_tools_cli -i cpe -c 'AT+QMBNCFG="autosel",0' 
                echo "内置SIM卡1" >> /tmp/moduleInit-AK68
                echo 1 > /tmp/sim_sel-AK68
            ;;
            2)
                printMsg "内置SIM2"
                echo 0 > /sys/class/gpio/cpe-sel0/value
                atsd_tools_cli -i cpe -c "AT+QUIMSLOT=2"
                #atsd_tools_cli -i cpe -c "AT+QUIMSLOT=2"
                echo 2 > /etc/simsel-AK68
                sleep 2
                atsd_tools_cli -i cpe -c "AT+QCFG="ims",0"
                #atsd_tools_cli -i cpe -c 'AT+QCFG="ims",0'
                atsd_tools_cli -i cpe -c "AT+QMBNCFG="autosel",0"
                #atsd_tools_cli -i cpe -c 'AT+QMBNCFG="autosel",0' 
                echo "内置SIM卡2" >> /tmp/moduleInit-AK68
                echo 2 > /tmp/sim_sel-AK68
            ;;
            *)
                printMsg "错误状态"
                atsd_tools_cli -i cpe -c "AT+QUIMSLOT=1"
                #atsd_tools_cli -i cpe -c "AT+QUIMSLOT=1"
                sleep 2
                echo 3 > /tmp/Sim_Sel-AK68
                echo "SIM状态错误" >> /tmp/moduleInit-AK68
            ;;
            esac

    #IPV6 support chk
    enable_native_ipv6_flag=$(uci get modem.@ndis[0].enable_native_ipv6) || enable_native_ipv6_flag=0
    if [ "$enable_native_ipv6_flag" -eq 1 ]; then
        echo "正在初始化，请稍后刷新查看状态" >/tmp/ipv6prefix-AK68
    fi

    if [ ${Enable_IMEI} == 1 ];then
        IMEI_file="/tmp/IMEI"
        if [ -e "$IMEI_file" ]; then
            last_IMEI=$(cat "$IMEI_file")
        else
            last_IMEI=-1
        fi
        IMEI=`uci -q get modem.@ndis[0].modify_imei`
        if [ "$IMEI" != "$last_IMEI" ]; then
            /usr/share/modem-AK68/moimei-AK68 ${IMEI} 1>/dev/null 2>&1
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
            atsd_tools_cli -i cpe -c 'AT+QNWPREFCFG="mode_pref",AUTO' >> /tmp/moduleInit-AK68
            #atsd_tools_cli -i cpe -c 'AT+QNWPREFCFG="mode_pref",AUTO' >> /tmp/moduleInit
        elif [ "$RF_Mode" == 1 ]; then
            echo "RF_Mode: $RF_Mode 4G网络" >> /tmp/moduleInit-AK68
            atsd_tools_cli -i cpe -c 'AT+QNWPREFCFG="mode_pref",LTE' >> /tmp/moduleInit-AK68
            #atsd_tools_cli -i cpe -c 'AT+QNWPREFCFG="mode_pref",LTE' >> /tmp/moduleInit
        elif [ "$RF_Mode" = 2 ]; then
            echo "RF_Mode: $RF_Mode 5G网络" >> /tmp/moduleInit-AK68
            atsd_tools_cli -i cpe -c 'AT+QNWPREFCFG="mode_pref",NR5G' >> /tmp/moduleInit-AK68
            #atsd_tools_cli -i cpe -c 'AT+QNWPREFCFG="mode_pref",NR5G' >> /tmp/moduleInit
        fi
        echo "$RF_Mode" > "$RF_Mode_file"
    else
        echo "RF_Mode未变动, 不执行操作" >> /tmp/moduleInit-AK68
    fi
    #-------------------------

    # LTE锁频
    #-------------------------
    Band_LTE_file="/tmp/Band_LTE-AK68"
    if [ -e "$Band_LTE_file" ]; then
        last_Band_LTE=$(cat "$Band_LTE_file")
    else
        last_Band_LTE=-1
    fi
    #--
    if [ "$Band_LTE" != "$last_Band_LTE" ]; then
        if [ "$Band_LTE" == 0 ]; then
            sendat_command='AT+QNWPREFCFG="lte_band",1:3:5:8:34:38:39:40:41'
            sendat_result=$( atsd_tools_cli -i cpe -c $sendat_command)
            echo "LTE自动: $sendat_result" >> /tmp/moduleInit-AK68
        else
            sendat_command="AT+QNWPREFCFG=\"lte_band\",$Band_LTE"
            sendat_result=$( atsd_tools_cli -i cpe -c $sendat_command)
            echo "LTE锁频: $sendat_result" >> /tmp/moduleInit-AK68
        fi
        echo "$Band_LTE" > "$Band_LTE_file"
    else
        echo "Band_LTE未变动, 不执行操作" >> /tmp/moduleInit-AK68
    fi
    #----------------------

    # SA/NSA模式切换
    #----------------------
    NR_Mode_file="/tmp/NR_Mode-AK68"
    if [ -e "$NR_Mode_file" ]; then
        last_NR_Mode=$(cat "$NR_Mode_file")
    else
        last_NR_Mode=-1
    fi
    #--
    if [ "$NR_Mode" != "$last_NR_Mode" ]; then
        if [ "$NR_Mode" == 0 ]; then
            echo "NR_Mode: $NR_Mode 自动网络" >> /tmp/moduleInit
            atsd_tools_cli -i cpe -c 'AT+QNWPREFCFG="nr5g_disable_mode",0' >> /tmp/moduleInit-AK68
            #atsd_tools_cli -i cpe -c 'AT+QNWPREFCFG="nr5g_disable_mode",0' >> /tmp/moduleInit
        elif [ "$NR_Mode" = 1 ]; then
            echo "NR_Mode: $NR_Mode SA网络" >> /tmp/moduleInit
            atsd_tools_cli -i cpe -c 'AT+QNWPREFCFG="nr5g_disable_mode",2' >> /tmp/moduleInit-AK68
            #atsd_tools_cli -i cpe -c 'AT+QNWPREFCFG="nr5g_disable_mode",2' >> /tmp/moduleInit
        elif [ "$NR_Mode" = 2 ]; then
            echo "NR_Mode: $NR_Mode NSA网络" >> /tmp/moduleInit
            atsd_tools_cli -i cpe -c 'AT+QNWPREFCFG="nr5g_disable_mode",1' >> /tmp/moduleInit-AK68
            #atsd_tools_cli -i cpe -c 'AT+QNWPREFCFG="nr5g_disable_mode",1' >> /tmp/moduleInit
        fi
        echo "$NR_Mode" > "$NR_Mode_file"
    else
        echo "NR_Mode未变动, 不执行操作" >> /tmp/moduleInit-AK68
    fi
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
            sendat_command='AT+QNWPREFCFG="nr5g_band",1:3:8:28:41:78:79'
            sendat_result=$(atsd_tools_cli -i cpe -c $sendat_command)
            #sendat_result=$(atsd_tools_cli -i cpe -c "$sendat_command")
            echo "SA自动: $sendat_result" >> /tmp/moduleInit-AK68
        else
            sendat_command="AT+QNWPREFCFG=\"nr5g_band\",$Band_SA"
            sendat_result=$(atsd_tools_cli -i cpe -c $sendat_command)
            #sendat_result=$(atsd_tools_cli -i cpe -c "$sendat_command")
            echo "SA锁频: $sendat_result" >> /tmp/moduleInit-AK68
        fi
        echo "$Band_SA" > "$band_sa_file"
    else
        echo "Band_SA未变动, 不执行操作" >> /tmp/moduleInit-AK68
    fi
    #-------------------

    # NSA锁频
    #-------------------
    band_nsa_file="/tmp/Band_NSA-AK68"
    if [ -e "$band_nsa_file" ]; then
        last_Band_NSA=$(cat "$band_nsa_file")
    else
        last_Band_NSA=-1
    fi

    if [ "$Band_NSA" != "$last_Band_NSA" ]; then
        if [ "$Band_NSA" == 0 ]; then
            sendat_command='AT+QNWPREFCFG="nsa_nr5g_band",41:78:79'
            sendat_result=$(atsd_tools_cli -i cpe -c $sendat_command)
            #sendat_result=$(atsd_tools_cli -i cpe -c "$sendat_command")
            echo "NSA自动: $sendat_result" >> /tmp/moduleInit-AK68
            echo 0 > /tmp/Band_NSA-AK68
        else
            sendat_command="AT+QNWPREFCFG=\"nsa_nr5g_band\",$Band_SA"
            sendat_result=$(atsd_tools_cli -i cpe -c $sendat_command)
            #sendat_result=$(atsd_tools_cli -i cpe -c "$sendat_command")
            echo "NSA锁频: $sendat_result" >> /tmp/moduleInit-AK68
            echo 1 > /tmp/Band_NSA-AK68
        fi
        echo "$Band_NSA" > "$band_nsa_file"
    else
        echo "Band_NSA未变动, 不执行操作" >> /tmp/moduleInit-AK68
    fi

    #数据漫游
    if [ -n "$Dataroaming" ] && [ "$Dataroaming" = "1" ]; then
        atsd_tools_cli -i cpe -c 'AT+QNWCFG="data_roaming",0'
        #atsd_tools_cli -i cpe -c 'AT+QNWCFG="data_roaming",0'
        printMsg "DataRoaming Enable"
    else
        atsd_tools_cli -i cpe -c 'AT+QNWCFG="data_roaming",1'
        #atsd_tools_cli -i cpe -c 'AT+QNWCFG="data_roaming",1'
        printMsg "DataRoaming Disable"
    fi


    #锁定频率
    #------------------------@Icey
    unlock() {
        printMsg "Unlock Band"
        atsd_tools_cli -i cpe -c 'at+qnwlock="common/5g",0'
        sleep 2
        atsd_tools_cli -i cpe -c 'at+qnwlock="common/4g",0'
        sleep 2
        return 0
    }

    band_lock() {
        printMsg "Start Band Lock"
        if [ "$Freqlock" -eq 0 ]; then
            if [ ! -e "/tmp/freq-AK68.run" ]; then
                printMsg "Restore band lock at boot"
                unlock
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
                        atsd_tools_cli -i cpe -c "at+qnwlock=\"common/4g\",1,$Cellid,$Earfcn"
                        sleep 3
                        atsd_tools_cli -i cpe -c 'at+qnwlock="save_ctrl",1,1'
                    else
                        unlock
                    fi
                    ;;
                2)
                    if [ "$NR_Mode" -ne 0 ] && [ "$Band_SA" -ne 0 -o "$Band_NSA" -ne 0 ] && [ "$Earfcn" -ne 0 ] && [ "$Cellid" -ne 0 ]; then
                            case "$Band_SA" in
                                1|2|3|5|7|8|12|20|25|28|66|71|75|76)
                                    scs=15
                                    ;;
                                38|40|41|48|77|78|79)
                                    scs=30
                                    ;;
                                257|258|260|261)
                                    scs=120
                                    ;;
                                *)
                                    printMsg "BANDLOCKFAILURE"
                                    return 0
                                    ;;
                            esac
                        printMsg "BAND LOCK AT COMMON5G $Cellid,$Earfcn,$scs,$Band_SA"
                        atsd_tools_cli -i cpe -c "at+qnwlock=\"common/5g\",$Cellid,$Earfcn,$scs,$Band_SA"
                        sleep 3
                        atsd_tools_cli -i cpe -c 'at+qnwlock="save_ctrl",1,1'
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
        simStat=$(atsd_tools_cli -i cpe -c 'at+qsimstat?' | grep '+QSIMSTAT' | awk -F, '{print $2}'| tr -d '\r\n')
        case $simStat in
            1)
                printMsg "SIM card is inserted."
                echo "SIM卡已插入" > /tmp/simcardstat-AK68
                #APN CONFiG 
                apnconfig=`uci -q get modem.@ndis[0].apnconfig` || apnconfig=""
                #如果不设置就配自动apn
                if [[ -z $apnconfig ]] ; then
                    while_i=0
                    while [ $while_i -le 5 ]
                    do
                        ispname=$(atsd_tools_cli -i cpe -c  'AT+QSPN' | sed -n '2p' | cut -d, -f1)
                        if echo "$ispname" | grep -qwi "+QSPN" ; then
                            break
                        fi
                        let while_i++
                        sleep 1
                    done
                    if echo "$ispname" | grep -qwi "UNICOM" ; then
                    printMsg "中国联通"
                    apnconfig='3gnet'
                    fi
                    if echo "$ispname" | grep -qwi "MOBILE" || echo "$ispname" | grep -qwi "4E2D56FD79FB52A8"; then
                    printMsg "中国移动"
                    apnconfig='CMNET'
                    fi
                    if echo "$ispname" | grep -qwi "CHN-CT" ; then
                    printMsg "中国电信"
                    apnconfig='ctnet'
                    fi
                    if echo "$ispname" | grep -qwi "BROADNET" ; then
                    printMsg "中国广电"
                    apnconfig='cbnet'
                    fi
                fi
                sendat_result=$(atsd_tools_cli -i cpe -c  'AT+CGDCONT=1,"IPV4V6","'$apnconfig'"')
                return 0
                ;;
            0)
                printMsg "SIM card is not inserted. Exiting program."
                echo "SIM卡未插入" > /tmp/simcardstat-AK68
                exit 0
                ;;
            *)
                printMsg "Unknown SIM card Insert status. Sleep 10，Retrying..."
                sleep 3
                chkSimExt
                ;;
        esac
    }
    #Check if SIM Ready to use

    chkSimReady() {
        chkSimReadyMAX_RETRIES=30
        local simReady=$(atsd_tools_cli -i cpe -c "at+qinistat" | grep '+QINISTAT' | awk '{print $2}' | tr -d '\r\n')
        while [ $moduleSetChkMAX_RETRIES -gt 0 ]; do
            case $simReady in
                7)
                    printMsg "SIM card is ready."
                    return 0
                    ;;
                *)
                        printMsg "Unknown SIM card Init status. Retrying..."
                        chkSimReadyMAX_RETRIES=$((chkSimReadyMAX_RETRIES - 1))
                        sleep 2
                    ;;
            esac
        done
    }


    #Check Module Hardware Set,pre check befroe everything
    moduleSetChk(){
        macchk=0
        moduleSetChkMAX_RETRIES=5
        printMsg "Start Modem Hardware Check"
        atsd_tools_cli -i cpe -c 'at+qeth="rgmii","enable",1'
        #atsd_tools_cli -i cpe -c 'at+qeth="rgmii","enable",1"'
        while [ $macchk -lt 30 ]; do
            mac_address=$(ifconfig | grep eth1 | awk '{print $5}' | tr -d '\r\n')

            case "$mac_address" in
            *:*:*:*:*:*)
                printMsg "WAN MAC $mac_address"
                success=true
                break
                ;;
            *)
                sleep 1
                macchk=$((macchk + 1))
                if [ $macchk -eq 30 ]; then
                    printMsg "获取WAN MAC失败!!"
                    exit 1
                fi
                ;;
            esac
        done

        while [ $moduleSetChkMAX_RETRIES -gt 0 ]; do
        success=true
        
        dataInterfaceChk=$(atsd_tools_cli -i cpe -c 'AT+QCFG="data_interface"' | grep '+QCFG:'|awk -F \" {'print $3'}|tr -d '\r\n')
            printMsg "dataInterfaceChk: $dataInterfaceChk"
            if [ "$dataInterfaceChk" != ",1,0" ]; then
                printMsg "dataInterfaceChk Status check failed."
                atsd_tools_cli -i cpe -c 'AT+QCFG="data_interface",1,0'
                printMsg "Maybe need to reboot"
                echo "模块数据接口模式变更或模块异常，如果没网，请手动断电后重启" >/tmp/simcardstat-AK68
                exit
                success=false
                #todo
            fi
            pcieStat=$(atsd_tools_cli -i cpe -c 'AT+QCFG="pcie/mode"' | grep '+QCFG' | awk -F, '{print $2}' | tr -d '\r\n')
            printMsg "PCIe Status: $pcieStat"
            if [ "$pcieStat" != "1" ]; then
                printMsg "PCIe Status check failed."
                atsd_tools_cli -i cpe -c 'AT+QCFG="pcie/mode",1'
                success=false
                #todo
            fi

            ethR8125Stat=$(atsd_tools_cli -i cpe -c 'at+qeth="eth_driver"' | grep '"r8125",1'|awk -F , {'print $3'}|tr -d '\r\n')
            printMsg "ethR8125Stat Status: $ethR8125Stat"
            if [ "$ethR8125Stat" != "1" ]; then
                printMsg "ethR8125Stat Status check failed."
                atsd_tools_cli -i cpe -c 'AT+QETH="eth_driver","r8125",1'
                success=false
            fi

            mpdnruleStat=$(atsd_tools_cli -i cpe -c 'at+qmap="mpdn_rule"' | grep '+QMAP: "MPDN_rule",0,1,0,1,1' | tr -d '\r\n')
            printMsg "mpdnruleStat Status: $mpdnruleStat"
            if ! echo "$mpdnruleStat" | grep -q "0,1,0,1,1"; then
                printMsg "mpdnruleStat Status check failed."
                atsd_tools_cli -i cpe -c 'at+qmap="mpdn_rule",0'
                sleep 5
                atsd_tools_cli -i cpe -c 'AT+QMAP="mpdn_rule",0,1,0,1,1,"FF:FF:FF:FF:FF:FF"'
                sleep 8
                success=false
            fi

            cmgfStat=$( atsd_tools_cli -i cpe -c "at+cmgf?" | grep '+CMGF'|awk -F : {'print $2'}|tr -d '\r\n')
            printMsg "cmgfStat Status: $cmgfStat"
            if [ "$cmgfStat" != " 0" ]; then
                printMsg "cmgfStat Status check failed."
                atsd_tools_cli -i cpe -c "at+cmgf=0"
                success=false
            fi


            if [ "$success" = false ]; then
                    moduleSetChkMAX_RETRIES=$(($moduleSetChkMAX_RETRIES - 1))
                    printMsg "Recheck Hardware Set...."
                    sleep 2
            else
                printMsg "Hardware Check Complete."
                return 0
            fi
            
        done

    }

    sim_pin_chk() {
        sim_card_pin_status=$(atsd_tools_cli -i cpe -c 'at+cpin?' |grep '+CPIN:'|awk -F ':' {'print $2'}|tr -d ' \r\n')
        pincode=$(uci get modem.@ndis[0].pincode)
        case "$sim_card_pin_status" in
            "READY")
                printMsg "SIM card is ready."
                echo "SIM卡已正常工作">/tmp/simcardstat-AK68
                return 0
                ;;
            "SIMPIN"|"SIMPIN2")
                if echo "$pincode" | grep -qE '^[0-9]+$'; then
                    atsd_tools_cli -i cpe -c "at+cpin=\"$pincode\""
                    sim_card_pin_status=$(atsd_tools_cli -i cpe -c 'at+cpin?' |grep '+CPIN:'|awk -F ':' {'print $2'}|tr -d ' \r\n')
                    if [ "$sim_card_pin_status" != "READY" ]; then
                        printMsg "Failed to unlock SIM card with PIN."
                        echo "SIM PIN错误，请注意，多次错误将会导致锁卡">/tmp/simcardstat-AK68
                        exit 1
                    else
                        printMsg "SIM card is ready."
                        echo "SIM卡已正常工作">/tmp/simcardstat-AK68
                        sleep 1
                        return 0
                    fi
                else
                    printMsg "Invalid PIN code."
                    echo "需要PIN。PIN不存在或者错误！">/tmp/simcardstat-AK68
                    exit 1
                fi
                ;;
            "SIMPUK"|"SIMPUK2")
                printMsg "SIM card requires PUK."
                echo "SIM卡已锁，请在其他设备上插入此卡输入PUK解锁">/tmp/simcardstat-AK68
                exit 1
                ;;
            *)
                printMsg "Unknown SIM card status."
                echo "SIM卡状态异常">/tmp/simcardstat-AK68
                exit 1
                ;;
        esac
    }


    moduleStartCheckLine(){
        sleep 15  #Must wait 15 seconds for sim init itself 
        chkSimExt
        sim_pin_chk
        echo "chkSimExt $?" 
        chkSimReady
        echo "chkSimReady $?" 
        moduleSetChk
        band_lock
        echo "moduleSetChk $?" 
        check_and_activate_wan
    }


    #start
    moduleStartCheckLine
    exit
