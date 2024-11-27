#By:Manper-20241106
# atsd_tools
网口AT操作中心
# 配置文件说明
 - 路径 /etc/config/atsd_tools
 - 通道 —— sectiontype为 channel配置块是通道参数，支持多通道,model指定为rule存在模组类型可以直接调用rule配置，但是通道参数优先级高于模块配置
 - 模组配置 —— sectiontype为 rule配置块是模组具体参数信息
# 调度说明
 - /etc/init.d/atsd_tools 负责守护方式启动,-d 参数开启DEBUG,-l 调整默认日志等级
# 功能介绍
获取模块基本信息以及提供AT操作；

采用ubus通信机制；

由atsd_tools一个守护进程，一个AT请求工具；前者负责AT操作环境，并生成特定基础信息，后者负责供外部调用执行AT请求,以下指令中XXXXX为配置块中通道的名称如：cpe

atsd_tools守护运行；
 - ubus path为atsdXXXXX；
 - ubus method；
 -    at_cmd，AT命令响应接口 ，参数cmd（AT命令，必配）,wait（AT等待最大时长默认200ms,单位毫秒）,at_log_level（单个指令AT日志等级，系统默认日志等级LOG_NOTICE）,block（命令执行完毕通道sleep阻塞时长,单位秒），如：
        ubus call atsdXXXXX at_cmd "{'cmd':'AT+CPIN?'}"
 - ubus event
 -    通道重置事件消息 atsd.XXXXX.reset 

atsd_tools_cli单次运行，通过传参执行AT，通过标准输出返回AT结果；
 - 参数说明 -c 通道参数必配，-i AT命令,-w 指令最大等待时长(默认200ms),-W （命令执行完毕通道sleep阻塞时长,单位秒）
 - 示例atsd_tools_cli -c XXXXX -i "AT+CPIN?"；

