#!/bin/bash

echo "请选择你需要编译的设备："
echo "------------C8-650双系统--------------"
echo "1、鲲鹏C8-650双系统-巴龙常规版"
echo "2、鲲鹏C8-650双系统-巴龙纯净版"
echo "3、鲲鹏C8-650双系统-移远常规版"
echo "4、鲲鹏C8-650双系统-移远纯净版"
echo "------------C8-660双系统--------------"
echo "11、鲲鹏C8-660双系统-巴龙常规版"
echo "12、鲲鹏C8-660双系统-巴龙纯净版"
echo "13、鲲鹏C8-660双系统-移远常规版"
echo "14、鲲鹏C8-660双系统-移远纯净版"
echo "------------C8-660单系统--------------"
echo "21、鲲鹏C8-660单系统-巴龙常规版"
echo "22、鲲鹏C8-660单系统-巴龙纯净版"
echo "23、鲲鹏C8-660单系统-移远常规版"
echo "24、鲲鹏C8-660单系统-移远纯净版"
echo "------------C8-668双系统--------------"
echo "31、鲲鹏C8-668双系统-巴龙常规版"
echo "32、鲲鹏C8-668双系统-巴龙纯净版"
echo "33、鲲鹏C8-668双系统-移远常规版"
echo "34、鲲鹏C8-668双系统-移远纯净版"
echo "-------------NB68双系统---------------"
echo "41、鲲鹏C8-NB68双系统-常规版"
echo "42、鲲鹏C8-NB68双系统-纯净版"
echo "-----------C5800-688双系统------------"
echo "51、鲲鹏C5800-688双系统-常规版"
echo "52、鲲鹏C5800-688双系统-纯净版"
echo "------------C8-688双系统--------------"
echo "61、鲲鹏C8-688双系统-常规版"
echo "62、鲲鹏C8-688双系统-纯净版"
echo "-------------------------------------"
echo "7、添加LUCIAPP与更新"

read -p "输入数字选择设备: " device

# 定义源目录和目标目录
src_dir="/home/zhouwei/immortalwrt-mt798x/config-NRdev"
base_files_dir="/home/zhouwei/immortalwrt-mt798x/package/base-files/files/bin"
mtwifi_dir="/home/zhouwei/immortalwrt-mt798x/package/mtk/applications/mtwifi-cfg/files"

case $device in
    1)
        cp "${src_dir}/config_generate-650" "${base_files_dir}/config_generate"
        cp "${src_dir}/mtwifi-650.sh" "${mtwifi_dir}/mtwifi.sh"
        cp "${src_dir}/bg11.jpg" "/home/zhouwei/immortalwrt-mt798x/feeds/luci/themes/luci-theme-argon/htdocs/luci-static/argon/img/bg1.jpg"
        cp "${src_dir}/650巴龙常规版.config" "/home/zhouwei/immortalwrt-mt798x/.config"
        make menuconfig
        ;;
    2)
        cp "${src_dir}/config_generate-650" "${base_files_dir}/config_generate"
        cp "${src_dir}/mtwifi-650.sh" "${mtwifi_dir}/mtwifi.sh"
        cp "${src_dir}/bg11.jpg" "/home/zhouwei/immortalwrt-mt798x/feeds/luci/themes/luci-theme-argon/htdocs/luci-static/argon/img/bg1.jpg"
        cp "${src_dir}/650巴龙纯净版.config" "/home/zhouwei/immortalwrt-mt798x/.config"
        make menuconfig
        ;;
    3)
        cp "${src_dir}/config_generate-650" "${base_files_dir}/config_generate"
        cp "${src_dir}/mtwifi-650.sh" "${mtwifi_dir}/mtwifi.sh"
        cp "${src_dir}/bg11.jpg" "/home/zhouwei/immortalwrt-mt798x/feeds/luci/themes/luci-theme-argon/htdocs/luci-static/argon/img/bg1.jpg"
        cp "${src_dir}/650移远常规版.config" "/home/zhouwei/immortalwrt-mt798x/.config"
        make menuconfig
        ;;
    4)
        cp "${src_dir}/config_generate-650" "${base_files_dir}/config_generate"
        cp "${src_dir}/mtwifi-650.sh" "${mtwifi_dir}/mtwifi.sh"
        cp "${src_dir}/bg11.jpg" "/home/zhouwei/immortalwrt-mt798x/feeds/luci/themes/luci-theme-argon/htdocs/luci-static/argon/img/bg1.jpg"
        cp "${src_dir}/650移远纯净版.config" "/home/zhouwei/immortalwrt-mt798x/.config"
        make menuconfig
        ;;
    11)
        cp "${src_dir}/config_generate-660" "${base_files_dir}/config_generate"
        cp "${src_dir}/mtwifi-660.sh" "${mtwifi_dir}/mtwifi.sh"
        cp "${src_dir}/bg11.jpg" "/home/zhouwei/immortalwrt-mt798x/feeds/luci/themes/luci-theme-argon/htdocs/luci-static/argon/img/bg1.jpg"
        cp "${src_dir}/660巴龙常规版.config" "/home/zhouwei/immortalwrt-mt798x/.config"
        make menuconfig
        ;;
    12)
        cp "${src_dir}/config_generate-660" "${base_files_dir}/config_generate"
        cp "${src_dir}/mtwifi-660.sh" "${mtwifi_dir}/mtwifi.sh"
        cp "${src_dir}/bg11.jpg" "/home/zhouwei/immortalwrt-mt798x/feeds/luci/themes/luci-theme-argon/htdocs/luci-static/argon/img/bg1.jpg"
        cp "${src_dir}/660巴龙纯净版.config" "/home/zhouwei/immortalwrt-mt798x/.config"
        make menuconfig
        ;;
    13)
        cp "${src_dir}/config_generate-660" "${base_files_dir}/config_generate"
        cp "${src_dir}/mtwifi-660.sh" "${mtwifi_dir}/mtwifi.sh"
        cp "${src_dir}/bg11.jpg" "/home/zhouwei/immortalwrt-mt798x/feeds/luci/themes/luci-theme-argon/htdocs/luci-static/argon/img/bg1.jpg"
        cp "${src_dir}/660移远常规版.config" "/home/zhouwei/immortalwrt-mt798x/.config"
        make menuconfig
        ;;
    14)
        cp "${src_dir}/config_generate-660" "${base_files_dir}/config_generate"
        cp "${src_dir}/mtwifi-660.sh" "${mtwifi_dir}/mtwifi.sh"
        cp "${src_dir}/bg11.jpg" "/home/zhouwei/immortalwrt-mt798x/feeds/luci/themes/luci-theme-argon/htdocs/luci-static/argon/img/bg1.jpg"
        cp "${src_dir}/660移远纯净版.config" "/home/zhouwei/immortalwrt-mt798x/.config"
        make menuconfig
        ;;
    21)
        cp "${src_dir}/config_generate-660" "${base_files_dir}/config_generate"
        cp "${src_dir}/mtwifi-660.sh" "${mtwifi_dir}/mtwifi.sh"
        cp "${src_dir}/bg11.jpg" "/home/zhouwei/immortalwrt-mt798x/feeds/luci/themes/luci-theme-argon/htdocs/luci-static/argon/img/bg1.jpg"
        cp "${src_dir}/660单系统巴龙常规版.config" "/home/zhouwei/immortalwrt-mt798x/.config"
        make menuconfig
        ;;
    22)
        cp "${src_dir}/config_generate-660" "${base_files_dir}/config_generate"
        cp "${src_dir}/mtwifi-660.sh" "${mtwifi_dir}/mtwifi.sh"
        cp "${src_dir}/bg11.jpg" "/home/zhouwei/immortalwrt-mt798x/feeds/luci/themes/luci-theme-argon/htdocs/luci-static/argon/img/bg1.jpg"
        cp "${src_dir}/660单系统巴龙纯净版.config" "/home/zhouwei/immortalwrt-mt798x/.config"
        make menuconfig
        ;;
    23)
        cp "${src_dir}/config_generate-660" "${base_files_dir}/config_generate"
        cp "${src_dir}/mtwifi-660.sh" "${mtwifi_dir}/mtwifi.sh"
        cp "${src_dir}/bg11.jpg" "/home/zhouwei/immortalwrt-mt798x/feeds/luci/themes/luci-theme-argon/htdocs/luci-static/argon/img/bg1.jpg"
        cp "${src_dir}/660单系统移远常规版.config" "/home/zhouwei/immortalwrt-mt798x/.config"
        make menuconfig
        ;;
    24)
        cp "${src_dir}/config_generate-660" "${base_files_dir}/config_generate"
        cp "${src_dir}/mtwifi-660.sh" "${mtwifi_dir}/mtwifi.sh"
        cp "${src_dir}/bg11.jpg" "/home/zhouwei/immortalwrt-mt798x/feeds/luci/themes/luci-theme-argon/htdocs/luci-static/argon/img/bg1.jpg"
        cp "${src_dir}/660单系统移远纯净版.config" "/home/zhouwei/immortalwrt-mt798x/.config"
        make menuconfig
        ;;
    31)
        cp "${src_dir}/config_generate-668" "${base_files_dir}/config_generate"
        cp "${src_dir}/mtwifi-668.sh" "${mtwifi_dir}/mtwifi.sh"
        cp "${src_dir}/bg11.jpg" "/home/zhouwei/immortalwrt-mt798x/feeds/luci/themes/luci-theme-argon/htdocs/luci-static/argon/img/bg1.jpg"
        cp "${src_dir}/668巴龙常规版.config" "/home/zhouwei/immortalwrt-mt798x/.config"
        make menuconfig
        ;;
    32)
        cp "${src_dir}/config_generate-668" "${base_files_dir}/config_generate"
        cp "${src_dir}/mtwifi-668.sh" "${mtwifi_dir}/mtwifi.sh"
        cp "${src_dir}/bg11.jpg" "/home/zhouwei/immortalwrt-mt798x/feeds/luci/themes/luci-theme-argon/htdocs/luci-static/argon/img/bg1.jpg"
        cp "${src_dir}/668巴龙纯净版.config" "/home/zhouwei/immortalwrt-mt798x/.config"
        make menuconfig
        ;;
    33)
        cp "${src_dir}/config_generate-668" "${base_files_dir}/config_generate"
        cp "${src_dir}/mtwifi-668.sh" "${mtwifi_dir}/mtwifi.sh"
        cp "${src_dir}/bg11.jpg" "/home/zhouwei/immortalwrt-mt798x/feeds/luci/themes/luci-theme-argon/htdocs/luci-static/argon/img/bg1.jpg"
        cp "${src_dir}/668移远常规版.config" "/home/zhouwei/immortalwrt-mt798x/.config"
        make menuconfig
        ;;
    34)
        cp "${src_dir}/config_generate-668" "${base_files_dir}/config_generate"
        cp "${src_dir}/mtwifi-668.sh" "${mtwifi_dir}/mtwifi.sh"
        cp "${src_dir}/bg11.jpg" "/home/zhouwei/immortalwrt-mt798x/feeds/luci/themes/luci-theme-argon/htdocs/luci-static/argon/img/bg1.jpg"
        cp "${src_dir}/668移远纯净版.config" "/home/zhouwei/immortalwrt-mt798x/.config"
        make menuconfig
        ;;
    41)
        cp "${src_dir}/config_generate-NB68" "${base_files_dir}/config_generate"
        cp "${src_dir}/mtwifi-NB68.sh" "${mtwifi_dir}/mtwifi.sh"
        cp "${src_dir}/bg11.jpg" "/home/zhouwei/immortalwrt-mt798x/feeds/luci/themes/luci-theme-argon/htdocs/luci-static/argon/img/bg1.jpg"
        cp "${src_dir}/NB68常规版.config" "/home/zhouwei/immortalwrt-mt798x/.config"
        make menuconfig
        ;;
    42)
        cp "${src_dir}/config_generate-NB68" "${base_files_dir}/config_generate"
        cp "${src_dir}/mtwifi-NB68.sh" "${mtwifi_dir}/mtwifi.sh"
        cp "${src_dir}/bg11.jpg" "/home/zhouwei/immortalwrt-mt798x/feeds/luci/themes/luci-theme-argon/htdocs/luci-static/argon/img/bg1.jpg"
        cp "${src_dir}/NB68纯净版.config" "/home/zhouwei/immortalwrt-mt798x/.config"
        make menuconfig
        ;;
    51)
        cp "${src_dir}/config_generate-C5800" "${base_files_dir}/config_generate"
        cp "${src_dir}/mtwifi-C5800.sh" "${mtwifi_dir}/mtwifi.sh"
        cp "${src_dir}/bg12.jpg" "/home/zhouwei/immortalwrt-mt798x/feeds/luci/themes/luci-theme-argon/htdocs/luci-static/argon/img/bg1.jpg"
        cp "${src_dir}/C5800常规版.config" "/home/zhouwei/immortalwrt-mt798x/.config"
        make menuconfig
        ;;
    52)
        cp "${src_dir}/config_generate-C5800" "${base_files_dir}/config_generate"
        cp "${src_dir}/mtwifi-C5800.sh" "${mtwifi_dir}/mtwifi.sh"
        cp "${src_dir}/bg12.jpg" "/home/zhouwei/immortalwrt-mt798x/feeds/luci/themes/luci-theme-argon/htdocs/luci-static/argon/img/bg1.jpg"
        cp "${src_dir}/C5800纯净版.config" "/home/zhouwei/immortalwrt-mt798x/.config"
        make menuconfig
        ;;
    61)
        cp "${src_dir}/config_generate-688" "${base_files_dir}/config_generate"
        cp "${src_dir}/mtwifi-688.sh" "${mtwifi_dir}/mtwifi.sh"
        cp "${src_dir}/bg11.jpg" "/home/zhouwei/immortalwrt-mt798x/feeds/luci/themes/luci-theme-argon/htdocs/luci-static/argon/img/bg1.jpg"
        cp "${src_dir}/688常规版.config" "/home/zhouwei/immortalwrt-mt798x/.config"
        make menuconfig
        ;;
    62)
        cp "${src_dir}/config_generate-688" "${base_files_dir}/config_generate"
        cp "${src_dir}/mtwifi-688.sh" "${mtwifi_dir}/mtwifi.sh"
        cp "${src_dir}/bg11.jpg" "/home/zhouwei/immortalwrt-mt798x/feeds/luci/themes/luci-theme-argon/htdocs/luci-static/argon/img/bg1.jpg"
        cp "${src_dir}/688纯净版.config" "/home/zhouwei/immortalwrt-mt798x/.config"
        make menuconfig
        ;;
    7)
        ./Addapplications.sh
        ;;   
    *)
        echo "无效的选项，请重新运行脚本并输入有效数字（0-6）。"
        ;;
esac

echo "开始执行菜单编辑器"

