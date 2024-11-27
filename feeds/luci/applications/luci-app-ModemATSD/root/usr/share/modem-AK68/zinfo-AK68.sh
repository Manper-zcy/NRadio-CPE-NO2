#!/bin/sh 
LOCKFILE="/tmp/zinfos-AK68.lock"
{
    flock -n 200 || {
        echo "脚本已经运行..."
        exit 1
    }
    echo "Script is running..."

    trap cleanup INT TERM EXIT
    echo "running..."
    echo "running..." > /tmp/stsss.file
    echo "初始化TCP AT程序..." > /tmp/stsss.file
    echo "初始化TCP AT程序..."
    sleep 15
    #二次判断，避免获取信号状态和模块设置干扰
    waitrm520n=$(ps -fe|grep rm520n-AK68.sh |grep -v grep)
    if [ "$waitrm520n" != "" ]
    then
        if [ -e "/tmp/cpe_cell-AK68.file" ]; then
        sed -i '14,26 s/.*/Loading.../g' /tmp/cpe_cell-AK68.file  
        fi
        # Normal exit cleanup
        cleanup
    fi
    #3次判断，避免获取信号状态和基站扫描干扰
    waitCellScan=$(ps -fe|grep keyPairCellScan-AK68.sh |grep -v grep)
    if [ "$waitCellScan" != "" ]
    then
        # Normal exit cleanup
        cleanup
    fi

    FILE133="/tmp/modconf-AK68.conf"
    if [ ! -f "$FILE133" ]; then
    	echo "文件不存在: $FILE133"
    	cleanup
    fi
    # 检查文件是否包含字符串 "RM520N"
    if grep -q "RM520N" "$FILE133"; then
        echo ""
    else
        cleanup
    fi
    SIM_Check=$(atsd_tools_cli -i cpe -c "AT+CPIN?")
    if [ -z "$(echo "$SIM_Check" | grep "READY")" ]; then
        {    
        echo `atsd_tools_cli -i cpe -c "ATI" | sed -n '3p'|sed 's/\r$//'` #'RM520N-CN'
        echo `atsd_tools_cli -i cpe -c "ATI" | sed -n '2p'|sed 's/\r$//'` #'Quectel'
        echo `date "+%Y-%m-%d %H:%M:%S"`
        echo ''
        echo "未检测到SIM卡!"
        echo -e "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n"
        } > /tmp/cpe_cell-AK68.file
        rm -rf "$LOCK_FILE"
        exit
    fi

    InitData(){
        Date=''
        CHANNEL="-" 
        ECIO="-"
        RSCP="-"
        ECIO1=" "
        RSCP1=" "
        NETMODE="-"
        LBAND="-"
        PCI="-"
        CTEMP="-"
        MODE="-"
        SINR="-"
        IMEI='-'
        IMSI='-'
        ICCID='-'
        phone='-'
        conntype=''
        Model=''

    }

    OutData(){
        echo "开始写到前端页面..." > /tmp/stsss.file
        echo "开始写数据..."
        {
        echo `atsd_tools_cli -i cpe -c "ATI" | sed -n '2p'|sed 's/\r$//'` #'Quectel'
        echo `atsd_tools_cli -i cpe -c "ATI" | sed -n '3p'|sed 's/\r$//'` #'RM520N-CN'
        echo `atsd_tools_cli -i cpe -c "ATI" | sed -n '4p' | cut -d ':' -f2 | tr -d ' '|sed 's/\r$//'` #'RM520NCNAAR03A03M4G
        echo "$CTEMP" # 设备温度 41°C
        echo `date "+%Y-%m-%d %H:%M:%S"` # 时间
        #----------------------------------
        echo "$SIMCard" # 卡槽
        echo "$ISP" #运营商
        echo "$IMEI" #imei
        echo "$IMSI" #imsi
        echo `atsd_tools_cli -i cpe -c AT+QCCID | awk -F': ' '/\:/{print $2}'|sed 's/\r$//'` #iccid
        echo `atsd_tools_cli -i cpe -c AT+CNUM | grep "+CNUM:" | sed 's/.*,"\(.*\)",.*/\1/'|sed 's/\r$//'` #phone
        #-----------------------------------
        echo "$MODE" #蜂窝网络类型 NR5G-SA "TDD"
        echo "$CSQ_PER" #CSQ_PER 信号质量
        echo "$CSQ_RSSI" #信号强度 RSSI 信号强度
        echo "$ECIO dB" #接收质量 RSRQ 
        echo "$RSCP dBm" #接收功率 RSRP
        echo "$SINR" #信噪比 SINR  rv["sinr"]
        #-----------------------------------
        echo "$COPS_MCC /$COPS_MNC" #MCC / MNC
        echo "$LAC"  #位置区编码
        echo "$CID"  #小区基站编码
        echo "$LBAND" # 频段 频宽
        echo "$CHANNEL" # 频点
        echo "$PCI" #物理小区标识 
        AMBR #基站速率和接入点！
        echo "$apn"
        echo "$DOWNspeed""mbps"
        echo "$UPspeed""mbps"
        } > /tmp/cpe_cell-AK68.file
        echo "数据写出前端页面完成" > /tmp/stsss.file
        echo "数据写出完成"
    }

    AMBR(){
        rm -rf "$LOCK_FILE"
        echo "开始获取速率..." > /tmp/stsss.file
        if [ -n "$QENG5" ]; then
            AMB=$(atsd_tools_cli -i cpe -c 'AT+qnwcfg="NR5G_AMBR"' | sed -n '2p')
            if [[ "$AMB" =~ "IMS" || "$AMB" =~ "ims" ]]
            then
                AMB=$(atsd_tools_cli -i cpe -c 'AT+qnwcfg="NR5G_AMBR"' | sed -n '3p')
                apn=$(echo $AMB | cut -d, -f2)
                apn=${apn:1:-1}
                DOWNspeed=$(echo $AMB | cut -d, -f4)
                UPspeed=$(($(echo $AMB | cut -d, -f6))) 
            else
                apn=$(echo $AMB | cut -d, -f2)
                apn=${apn:1:-1}
                DOWNspeed=$(echo $AMB | cut -d, -f4)
                UPspeed=$(($(echo $AMB | cut -d, -f6)))
            fi
        else
            AMB=$(atsd_tools_cli -i cpe -c 'AT+qnwcfg="lte_ambr"' | sed -n '2p')
            if [[ "$AMB" =~ "IMS" || "$AMB" =~ "ims" ]]
            then
                AMB=$(atsd_tools_cli -i cpe -c 'AT+qnwcfg="lte_ambr"' | sed -n '3p')
                apn=$(echo $AMB | cut -d, -f2)
                apn=${apn:1:-1}
                DOWNspeed=$(echo $AMB | cut -d, -f3)
                DOWNspeed=`expr $DOWNspeed / 1000`             
                UPspeed=$(echo $AMB | cut -d, -f4)
                UPspeed=$(($UPspeed / 1000))
            else
                apn=$(echo $AMB | cut -d, -f2)
                apn=${apn:1:-1}
                DOWNspeed=$(echo $AMB | cut -d, -f3)
                DOWNspeed=`expr $DOWNspeed / 1000`
                UPspeed=$(echo $AMB | cut -d, -f4)
                UPspeed=$(($UPspeed / 1000))
            fi  
        fi
        echo "速率获取完成" > /tmp/stsss.file
    }
    #source /usr/share/modem/Quectel
    lte_bw() {
        BW=$(echo $BW | grep -o "[0-5]\{1\}")
        case $BW in
            "0")
                BW="1.4" ;;
            "1")
                BW="3" ;;
            "2"|"3"|"4"|"5")
                BW=$((($(echo $BW) - 1) * 5)) ;;
        esac
    }

    nr_bw() {
        BW=$(echo $BW | grep -o "[0-9]\{1,2\}")
        case $BW in
            "0"|"1"|"2"|"3"|"4"|"5")
                BW=$((($(echo $BW) + 1) * 5)) ;;
            "6"|"7"|"8"|"9"|"10"|"11"|"12")
                BW=$((($(echo $BW) - 2) * 10)) ;;
            "13")
                BW="200" ;;
            "14")
                BW="400" ;;
        esac
    }

    All_CSQ()
    {
        #信号
        echo "信号获取..." > /tmp/stsss.file
        echo "信号获取..."
        OX=$( atsd_tools_cli -i cpe -c "AT+CSQ" |grep "+CSQ:")
        OX=$(echo $OX | tr 'a-z' 'A-Z')
        CSQ=$(echo "$OX" | grep -o "+CSQ: [0-9]\{1,2\}" | grep -o "[0-9]\{1,2\}")
        if [ $CSQ = "99" ]; then
            CSQ=""
        fi
        if [ -n "$CSQ" ]; then
            CSQ_PER=$(($CSQ * 100/31))"%"
            CSQ_RSSI=$((2 * CSQ - 113))" dBm"
        else
            CSQ="-"
            CSQ_PER="-"
            CSQ_RSSI="-"
        fi
        echo "信号获取完成" > /tmp/stsss.file
        echo "信号获取完成"
    }

    Quectel_SIMINFO()
    {
        # 获取IMEI
        echo "IMEI获取..." > /tmp/stsss.file
        echo "IMEI获取..."
        IMEI=$( atsd_tools_cli -i cpe -c "AT+CGSN"  | sed -n '2p'  )
        echo "IMEI获取完成" > /tmp/stsss.file
        echo "IMEI获取完成"
        # 获取IMSI
        echo "IMSI获取..." > /tmp/stsss.file
        echo "IMSI获取..."
        IMSI=$( atsd_tools_cli -i cpe -c "AT+CIMI"  | sed -n '2p'  )
        echo "IMSI获取完成" > /tmp/stsss.file
        echo "IMSI获取完成"
        # 获取ICCID
        echo "ICCID获取..." > /tmp/stsss.file
        echo "ICCID获取..."
        ICCID=$( atsd_tools_cli -i cpe -c "AT+ICCID"  | grep -o "+ICCID:[ ]*[-0-9]\+" | grep -o "[-0-9]\{1,4\}"  )
        echo "ICCID获取完成" > /tmp/stsss.file
        echo "ICCID获取完成"
        # 获取电话号码
        echo "电话获取..." > /tmp/stsss.file
        echo "电话获取..."
        phone=$( atsd_tools_cli -i cpe -c "AT+CNUM"  | grep "+CNUM:"  )
        echo "电话获取完成" > /tmp/stsss.file
        echo "电话获取完成"

    }
    # SIMCOM获取基站信息
    Quectel_Cellinfo()
    {
        # return
        #cellinfo0.gcom
        echo "SIMCOM获取基站信息...." > /tmp/stsss.file
        echo "SIMCOM获取基站信息...."
        OX1=$( atsd_tools_cli -i cpe -c "AT+COPS=3,0;+COPS?")
        OX2=$( atsd_tools_cli -i cpe -c "AT+COPS=3,2;+COPS?")
        OX=$OX1" "$OX2
        #cellinfo.gcom
        OY1=$( atsd_tools_cli -i cpe -c "AT+CREG=2;+CREG?;+CREG=0")
        OY2=$( atsd_tools_cli -i cpe -c "AT+CEREG=2;+CEREG?;+CEREG=0")
        OY3=$( atsd_tools_cli -i cpe -c "AT+C5GREG=2;+C5GREG?;+C5GREG=0")
        OY=$OY1" "$OY2" "$OY3

        OXx=$OX
        OX=$(echo $OX | tr 'a-z' 'A-Z')
        OY=$(echo $OY | tr 'a-z' 'A-Z')
        OX=$OX" "$OY
        COPS="-"
        COPS_MCC="-"
        COPS_MNC="-"
        COPSX=$(echo $OXx | grep -o "+COPS: [01],0,.\+," | cut -d, -f3 | grep -o "[^\"]\+")

        if [ "x$COPSX" != "x" ]; then
            COPS=$COPSX
        fi

        COPSX=$(echo $OX | grep -o "+COPS: [01],2,.\+," | cut -d, -f3 | grep -o "[^\"]\+")

        if [ "x$COPSX" != "x" ]; then
            COPS_MCC=${COPSX:0:3}
            COPS_MNC=${COPSX:3:3}
            if [ "$COPS" = "-" ]; then
                COPS=$(awk -F[\;] '/'$COPS'/ {print $2}' $ROOTER/signal/mccmnc.data)
                [ "x$COPS" = "x" ] && COPS="-"
            fi
        fi

        if [ "$COPS" = "-" ]; then
            COPS=$(echo "$O" | awk -F[\"] '/^\+COPS: 0,0/ {print $2}')
            if [ "x$COPS" = "x" ]; then
                COPS="-"
                COPS_MCC="-"
                COPS_MNC="-"
            fi
        fi
        COPS_MNC=" "$COPS_MNC

        OX=$(echo "${OX//[ \"]/}")
        CID=""
        CID5=""
        RAT=""
        REGV=$(echo "$OX" | grep -o "+C5GREG:2,[0-9],[A-F0-9]\{2,6\},[A-F0-9]\{5,10\},[0-9]\{1,2\}")
        if [ -n "$REGV" ]; then
            LAC5=$(echo "$REGV" | cut -d, -f3)
            LAC5=$LAC5" ($(printf "%d" 0x$LAC5))"
            CID5=$(echo "$REGV" | cut -d, -f4)
            CID5L=$(printf "%010X" 0x$CID5)
            RNC5=${CID5L:1:6}
            RNC5=$RNC5" ($(printf "%d" 0x$RNC5))"
            CID5=${CID5L:7:3}
            CID5="Short $(printf "%X" 0x$CID5) ($(printf "%d" 0x$CID5)), Long $(printf "%X" 0x$CID5L) ($(printf "%d" 0x$CID5L))"
            RAT=$(echo "$REGV" | cut -d, -f5)
        fi
        REGV=$(echo "$OX" | grep -o "+CEREG:2,[0-9],[A-F0-9]\{2,4\},[A-F0-9]\{5,8\}")
        REGFMT="3GPP"
        if [ -z "$REGV" ]; then
            REGV=$(echo "$OX" | grep -o "+CEREG:2,[0-9],[A-F0-9]\{2,4\},[A-F0-9]\{1,3\},[A-F0-9]\{5,8\}")
            REGFMT="SW"
        fi
        if [ -n "$REGV" ]; then
            LAC=$(echo "$REGV" | cut -d, -f3)
            LAC=$(printf "%04X" 0x$LAC)" ($(printf "%d" 0x$LAC))"
            if [ $REGFMT = "3GPP" ]; then
                CID=$(echo "$REGV" | cut -d, -f4)
            else
                CID=$(echo "$REGV" | cut -d, -f5)
            fi
            CIDL=$(printf "%08X" 0x$CID)
            RNC=${CIDL:1:5}
            RNC=$RNC" ($(printf "%d" 0x$RNC))"
            CID=${CIDL:6:2}
            CID="Short $(printf "%X" 0x$CID) ($(printf "%d" 0x$CID)), Long $(printf "%X" 0x$CIDL) ($(printf "%d" 0x$CIDL))"

        else
            REGV=$(echo "$OX" | grep -o "+CREG:2,[0-9],[A-F0-9]\{2,4\},[A-F0-9]\{2,8\}")
            if [ -n "$REGV" ]; then
                LAC=$(echo "$REGV" | cut -d, -f3)
                CID=$(echo "$REGV" | cut -d, -f4)
                if [ ${#CID} -gt 4 ]; then
                    LAC=$(printf "%04X" 0x$LAC)" ($(printf "%d" 0x$LAC))"
                    CIDL=$(printf "%08X" 0x$CID)
                    RNC=${CIDL:1:3}
                    CID=${CIDL:4:4}
                    CID="Short $(printf "%X" 0x$CID) ($(printf "%d" 0x$CID)), Long $(printf "%X" 0x$CIDL) ($(printf "%d" 0x$CIDL))"
                else
                    LAC=""
                fi
            else
                LAC=""
            fi
        fi
        REGSTAT=$(echo "$REGV" | cut -d, -f2)
        if [ "$REGSTAT" == "5" -a "$COPS" != "-" ]; then
            COPS_MNC=$COPS_MNC" (Roaming)"
        fi
        if [ -n "$CID" -a -n "$CID5" ] && [ "$RAT" == "13" -o "$RAT" == "10" ]; then
            LAC="4G $LAC, 5G $LAC5"
            CID="4G $CID<br />5G $CID5"
            RNC="4G $RNC, 5G $RNC5"
        elif [ -n "$CID5" ]; then
            LAC=$LAC5
            CID=$CID5
            RNC=$RNC5
        fi
        if [ -z "$LAC" ]; then
            LAC="-"
            CID="-"
            RNC="-"
        fi
        echo "SIMCOM获取基站完成" > /tmp/stsss.file
        echo "SIMCOM获取基站完成"
    }

    #Quectel公司查找基站AT
    Quectel_AT()
    {
        echo "INIT..." > /tmp/stsss.file
        echo "INIT..."
        Quectel_SIMINFO
        All_CSQ
        Quectel_Cellinfo
        #
        echo "开始初始化Quectel基站数据格式化..." > /tmp/stsss.file
        echo "开始初始化Quectel基站数据格式化..."
        OX=$( atsd_tools_cli -i cpe -c 'AT+QENG="servingcell"'  | grep "+QENG:"  )
        NR_NSA=$(echo $OX | grep -o -i "+QENG:[ ]\?\"NR5G-NSA\",")
        NR_SA=$(echo $OX | grep -o -i "+QENG: \"SERVINGCELL\",[^,]\+,\"NR5G-SA\",\"[DFT]\{3\}\",")
        if [ -n "$NR_NSA" ]; then
        QENG=",,"$(echo $OX" " | grep -o -i "+QENG: \"LTE\".\+\"NR5G-NSA\"," | tr " " ",")
        QENG5=$(echo $OX | grep -o -i "+QENG:[ ]\?\"NR5G-NSA\",[0-9]\{3\},[0-9]\{2,3\},[0-9]\{1,5\},-[0-9]\{2,5\},[-0-9]\{1,3\},-[0-9]\{2,3\},[0-9]\{1,7\},[0-9]\{1,3\}.\{1,6\}")
        if [ -z "$QENG5" ]; then
            QENG5=$(echo $OX | grep -o -i "+QENG:[ ]\?\"NR5G-NSA\",[0-9]\{3\},[0-9]\{2,3\},[0-9]\{1,5\},-[0-9]\{2,3\},[-0-9]\{1,3\},-[0-9]\{2,3\}")
            if [ -n "$QENG5" ]; then
                QENG5=$QENG5",,"
            fi
        fi
        elif [ -n "$NR_SA" ]; then
            QENG=$(echo $NR_SA | tr " " ",")
            QENG5=$(echo $OX | grep -o -i "+QENG: \"SERVINGCELL\",[^,]\+,\"NR5G-SA\",\"[DFT]\{3\}\",[ 0-9]\{3,4\},[0-9]\{2,3\},[0-9A-F]\{1,10\},[0-9]\{1,5\},[0-9A-F]\{2,6\},[0-9]\{6,7\},[0-9]\{1,3\},[0-9]\{1,2\},-[0-9]\{2,5\},-[0-9]\{2,3\},[-0-9]\{1,3\}")
        else
            QENG=$(echo $OX" " | grep -o -i "+QENG: [^ ]\+ " | tr " " ",")
        fi
        
        RAT=$(echo $QENG | cut -d, -f4 | grep -o "[-A-Z5]\{3,7\}")
        case $RAT in
            "GSM")
                MODE="GSM"
                ;;
            "WCDMA")
                MODE="WCDMA"
                CHANNEL=$(echo $QENG | cut -d, -f9)
                RSCP=$(echo $QENG | cut -d, -f12)
                RSCP="-"$(echo $RSCP | grep -o "[0-9]\{1,3\}")
                ECIO=$(echo $QENG | cut -d, -f13)
                ECIO="-"$(echo $ECIO | grep -o "[0-9]\{1,3\}")
                ;;
            "LTE"|"CAT-M"|"CAT-NB")
                MODE=$(echo $QENG | cut -d, -f5 | grep -o "[DFT]\{3\}")
                if [ -n "$MODE" ]; then
                    MODE="$RAT $MODE"
                else
                    MODE="$RAT"
                fi
                PCI=$(echo $QENG | cut -d, -f9)
                CHANNEL=$(echo $QENG | cut -d, -f10)
                LBAND=$(echo $QENG | cut -d, -f11 | grep -o "[0-9]\{1,3\}")
                BW=$(echo $QENG | cut -d, -f12)
                lte_bw
                BWU=$BW
                BW=$(echo $QENG | cut -d, -f13)
                lte_bw
                BWD=$BW
                if [ -z "$BWD" ]; then
                    BWD="unknown"
                fi
                if [ -z "$BWU" ]; then
                    BWU="unknown"
                fi
                if [ -n "$LBAND" ]; then
                    LBAND="B"$LBAND" (Bandwidth $BWD MHz Down | $BWU MHz Up)"
                fi
                RSRP=$(echo $QENG | cut -d, -f15 | grep -o "[0-9]\{1,3\}")
                if [ -n "$RSRP" ]; then
                    RSCP="-"$RSRP
                    RSRPLTE=$RSCP
                fi
                RSRQ=$(echo $QENG | cut -d, -f16 | grep -o "[0-9]\{1,3\}")
                if [ -n "$RSRQ" ]; then
                    ECIO="-"$RSRQ
                fi
                RSSI=$(echo $QENG | cut -d, -f17 | grep -o "\-[0-9]\{1,3\}")
                if [ -n "$RSSI" ]; then
                    CSQ_RSSI=$RSSI" dBm"
                fi
                SINRR=$(echo $QENG | cut -d, -f18 | grep -o "[0-9]\{1,3\}")
                if [ -n "$SINRR" ]; then
                    if [ $SINRR -le 25 ]; then
                        SINR=$((($(echo $SINRR) * 2) -20))" dB"
                    fi
                fi

                if [ -n "$NR_NSA" ]; then
                    MODE="LTE/NR EN-DC"
                    echo "0" > /tmp/modnetwork-AK68
                    if [ -n "$QENG5" ]  && [ -n "$LBAND" ] && [ "$RSCP" != "-" ] && [ "$ECIO" != "-" ]; then
                        PCI="$PCI, "$(echo $QENG5 | cut -d, -f4)
                        SCHV=$(echo $QENG5 | cut -d, -f8)
                        SLBV=$(echo $QENG5 | cut -d, -f9)
                        BW=$(echo $QENG5 | cut -d, -f10 | grep -o "[0-9]\{1,3\}")
                        if [ -n "$SLBV" ]; then
                            LBAND=$LBAND"<br />n"$SLBV
                            if [ -n "$BW" ]; then
                                nr_bw
                                LBAND=$LBAND" (Bandwidth $BW MHz)"
                            fi
                            if [ "$SCHV" -ge 123400 ]; then
                                CHANNEL=$CHANNEL", "$SCHV
                            else
                                CHANNEL=$CHANNEL", -"
                            fi
                        else
                            LBAND=$LBAND"<br />nxx (unknown NR5G band)"
                            CHANNEL=$CHANNEL", -"
                        fi
                        RSCP=$RSCP" dBm<br />"$(echo $QENG5 | cut -d, -f5)
                        SINRR=$(echo $QENG5 | cut -d, -f6 | grep -o "[0-9]\{1,3\}")
                        if [ -n "$SINRR" ]; then
                            if [ $SINRR -le 30 ]; then
                                SINR=$SINR"<br />"$((($(echo $SINRR) * 2) -20))" dB"
                            fi
                        fi
                        ECIO=$ECIO" (4G) dB<br />"$(echo $QENG5 | cut -d, -f7)" (5G) "
                    fi
                fi
                if [ -z "$LBAND" ]; then
                    LBAND="-"
                else
                    if [ -n "$QCA" ]; then
                        QCA=$(echo $QCA | grep -o "\"S[CS]\{2\}\"[-0-9A-Z,\"]\+")
                        for QCAL in $(echo "$QCA"); do
                            if [ $(echo "$QCAL" | cut -d, -f7) = "2" ]; then
                                SCHV=$(echo $QCAL | cut -d, -f2 | grep -o "[0-9]\+")
                                SRATP="B"
                                if [ -n "$SCHV" ]; then
                                    CHANNEL="$CHANNEL, $SCHV"
                                    if [ "$SCHV" -gt 123400 ]; then
                                        SRATP="n"
                                    fi
                                fi
                                SLBV=$(echo $QCAL | cut -d, -f6 | grep -o "[0-9]\{1,2\}")
                                if [ -n "$SLBV" ]; then
                                    LBAND=$LBAND"<br />"$SRATP$SLBV
                                    BWD=$(echo $QCAL | cut -d, -f3 | grep -o "[0-9]\{1,3\}")
                                    if [ -n "$BWD" ]; then
                                        UPDOWN=$(echo $QCAL | cut -d, -f13)
                                        case "$UPDOWN" in
                                            "UL" )
                                                CATYPE="CA"$(printf "\xe2\x86\x91") ;;
                                            "DL" )
                                                CATYPE="CA"$(printf "\xe2\x86\x93") ;;
                                            * )
                                                CATYPE="CA" ;;
                                        esac
                                        if [ $BWD -gt 14 ]; then
                                            LBAND=$LBAND" ("$CATYPE", Bandwidth "$(($(echo $BWD) / 5))" MHz)"
                                        else
                                            LBAND=$LBAND" ("$CATYPE", Bandwidth 1.4 MHz)"
                                        fi
                                    fi
                                    LBAND=$LBAND
                                fi
                                PCI="$PCI, "$(echo $QCAL | cut -d, -f8)
                            fi
                        done
                    fi
                fi
                if [ $RAT = "CAT-M" ] || [ $RAT = "CAT-NB" ]; then
                    LBAND="B$(echo $QENG | cut -d, -f11) ($RAT)"
                fi
                ;;
            "NR5G-SA")
                MODE="NR5G-SA"
                if [ -n "$QENG5" ]; then
                    #AT+qnwcfg="NR5G_AMBR"  #查询速度
                    MODE="$RAT $(echo $QENG5 | cut -d, -f4)"
                    PCI=$(echo $QENG5 | cut -d, -f8)
                    CHANNEL=$(echo $QENG5 | cut -d, -f10)
                    LBAND=$(echo $QENG5 | cut -d, -f11)
                    BW=$(echo $QENG5 | cut -d, -f12)
                    nr_bw
                    LBAND="n"$LBAND" (Bandwidth $BW MHz)"
                    RSCP=$(echo $QENG5 | cut -d, -f13)
                    ECIO=$(echo $QENG5 | cut -d, -f14)
                    if [ "$CSQ_PER" = "-" ]; then
                        RSSI=$(rsrp2rssi-AK68 $RSCP $BW)
                        CSQ_PER=$((100 - (($RSSI + 51) * 100/-62)))"%"
                        CSQ=$((($RSSI + 113) / 2))
                        CSQ_RSSI=$RSSI" dBm"
                    fi
                    SINRR=$(echo $QENG5 | cut -d, -f15 | grep -o "[0-9]\{1,3\}")
                    if [ -n "$SINRR" ]; then
                        if [ $SINRR -le 30 ]; then
                            SINR=$((($(echo $SINRR) * 2) -20))" dB"
                        fi
                    fi
                fi
                ;;
        esac

        #
        OX=$( atsd_tools_cli -i cpe -c "AT+QCAINFO"  | grep "+QCAINFO:"  )
        QCA=$(echo $OX" " | grep -o -i "+QCAINFO: \"S[CS]\{2\}\".\+NWSCANMODE" | tr " " ",")
        #
        OX=$( atsd_tools_cli -i cpe -c 'AT+QCFG="nwscanmode"'  | grep "+QCAINFO:"  )
        QNSM=$(echo $OX | grep -o -i "+QCFG: \"NWSCANMODE\",[0-9]")
        QNSM=$(echo "$QNSM" | grep -o "[0-9]")
        if [ -n "$QNSM" ]; then
            MODTYPE="6"
            case $QNSM in
            "0" )
                NETMODE="1" ;;
            "1" )
                NETMODE="3" ;;
            "2"|"5" )
                NETMODE="5" ;;
            "3" )
                NETMODE="7" ;;
            esac
        fi
        if [ -n "$QNWP" ]; then
            MODTYPE="6"
            case $QNWP in
            "AUTO" )
                NETMODE="1" ;;
            "WCDMA" )
                NETMODE="5" ;;
            "LTE" )
                NETMODE="7" ;;
            "LTE:NR5G" )
                NETMODE="8" ;;
            "NR5G" )
                NETMODE="9" ;;
            esac
        fi

        #
        OX=$( atsd_tools_cli -i cpe -c 'AT+QNWPREFCFG="mode_pref"'  | grep "+QNWPREFCFG:"  )
        QNWP=$(echo $OX | grep -o -i "+QNWPREFCFG: \"MODE_PREF\",[A-Z5:]\+" | cut -d, -f2)
        #温度
        echo "查询温度..." > /tmp/stsss.file
        OX=$( atsd_tools_cli -i cpe -c 'AT+QTEMP'  | grep "+QTEMP:"  )
        QTEMP=$(echo $OX | grep -o -i "+QTEMP: [0-9]\{1,3\}")
        if [ -z "$QTEMP" ]; then
            QTEMP=$(echo $OX | grep -o -i "+QTEMP:[ ]\?\"XO[_-]THERM[_-][^,]\+,[\"]\?[0-9]\{1,3\}" | grep -o "[0-9]\{1,3\}")
        fi
        if [ -z "$QTEMP" ]; then
            QTEMP=$(echo $OX | grep -o -i "+QTEMP:[ ]\?\"MDM-CORE-USR.\+[0-9]\{1,3\}\"" | cut -d\" -f4)
        fi
        if [ -z "$QTEMP" ]; then
            QTEMP=$(echo $OX | grep -o -i "+QTEMP:[ ]\?\"MDMSS.\+[0-9]\{1,3\}\"" | cut -d\" -f4)
        fi
        if [ -n "$QTEMP" ]; then
            CTEMP=$(echo $QTEMP | grep -o -i "[0-9]\{1,3\}")$(printf "\xc2\xb0")"C"
        fi
        echo "温度查询完成" > /tmp/stsss.file
        #
        OX=$(atsd_tools_cli -i cpe -c "AT+QRSRP"  | grep "+QRSRP:")
        QRSRP=$(echo "$OX" | grep -o -i "+QRSRP:[^,]\+,-[0-9]\{1,5\},-[0-9]\{1,5\},-[0-9]\{1,5\}[^ ]*")
        if [ -n "$QRSRP" ] && [ "$RAT" != "WCDMA" ]; then
            QRSRP1=$(echo $QRSRP | cut -d, -f1 | grep -o "[-0-9]\+")
            QRSRP2=$(echo $QRSRP | cut -d, -f2)
            QRSRP3=$(echo $QRSRP | cut -d, -f3)
            QRSRP4=$(echo $QRSRP | cut -d, -f4)
            QRSRPtype=$(echo $QRSRP | cut -d, -f5)
            if [ "$QRSRPtype" == "NR5G" ]; then
                if [ -n "$NR_SA" ]; then
                    RSCP=$QRSRP1
                    if [ -n "$QRPRP2" -a "$QRSRP2" != "-32768" ]; then
                        RSCP1="RxD "$QRSRP2
                    fi
                    if [ -n "$QRSRP3" -a "$QRSRP3" != "-32768" ]; then
                        RSCP=$RSCP" dBm<br />"$QRSRP3
                    fi
                    if [ -n "$QRSRP4" -a "$QRSRP4" != "-32768" ]; then
                        RSCP1="RxD "$QRSRP4
                    fi
                else
                    RSCP=$RSRPLTE
                    if [ -n "$QRSRP1" -a "$QRSRP1" != "-32768" ]; then
                        RSCP=$RSCP" (4G) dBm<br />"$QRSRP1
                        if [ -n "$QRSRP2" -a "$QRSRP2" != "-32768" ]; then
                            RSCP="$RSCP,$QRSRP2"
                            if [ -n "$QRSRP3" -a "$QRSRP3" != "-32768" ]; then
                                RSCP="$RSCP,$QRSRP3"
                                if [ -n "$QRSRP4" -a "$QRSRP4" != "-32768" ]; then
                                    RSCP="$RSCP,$QRSRP4"
                                fi
                            fi
                            RSCP=$RSCP" (5G) "
                        fi
                    fi
                fi
            elif [ "$QRSRP2$QRSRP3$QRSRP4" != "-44-44-44" -a -z "$QENG5" ]; then
                RSCP=$QRSRP1
                if [ "$QRSRP3$QRSRP4" == "-140-140" -o "$QRSRP3$QRSRP4" == "-44-44" -o "$QRSRP3$QRSRP4" == "-32768-32768" ]; then
                    RSCP1="RxD "$(echo $QRSRP | cut -d, -f2)
                else
                    RSCP=$RSCP" dBm (RxD "$QRSRP2" dBm)<br />"$QRSRP3
                    RSCP1="RxD "$QRSRP4
                fi
            fi
        fi
        echo "初始化Quectel基站数据格式化完成" > /tmp/stsss.file
        echo "初始化Quectel基站数据格式化完成"
        echo "识别电话卡序号..." > /tmp/stsss.file
        echo "识别电话卡序号..."
        sim_sel=$(cat /tmp/sim_sel-AK68)
        SIMCard=""
        case $sim_sel in
            0)
                SIMCard="外置SIM卡"
                ;;
            1)
                SIMCard="内置SIM1"
                ;;
            2)
                SIMCard="内置SIM2"
                ;;
            *)
                SIMCard="SIM状态错误"
                ;;
        esac
        echo "电话卡序号识别完成" > /tmp/stsss.file
        echo "电话卡序号识别完成"
        echo "识别运营商..." > /tmp/stsss.file
        echo "识别运营商..."
        ISP=""
        case $COPS in
            "CHN-CT")
                ISP="中国电信"
                ;;
            "CHN-UNICOM")
                ISP="中国联通"
                ;;
            "CHINA MOBILE")
                ISP="中国移动"
                ;;
            *)
                ISP="$COPS"
                ;;
        esac
        echo "运营商识别完成" > /tmp/stsss.file
        echo "运营商识别完成"
        OutData
        echo "移除锁文件..." > /tmp/stsss.file 
        echo "移除锁文件..."
        rm -rf "$LOCK_FILE"
        echo "移除锁文件完成" > /tmp/stsss.file
        echo "移除锁文件完成"
        echo "已完成数据获取，点击信号状态或刷新会重新进行拉取！" > /tmp/stsss.file
        echo "已完成数据获取，点击信号状态或刷新会重新进行拉取！"
        # Normal exit cleanup
        cleanup
    }
    #====================================================================================
    InitData
    Quectel_AT
} 200>"$LOCKFILE"

