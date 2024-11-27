#!/bin/sh 

LOCK_FILE="/tmp/zinfo.lock"
if [ -e "$LOCK_FILE" ]; then
    echo "zinfo互斥" >> /tmp/rm520n.log
    exit 1
fi
touch "$LOCK_FILE"

#二次判断，避免获取信号状态和模块设置干扰
waitrm520n=$(ps -fe|grep mt5700m.sh |grep -v grep)
if [ "$waitrm520n" != "" ]
then
    if [ -e "/tmp/cpe_cell-AK68.file" ]; then
    sed -i '14,26 s/.*/Loading.../g' /tmp/cpe_cell-AK68.file  
    fi
    rm -rf "$LOCK_FILE"
    exit 1
fi

# 判断第三行文本并执行相应操作
#third_line=$(atsd_tools_cli -i cpe -c 'ATI' | sed -n '3p')
#if [ -n "$third_line" ]; then
#    if echo "$third_line" | grep -q 'RM520'; then
#        ModuleName=$(atsd_tools_cli -i cpe -c "ATI" | sed -n '2p'|sed 's/\r$//') #'Quectel'
#        ModuleType=$(atsd_tools_cli -i cpe -c "ATI" | sed -n '3p'|sed 's/\r$//') #'RM520N-CN'
#        Moduleversion=$(atsd_tools_cli -i cpe -c "ATI" | sed -n '4p' | cut -d ':' -f2 | tr -d ' '|sed 's/\r$//') #'RM520NCNAAR03A03M4G
#
#        source /usr/share/modem/Quectel       
#    elif echo "$third_line" | grep -q 'RM500U'; then
#        ModuleName=$(atsd_tools_cli -i cpe -c "ATI" | sed -n '2p'|sed 's/\r$//') #'Quectel'
#        ModuleType=$(atsd_tools_cli -i cpe -c "ATI" | sed -n '3p'|sed 's/\r$//') #'RM520N-CN'
#        Moduleversion=$(atsd_tools_cli -i cpe -c "ATI" | sed -n '4p' | cut -d ':' -f2 | tr -d ' '|sed 's/\r$//') #'RM520NCNAAR03A03M4G
#        source /usr/share/modem/RM500X
#    fi
#else
#    echo "第三行文本为空或不包含指定内容"
#    source /usr/share/modem/MT5700M   
#fi
#source /usr/share/modem/Quectel

#sim_sel=$(cat /tmp/sim_sel-AK68)
#SIMCard=""

#case $sim_sel in
#    0)
#        SIMCard="外置SIM卡"
#        ;;
#    1)
#        SIMCard="内置SIM1"
#        ;;
#    2)
#        SIMCard="内置SIM2"
#        ;;
#    *)
#        SIMCard="SIM状态错误"
#        ;;
#esac


#SIM_Check=$(atsd_tools_cli -i cpe -c AT+CPIN?)
#if [ -z "$(echo "$SIM_Check" | grep "READY")" ]; then
#    {    
#    echo `atsd_tools_cli -i cpe -c "ATI" | sed -n '3p'|sed 's/\r$//'` #'RM520N-CN'
#    echo `atsd_tools_cli -i cpe -c "ATI" | sed -n '2p'|sed 's/\r$//'` #'Quectel'
#    echo `date "+%Y-%m-%d %H:%M:%S"`
#    echo ''
#    echo "未检测到SIM卡!"
#    echo -e "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n"
#    } > /tmp/cpe_cell-AK68.file
#    rm -rf "$LOCK_FILE"
 #   exit
#fi


Temperature(){
    OX=$(atsd_tools_cli -i cpe -c 'AT^CHIPTEMP?'| grep 'CHIPTEMP' | sed -n '1p' | cut -d, -f9 | sed '/^$/d')
    CTEMP=$(($OX / 10))
}
ISP_Read(){
        operatorCode=$(atsd_tools_cli -i cpe -c 'AT^EONS=2' | awk -F ',' '{print $2}' | sed '/^$/d')
        case "$operatorCode" in
        "46000" | "46002" | "46004" | "46007" | "46008" | "46020")
            ISP="中国移动"
            ;;
        "46001" | "46006" | "46009")
            ISP="中国联通"
            ;;
        "46003" | "46005" | "46011")
            ISP="中国电信"
            ;;
        "46015")
            ISP="中国广电"
            ;;
        *)
            ISP="未知运营商"
            ;;
        esac
}


TD_Tech_Ltd_SIMINFO()
{
    # 获取IMEI
	IMEI=$( sendat $ATPORT "AT+CGSN"  | sed -n '2p'  )
	# 获取IMSI
	IMSI=$( sendat $ATPORT "AT+CIMI"  | sed -n '2p'  )
	# 获取ICCID
	ICCID=$( sendat $ATPORT "AT^ICCID?" | grep -o "[-0-9]*" )
	# 获取电话号码
	phone=$(sendat $ATPORT "AT+CNUM"  | awk -F ',' '{print $2}'| sed '/^$/d' )
    phone=${phone:1:-1}
    QCI1=$(atsd_tools_cli -i cpe -c 'AT+CGEQOSRDP=8' | sed -n '2p')
    QCI2=$(echo $QCI1 | cut -d ',' -f2)
    QCI2=$(echo "$QCI2" | tr -dc '0-9')
    case $QCI2 in
    1)
        QCI="QCI值：1\\-GBR优级2\\-Budget100ms"
        ;;
    2)
        QCI="QCI值：2\\-GBR优级4\\-Budget150ms"
        ;;
    3)
        QCI="QCI值：3\\-GBR优级3\\-Budget50ms"
        ;;
    4)
        QCI="QCI值：4\\-GBR优级5\\-Budget300ms"
        ;;
    5)
        QCI="QCI值：5\\-GBR优级1\\-Budget100ms"
        ;;
    6)
        QCI="QCI值：6\\-GBR优级6\\-Budget300ms"
        ;;
    7)
        QCI="QCI值：7\\-GBR优级7\\-Budget100ms"
        ;;
    8)
        QCI="QCI值：8\\-GBR优级8\\-Budget300ms"
        ;;
    9)
        QCI="QCI值：9\\-GBR优级9\\-延时预300ms"
        ;;
    *)
        QCI="无效的QCI值：$QCI2"
        ;;
    esac

}
Read_signal_data(){
    OX=$(atsd_tools_cli -i cpe -c 'AT^MONSC' | sed -n '2p' | grep 'MONSC') 
    if echo "$OX" | grep -q "NR"; then
        DTAT_5G
    elif echo "$OX" | grep -q "LTE"; then
        DTAT_4G
    fi
}
DTAT_5G(){
    OX=$(atsd_tools_cli -i cpe -c 'AT^MONSC' | sed -n '2p' | grep 'MONSC') 
    MODE="NR-5G"
    RSCP=$(echo $OX | awk -F ',' '{print $9}')
    if [ $RSCP -ge -85 ] ; then
    CSQ_PER="100%"
    elif [ $RSCP -le -85 -a $RSCP -ge -90 ]  ; then
    CSQ_PER="90%"
    elif [ $RSCP -le -90 -a $RSCP -ge -95 ]  ; then
    CSQ_PER="80%"
    elif [ $RSCP -le -95 -a $RSCP -ge -105 ]  ; then
    CSQ_PER="50%"
    elif [ $RSCP -le 105 -a $RSCP -ge -115 ]  ; then
    CSQ_PER="10%"        
    fi
    ECIO=$(echo $OX | awk -F ',' '{print $10}')
    CSQ_RSSI=$ECIO
    SINR=$(echo $OX | awk -F ',' '{print $11}')
    COPS_MCC=$( echo $OX | awk -F ',' '{print $2}')
    COPS_MNC=$( echo $OX | awk -F ',' '{print $3}')
    LAC=$( echo $OX | awk -F ',' '{print $8}' | sed '/^$/d')
    CID=$( echo $OX | awk -F ',' '{print $6}' | sed '/^$/d')
    CHANNEL=$( echo $OX | awk -F ',' '{print $4}')

    HFREQINFO=$(atsd_tools_cli -i cpe -c "AT^HFREQINFO?" | grep "HFREQINFO")
    band=$(echo $HFREQINFO | cut -d, -f3)   
    dl_bwN=$(echo $HFREQINFO | cut -d, -f6)
    ul_bwN=$(echo $HFREQINFO | cut -d, -f9)
    dl_bwN=$(($dl_bwN / 1000))
    ul_bwN=$(($ul_bwN / 1000))
    LBAND="N"$band" (Bandwidth $dl_bwN MHz Down | $ul_bwN MHz Up)"

    PCI=$( echo $OX | awk -F ',' '{print $7}' | sed '/^$/d')
    PCI=$((0x$PCI))

    zbjhox=$(atsd_tools_cli -i cpe -c 'AT^CASCELLINFO?' | grep 'ERROR')
    if [ "$zbjhox" == "" ] ; then
        Zbjh="Finded 载波聚合中"
        R2cc=$(atsd_tools_cli -i cpe -c 'AT^CASCELLINFO?' | grep 'CASCELLINFO: 1')
        R3cc=$(atsd_tools_cli -i cpe -c 'AT^CASCELLINFO?' | grep 'CASCELLINFO: 2')
    else
        Zbjh="Loss 无载波聚合"
        R2cc="Loss"
        R3cc="Loss"
    fi
}



DTAT_4G(){
    OX=$(atsd_tools_cli -i cpe -c 'AT^MONSC' | sed -n '2p' | grep 'MONSC') 
    MODE="LTE-4G"
    CSQ_RSSI=$(echo $OX | awk -F ',' '{print $10}')
    RSCP=$(echo $OX | awk -F ',' '{print $8}')
    if [ $RSCP -ge -85 ] ; then
    CSQ_PER="100%"
    elif [ $RSCP -le -85 -a $RSCP -ge -90 ]  ; then
    CSQ_PER="90%"
    elif [ $RSCP -le -90 -a $RSCP -ge -95 ]  ; then
    CSQ_PER="80%"
    elif [ $RSCP -le -95 -a $RSCP -ge -105 ]  ; then
    CSQ_PER="50%"
    elif [ $RSCP -le 105 -a $RSCP -ge -115 ]  ; then
    CSQ_PER="10%"        
    fi
    ECIO=$(echo $OX | awk -F ',' '{print $9}')
    SINR="\\"
    COPS_MCC=$( echo $OX | awk -F ',' '{print $2}')
    COPS_MNC=$( echo $OX | awk -F ',' '{print $3}')
    LAC=$( echo $OX | awk -F ',' '{print $7}' | sed '/^$/d')
    CID=$( echo $OX | awk -F ',' '{print $5}' | sed '/^$/d')
    CHANNEL=$( echo $OX | awk -F ',' '{print $4}')
    HFREQINFO=$(atsd_tools_cli -i cpe -c "AT^HFREQINFO?" | grep "HFREQINFO")
    band=$(echo $HFREQINFO | cut -d, -f3)   
    dl_bwN=$(echo $HFREQINFO | cut -d, -f6)
    ul_bwN=$(echo $HFREQINFO | cut -d, -f9)
    dl_bwN=$(($dl_bwN / 1000))
    ul_bwN=$(($ul_bwN / 1000))
    LBAND="B"$band"-(Bandwidth $dl_bwN MHz Down | $ul_bwN MHz Up)"
    PCI=$( echo $OX | awk -F ',' '{print $6}' | sed '/^$/d')
    PCI=$((0x$PCI))

    zbjhox=$(atsd_tools_cli -i cpe -c 'AT^CASCELLINFO?' | grep 'ERROR')
    if [ "$zbjhox" == "" ] ; then
        Zbjh="Finded 载波聚合中"
        R2cc=$(atsd_tools_cli -i cpe -c 'AT^CASCELLINFO?' | grep 'CASCELLINFO: 1')
        R3cc=$(atsd_tools_cli -i cpe -c 'AT^CASCELLINFO?' | grep 'CASCELLINFO: 2')
    else
        Zbjh="Loss 无载波聚合"
        R2cc="Loss"
        R3cc="Loss"
    fi
}

AMBR(){
    rm -rf "$LOCK_FILE"
    AMB=$(atsd_tools_cli -i cpe -c 'AT^DSAMBR=8' | grep 'DSAMBR')
    apn=$(echo $AMB | cut -d, -f4) 
    apn=${apn:1:-1}
    DOWNspeed=$(echo $AMB | cut -d, -f2)
    DOWNspeed=`expr $DOWNspeed / 1000`
    UPspeed=$(echo $AMB | cut -d, -f3)
    UPspeed=`expr $UPspeed / 1000`
}

Read_module_data_AT(){
    ModuleName=$(atsd_tools_cli -i cpe -c "ATI" | sed -n '2p'|sed 's/\r$//') #'TD Tech Ltd'
    ModuleType=$(atsd_tools_cli -i cpe -c "ATI" | sed -n '3p'|sed 's/\r$//') #'MT5700M-CN'
    Moduleversion=$(atsd_tools_cli -i cpe -c "ATI" | sed -n '4p' | cut -d ':' -f2 | tr -d ' '|sed 's/\r$//') #'V200R001C20B008'
    Temperature
    ISP_Read
    TD_Tech_Ltd_SIMINFO
    Read_signal_data
    AMBR
}


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

sim_sel=$(cat /tmp/sim_sel-AK68)
SIMCard=""
case $sim_sel in
    0)
        SIMCard="外置SIM卡1"
        ;;
    1)
        SIMCard="内置SIM1"
        ;;
    2)
        SIMCard="内置SIM2"
        ;;
    3)
        SIMCard="外置SIM2"
        ;;
    4)
        SIMCard="外置SIM3"
        ;;
    5)
        SIMCard="外置SIM4"
        ;;
    *)
        SIMCard="SIM未读取"
        ;;
esac



OutData(){
    {
    echo "ATSD数据持续获取中..." 
    echo "$ModuleName" #'Quectel'
    echo "$ModuleType" #'RM520N-CN'
    echo "$Moduleversion" #'RM520NCNAAR03A03M4G
    echo "$CTEMP" # 设备温度 41°C
    echo `date "+%Y-%m-%d %H:%M:%S"` # 时间
    #----------------------------------
    echo "$SIMCard" # 卡槽
    echo "$ISP" #运营商
    echo "$IMEI" #imei
    echo "$IMSI" #imsi
    echo "$ICCID" #iccid
    echo "$phone" #phone
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
    echo "$apn" 
    echo "$DOWNspeed""mbps"
    echo "$UPspeed""mbps"
    echo "$QCI"
    echo "$Zbjh" #载波聚合
    echo "$R2cc"
    echo "$R3cc"
    } > /tmp/cpe_cell-AK68.file
}


InitData
Read_module_data_AT
OutData
rm -rf "$LOCK_FILE"


