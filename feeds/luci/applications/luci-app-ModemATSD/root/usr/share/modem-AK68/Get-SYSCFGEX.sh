#!/bin/bash
output=$(atsd_tools_cli -i cpe -c 'AT^SYSCFGEX?')
netser=$(echo "$output" | awk -F', *' '/^\^SYSCFGEX:/ {print substr($0, index($0,$2))}')
echo "$netser"
