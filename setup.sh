#!/bin/bash

_RootNeed () {
    if [[ $EUID -ne 0 ]]; then
        echo "错误：请以管理员权限运行！" 1>&2
        exit 1
    fi
}

_ReleaseQuery () {
	source /etc/os-release
	case $ID in
	debian|ubuntu|devuan)
	    Install_command=apt-get
	    ;;
	centos|fedora|rhel)
	    Install_command=yum
	    if test "$(echo "$VERSION_ID >= 22" | bc)" -ne 0; then
	        Install_command="dnf"
	    fi
	    ;;
	*)
		echo "抱歉，当前发行版不支持自动安装，请手动安装以下依赖项：\n    $Requirement_need"
	    exit 1
	    ;;
	esac
}


_AutoInstallRequirement () {
	read Pick
	[[ -z $Pick ]] && Pick=yes
	case $Pick in
		Y|y|yes|YES|Yes)
			echo -n "正在安装: $Requirement_need ..."
			_ReleaseQuery
			$Install_command install $Requirement_need -y 2>&1 1>/dev/null

			if [[ $? == 0 ]]
			then
				echo -e "\r已安装以下依赖：$Requirement_need\n"
			else
				echo -e "\r自动安装发生错误，请手动安装以下依赖：\n    $Requirement_need"
				exit 1
			fi
			;;
		N|n|no|No|NO)
			exit 0
			;;
		*)
			echo -n "输入错误，请重新输入[Y/N]："
			_AutoInstallRequirement
	esac
}
		

_TestComponent () {
	Requirement_need=""
	[[ ! `command -v pngquant` ]]  && Requirement_need="$Requirement_need pngquant"
	[[ ! `command -v inotifywait` ]]  && Requirement_need="$Requirement_need inotify-tools"
	[[ ! `command -v jpegoptim` ]] && Requirement_need="$Requirement_need jpegoptim"
	if [[ ! -z $Requirement_need ]]
	then
		echo -ne "检测到当前系统缺少以下依赖： $Requirement_need\n\n是否执行自动安装[Y/N]? "
		_AutoInstallRequirement
	fi
}

_Install () {
	if [[ -f /etc/systemd/system/acp.service ]]
	then
		echo "检测到已安装ACP，再次安装将覆盖原安装文件，按下Ctrl+C可退出"
		ACP_Installed=true
	else
		echo "请选择监听的文件夹。如果该文件夹不存在，将自动创建"
	fi

	echo -ne "请输入文件夹的绝对路径（默认为：/home/$Username/pictures/acp）："
	read Monitor_dir
	[[ -z $Monitor_dir ]] && Monitor_dir=/home/$Username/pictures/acp
	[[ ! -d $Monitor_dir ]] && sudo -u $Username mkdir -p $Monitor_dir

	cp acp.service acp.service_tmp
	sed -ri "s#(acp.sh ).*#\1${Monitor_dir}#" acp.service_tmp
	sed -i "s#root#${Username}#g" acp.service_tmp

	[[ ! -d /usr/local/sbin/wenjinyu ]] && mkdir -p /usr/local/sbin/wenjinyu
	cp acp.sh /usr/local/sbin/wenjinyu/acp.sh
	mv acp.service_tmp /etc/systemd/system/acp.service
	[[ $ACP_Installed ]] && systemctl daemon-reload && systemctl restart acp || systemctl start acp
	systemctl enable acp 2>/dev/null

	[[ $? == 0 ]] && echo "ACP安装成功！" || echo "ACP安装失败"
}

_Uninstall () {
	systemctl stop acp 2>/dev/null
	systemctl disable acp 2>/dev/null 1>/dev/null
	rm /usr/local/sbin/wenjinyu/acp.sh 2>/dev/null
	if [[ "`ls -A /usr/local/sbin/wenjinyu/ 2>/dev/null 1>/dev/null`" = "" ]]
	then
		rm -rf /usr/local/sbin/wenjinyu/ 2>/dev/null
	fi
	rm /etc/systemd/system/acp.service 2>/dev/null
	[[ $? == 0 ]] && echo "ACP卸载完成！" || echo "ACP未安装！"
}


_RootNeed

ACP_Installed=false
Username=$SUDO_USER

if [[ -z $1 ]]
then
	_TestComponent
	_Install
elif [[ $1 == uninstall ]]; then
	_Uninstall
else
	echo -e "安装：\"./setup.sh\""
	echo -e "卸载：\"./setup.sh uninstall\""
fi