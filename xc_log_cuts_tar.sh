#!/bin/bash
source /etc/profile
############################################################################################
#                                                                                          #
# Author: xiao.li                                                                          #
# Date: 2018-07-27                                                                         #
# version:0.01.0                                                                           #
# Description: 业务日志割脚本                                                              #
# Alter:                                                                                   #
############################################################################################

for log_path in $(find /data/www/*/storage/logs -type d)
do
    sh /data/script/log_cuts_tar.sh ${log_path}
done
