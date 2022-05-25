#!/bin/bash


############################################################# 功能函数 Begin ##################################################################

        #显示消息
        #showType='errSysMsg/errSys/errUserMsg/warning/msg/msg2/OK'
        #错误输出（以红色字体输出） errSysMsg：捕捉系统错误后发现相信并退出；errSys：捕捉到系统错误后退出；errUserMsg：自定义错误并退出，但不退出（errSysMsg及errUserMsg可以赋第三个参数isExit为非1来控制不退出）
        #警告（以黄色字体输出）  warning：显示warning，但不退出
        #显示信息（以白色字体输出，OK以绿色输出） msg：输出信息并换行；msg2：输出信息不换行；OK：输出绿色OK并换行
        function showMsg()
        {
                errState="$?"
                local showType="$1"
                local showContent="$2"
                local isExit="$3"
                #如果isExit为空，则默认出错时该退出
                if [ "${isExit}" = "" ]; then
                        isExit=1
                fi
                local isIP=`echo ${mysqlHost} | grep -E "172|192|10" | wc -l`
                if [ "${mysqlHost}" = "localhost" ]; then
                        local showExtent="localhost.${siteId}"
                elif [ "${isIP}" -eq "1" ]; then
                        local showExtent="db1(${mysqlHost}).${siteId}"
                else
                        showExtent=''
                fi
                showType=`echo ${showType} | tr 'A-Z' 'a-z'`
                case "${showType}" in
                        errsysmsg)
                                if [ "${errState}" -ne 0 ]; then
                                        echo -e "\033[31;49;1m[`date +%F' '%T`] ${showExtent} Error: ${showContent}\033[39;49;0m" | tee -a ${logFile} >&2
                                        echo -e "\033[31;49;1m[`date +%F' '%T`] Call Relation: bash${pid}\033[39;49;0m" | tee -a ${logFile} >&2
                                        if [ "${isExit}" -eq 1 ]; then
                                                exit 1
                                        fi
                                fi
                        ;;
                        errsys)
                                if [ "$errState" -ne 0 ]; then
                                        exit 1
                                fi
                        ;;
                        errusermsg)
                                echo -e "\033[31;49;1m[`date +%F' '%T`] ${showExtent} Error: ${showContent}\033[39;49;0m"  | tee -a ${logFile} >&2
                                echo -e "\033[31;49;1m[`date +%F' '%T`] Call Relation: bash${pid}\033[39;49;0m" | tee -a ${logFile} >&2
                                if [ "${isExit}" -eq 1 ]; then
                                        exit 1
                                fi
                        ;;
                        warning)
                                echo -e "\033[33;49;1m[`date +%F' '%T`] ${showExtent} Warnning: ${showContent}\033[39;49;0m"  | tee -a ${logFile}
                                echo -e "\033[33;49;1m[`date +%F' '%T`] Call Relation: bash${pid}\033[39;49;0m"  | tee -a ${logFile}
                        ;;
                        msg)
                                echo "[`date +%F' '%T`] ${showExtent} ${showContent}" | tee -a ${logFile}
                        ;;
                        msg2)
                                echo -n "[`date +%F' '%T`] ${showExtent} ${showContent}" | tee -a ${logFile}
                        ;;
                        ok)
                                echo "OK" >> ${logFile}
                                echo -e "\033[32;49;1mOK\033[39;49;0m"
                        ;;
                        *)
                                echo -e "\033[31;49;1m[`date +%F' '%T`] Error: Call founction showMsg error\033[39;49;0m"  | tee -a ${logFile}
                                exit 1
                        ;;
                esac
        }

        function checkFileExist()
        {
                theFileName="$1"
                if [ ! -f $theFileName ]; then
                        showMsg "errUserMsg" "The file '$theFileName' is not exist."
                fi
        }


        function checkVar()
        {
                local theVar="$1"
                local theVar2="$2"
                if [ "${theVar2}" = "" ]; then
                        showMsg "errUserMsg" "The var '${theVar}' is not invalidation."
                fi
        }




############################################################# 功能函数 End ####################################################################

function shellInit()
{
        theFiledir=`echo $(cd "$(dirname "$0")"; pwd)`

        bak_date=`date "+%Y%m%d"`
        log_dir="/data/logs/ui_baklog/${bak_date}"
        if ! [ -d "$log_dir" ]; then
                mkdir -p $log_dir
        fi

        logFile="/data/logs/ui_baklog/ui_backup_${bak_date}.log"

}


function backup_fx()
{
        dir_status=$(ssh uibakuser@10.10.10.3 "sh /data/ht_tool/check_dir_fx.sh")
        if [ "$dir_status" == "ok" ]; then
                showMsg "msg" "----------------------------------"
                showMsg "msg" "开始备份飞仙项目 [fx] ui文件"
                if ! [ -d /data/del_bak/ui/fx/${bak_date} ]; then
                        mkdir -p /data/del_bak/ui/fx/${bak_date}
                fi
                sh /data/ht_tool/ui/ui_backup_fx.sh >> $log_dir/fx_rsync.log 2>&1
                showMsg "msg" "飞仙项目 [fx] ui文件备份完成"
        else
                showMsg "msg" "飞仙项目源服务器目录不存在!!!"
        fi
}


function backup_mhxx()
{
        dir_status=$(ssh uibakuser@10.10.10.3 "sh /data/ht_tool/check_dir_mhxx.sh")
        if [ "$dir_status" == "ok" ]; then
                showMsg "msg" "----------------------------------"
                showMsg "msg" "开始备份梦幻修仙项目 [mhxx] ui文件"
                if ! [ -d /data/del_bak/ui/mhxx/${bak_date} ]; then
                        mkdir -p /data/del_bak/ui/mhxx/${bak_date}
                fi
                sh /data/ht_tool/ui/ui_backup_qb.sh >> $log_dir/mhxx_rsync.log 2>&1
                showMsg "msg" "梦幻修仙项目 [mhxx] ui文件备份完成"
        else
                showMsg "msg" "梦幻修仙项目源服务器目录不存在!!!"
        fi
}


function backup_slls()
{
        dir_status=$(ssh uibakuser@10.10.10.3 "sh /data/ht_tool/check_dir_flzj.sh")
        if [ "$dir_status" == "ok" ]; then
                showMsg "msg" "----------------------------------"
                showMsg "msg" "开始备份神龙猎手项目 [flzj] ui文件"
                if ! [ -d /data/del_bak/ui/flzj/${bak_date} ]; then
                        mkdir -p /data/del_bak/ui/flzj/${bak_date}
                fi
                sh /data/ht_tool/ui/ui_backup_slls.sh >> $log_dir/flzj_rsync.log 2>&1
                showMsg "msg" "神龙猎手项目 [flzj] ui文件备份完成"
        else
                showMsg "msg" "神龙猎手项目源服务器目录不存在!!!"
        fi

}


function backup_xkx()
{
        dir_status=$(ssh uibakuser@10.10.10.3 "sh /data/ht_tool/check_dir_xkx.sh")
        if [ "$dir_status" == "ok" ]; then
                showMsg "msg" "----------------------------------"
                showMsg "msg" "开始备份侠客行项目 [xkx] ui文件"
                if ! [ -d /data/del_bak/ui/xkx/${bak_date} ]; then
                        mkdir -p /data/del_bak/ui/xkx/${bak_date}
                fi
                sh /data/ht_tool/ui/ui_backup_xkx.sh >> $log_dir/xkx_rsync.log 2>&1
                showMsg "msg" "侠客行项目 [xkx] ui文件备份完成"
        else
                showMsg "msg" "侠客行项目源服务器目录不存在!!!"
        fi
}


function backup_dwx()
{
        dir_status=$(ssh uibakuser@10.10.10.3 "sh /data/ht_tool/check_dir_dwx.sh")
        if [ "$dir_status" == "ok" ]; then
                showMsg "msg" "----------------------------------"
                showMsg "msg" "开始备份大武侠项目 [dwx] ui文件"
                if ! [ -d /data/del_bak/ui/dwx/${bak_date} ]; then
                        mkdir -p /data/del_bak/ui/dwx/${bak_date}
                fi
                sh /data/ht_tool/ui/ui_backup_dwx.sh >> $log_dir/dwx_rsync.log 2>&1
                showMsg "msg" "大武侠项目 [dwx] ui文件备份完成"
        else
                showMsg "msg" "大武侠项目源服务器目录不存在!!!"
        fi
}


function backup_f()
{
        dir_status=$(ssh uibakuser@10.10.10.3 "sh /data/ht_tool/check_dir_f.sh")
        if [ "$dir_status" == "ok" ]; then
                showMsg "msg" "----------------------------------"
                showMsg "msg" "开始备份F项目 [f] ui文件"
                if ! [ -d /data/del_bak/ui/f/${bak_date} ]; then
                        mkdir -p /data/del_bak/ui/f/${bak_date}
                fi
                sh /data/ht_tool/ui/ui_backup_f.sh >> $log_dir/f_rsync.log 2>&1
                showMsg "msg" "F项目 [f] ui文件备份完成"
        else
                showMsg "msg" "F项目源服务器目录不存在!!!"
        fi
}


function backup_dfh()
{
        dir_status=$(ssh uibakuser@10.10.10.3 "sh /data/ht_tool/check_dir_dfh.sh")
        if [ "$dir_status" == "ok" ]; then
                showMsg "msg" "----------------------------------"
                showMsg "msg" "开始备份大富豪 [dfh] ui文件"
                if ! [ -d /data/del_bak/ui/dfh/${bak_date} ]; then
                        mkdir -p /data/del_bak/ui/dfh/${bak_date}
                fi
                sh /data/ht_tool/ui/ui_backup_dfh.sh >> $log_dir/dfh_rsync.log 2>&1
                showMsg "msg" "大富豪 [dfh] ui文件备份完成"
        else
                showMsg "msg" "大富豪源服务器目录不存在!!!"
        fi
}


function backup_dfhh5()
{
        dir_status=$(ssh uibakuser@10.10.10.3 "sh /data/ht_tool/check_dir_dfhh5.sh")
        if [ "$dir_status" == "ok" ]; then
                showMsg "msg" "----------------------------------"
                showMsg "msg" "开始备份大富豪h5 [dfhh5] ui文件"
                if ! [ -d /data/del_bak/ui/dfhh5/${bak_date} ]; then
                        mkdir -p /data/del_bak/ui/dfhh5/${bak_date}
                fi
                sh /data/ht_tool/ui/ui_backup_dfhh5.sh >> $log_dir/dfhh5_rsync.log 2>&1
                showMsg "msg" "大富豪 [dfhh5] ui文件备份完成"
        else
                showMsg "msg" "大富豪h5源服务器目录不存在!!!"
        fi
}


function backup_fzwl()
{
        dir_status=$(ssh uibakuser@10.10.10.3 "sh /data/ht_tool/check_dir_fzwl.sh")
        if [ "$dir_status" == "ok" ]; then
                showMsg "msg" "----------------------------------"
                showMsg "msg" "开始备份放置武林 [fzwl] ui文件"
                if ! [ -d /data/del_bak/ui/fzwl/${bak_date} ]; then
                        mkdir -p /data/del_bak/ui/fzwl/${bak_date}
                fi
                sh /data/ht_tool/ui/ui_backup_fzwl.sh >> $log_dir/fzwl_rsync.log 2>&1
                showMsg "msg" "放置武林 [fzwl] ui文件备份完成"
        else
                showMsg "msg" "放置武林h5源服务器目录不存在!!!"
        fi
}


function backup_xhwx()
{
        dir_status=$(ssh uibakuser@10.10.10.3 "sh /data/ht_tool/check_dir_xhwx.sh")
        if [ "$dir_status" == "ok" ]; then
                showMsg "msg" "----------------------------------"
                showMsg "msg" "开始备份玄幻武侠 [xhwx] ui文件"
                if ! [ -d /data/del_bak/ui/xhwx/${bak_date} ]; then
                        mkdir -p /data/del_bak/ui/xhwx/${bak_date}
                fi
                sh /data/ht_tool/ui/ui_backup_xhwx.sh >> $log_dir/xhwx_rsync.log 2>&1
                showMsg "msg" "玄幻武侠 [xhwx] ui文件备份完成"
        else
                showMsg "msg" "玄幻武侠h5源服务器目录不存在!!!"
        fi
}


function backup_webgame_lz()
{
        dir_status=$(ssh uibakuser@10.10.10.3 "sh /data/ht_tool/check_dir_webgame_lz.sh")
        if [ "$dir_status" == "ok" ]; then
                showMsg "msg" "----------------------------------"
                showMsg "msg" "开始备份龙之领主页游 [lz] ui文件"
                if ! [ -d /data/del_bak/ui/lz/${bak_date} ]; then
                        mkdir -p /data/del_bak/ui/lz/${bak_date}
                fi
                sh /data/ht_tool/ui/ui_backup_webgame_lz.sh >> $log_dir/lz_rsync.log 2>&1
                showMsg "msg" "龙之领主页游 [lz] ui文件备份完成"
        else
                showMsg "msg" "龙之领主页游源服务器目录不存在!!!"
        fi
}


function backup_webgame_lz2()
{
        dir_status=$(ssh uibakuser@10.10.10.3 "sh /data/ht_tool/check_dir_webgame_lz2.sh")
        if [ "$dir_status" == "ok" ]; then
                showMsg "msg" "----------------------------------"
                showMsg "msg" "开始备份龙之领主2 [lz2] ui文件"
                if ! [ -d /data/del_bak/ui/lz2/${bak_date} ]; then
                        mkdir -p /data/del_bak/ui/lz2/${bak_date}
                fi
                sh /data/ht_tool/ui/ui_backup_webgame_lz2.sh >> $log_dir/lz2_rsync.log 2>&1
                showMsg "msg" "龙之领主2 [lz2] ui文件备份完成"
        else
                showMsg "msg" "龙之领主2源服务器目录不存在!!!"
        fi
}


function backup_meixuan()
{
        dir_status=$(ssh uibakuser@10.10.10.3 "sh /data/ht_tool/check_dir_meixuan.sh")
        if [ "$dir_status" == "ok" ]; then
                showMsg "msg" "----------------------------------"
                showMsg "msg" "开始备份美宣 [meixuan] ui文件"
                if ! [ -d /data/del_bak/ui/meixuan/${bak_date} ]; then
                        mkdir -p /data/del_bak/ui/meixuan/${bak_date}
                fi
                sh /data/ht_tool/ui/ui_backup_meixuan.sh >> $log_dir/meixuan_rsync.log 2>&1
                showMsg "msg" "美宣 [meixuan] ui文件备份完成"
        else
                showMsg "msg" "美宣源服务器目录不存在!!!"
        fi
}


function backup_ssb()
{
        dir_status=$(ssh uibakuser@10.10.10.3 "sh /data/ht_tool/check_dir_ssb.sh")
        if [ "$dir_status" == "ok" ]; then
                showMsg "msg" "----------------------------------"
                showMsg "msg" "开始备份ssb [ssb] ui文件"
                if ! [ -d /data/del_bak/ui/ssb/${bak_date} ]; then
                        mkdir -p /data/del_bak/ui/ssb/${bak_date}
                fi
                sh /data/ht_tool/ui/ui_backup_ssb.sh >> $log_dir/ssb_rsync.log 2>&1
                showMsg "msg" "ssb [ssb] ui文件备份完成"
        else
                showMsg "msg" "ssb源服务器目录不存在!!!"
        fi
}


function backup_tcg()
{
        dir_status=$(ssh uibakuser@10.10.10.3 "sh /data/ht_tool/check_dir_tcg.sh")
        if [ "$dir_status" == "ok" ]; then
                showMsg "msg" "----------------------------------"
                showMsg "msg" "开始备份tcg [tcg] ui文件"
                if ! [ -d /data/del_bak/ui/tcg/${bak_date} ]; then
                        mkdir -p /data/del_bak/ui/tcg/${bak_date}
                fi
                sh /data/ht_tool/ui/ui_backup_tcg.sh >> $log_dir/tcg_rsync.log 2>&1
                showMsg "msg" "tcg [tcg] ui文件备份完成"
        else
                showMsg "msg" "tcg源服务器目录不存在!!!"
        fi
}



function main()
{
        shellInit
        backup_fx
        backup_mhxx
        backup_slls
        backup_xkx
        backup_dwx
        backup_f
        backup_dfh
        backup_dfhh5
        backup_fzwl
        backup_xhwx
        backup_webgame_lz
        backup_webgame_lz2
        backup_meixuan
        backup_ssb
        backup_tcg
}

main $*
