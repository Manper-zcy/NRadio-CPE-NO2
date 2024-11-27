#!/bin/sh
#by:xinqn
# 显示用户选择菜单
echo "2、LED 兼容控制"
echo "3、流量白送功能"
echo "6、L2TP-SIM拨号"
read -p "请输入数字并回车选择操作：" choice
case $choice in
    2)
        led-AK68.sh
        echo "--------------------------------"
        ;;
    3)
        sll-AK68.sh
        echo "--------------------------------"
        ;;
    6)
        l2tpsim-AK68.sh
        echo "--------------------------------"
        ;;
   *)
        echo "无效的选择，请重新运行脚本并输入有效数字。"
        ;;
esac
