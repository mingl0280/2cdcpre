#!/bin/sh

#1、---------------------------------------------------------------------
echo "删除不用的帐号和组"
echo "delete unused users and grups"
for i in lp sync shutdown halt news uucp operator games gopher
do
echo "will delete user $i"
echo $i >> _delusr.fi
#userdel $i
echo "user $i have delete"
done
for i in lp sync shutdown halt news uucp operator games gopher
do
echo "will delete group $i"
echo $i >> _delgroup.fi
#groupdel $i
echo "group $i have delete"
done
date=`date +%F`
#2、-----------------------------------------------
#section1 密码要求密码长度大于8,口令90天过期/etc/login.defs
#-----------------------------------------------
#---------------------------------------------------------------------
echo "cp /etc/login.defs to /etc/login.defs.bak_%date"
echo "#-------------------------------------"
cp /etc/login.defs /etc/login.defs.bak_$date
#echo "检查密码的配置"
echo "Check the configure for user's password."
echo "#-------------------------------------"
for i in PASS_MAX_DAYS PASS_MIN_LEN PASS_MIN_DAYS PASS_WARN_AGE 
do
cat /etc/login.defs |grep $i|grep -v \#
done
#set password min length 8
echo "#-------------------------------------"
echo "Set user's password min length is 8"
sed  -i '/PASS_MIN_LEN/s/5/8/g' /etc/login.defs
echo "#-------------------------------------"
#set password max day 90
#echo "set password expired 90 day"
#sed  -i '/PASS_MAX_DAYS/s/99999/90/g' /etc/login.defs
#3、---------------------------------------------------------------------
echo "#检查是否存在空口令"
echo "Check if there have user without password!"
echo "#-------------------------------------"
awk -F: '($2 == "") { print $1 }' /etc/shadow
#4、-----------------------------------------------
#section2 限制root用户直接telnet或rlogin，ssh无效
######建议在/etc/securetty文件中配置：CONSOLE = /dev/tty01
#---------------------------------------------------------------------
#帐号与口令-检查是否存在除root之外UID为0的用户
#echo "#检查系统中是否存在其它id为0的用户"
echo "Check if the system have other user's id is 0"
echo "#-------------------------------------"
mesg=`awk -F: '($3 == 0) { print $1 }' /etc/passwd|grep -v root`
if [ -z $mesg ]
then
echo "There don't have other user uid=0"
else
echo
echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
echo "$mesg uid=0"
echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
fi


#5、---------------------------------------------------------------------
echo "#确保root用户的系统路径中不包含父目录，在非必要的情况下，不应包含组权限为777的目录"
echo "check the Path set for root,make sure the path for root dont have father directory and 777 rights"
echo "#-------------------------------------"
echo $PATH | egrep '(^|:)(\.|:|$)'
find `echo $PATH | tr ':' ' '` -type d \( -perm -002 -o -perm -020 \) -ls
#6、---------------------------------------------------------------------
echo "#检查操作系统Linux远程连接"
echo "Check if system have remote connection seting"
echo "#-------------------------------------"
find  / -name  .netrc
find  / -name  .rhosts 
echo "检查操作系统Linux用户umask设置"
echo "Check the system users umask setting"
echo "#-------------------------------------"
for i in /etc/profile /etc/csh.login /etc/csh.cshrc /etc/bashrc
do
grep -H umask $i|grep -v "#"
done
###################设置umask为027
#7、---------------------------------------------------------------------
#echo "#检查重要目录和文件的权限"
##echo "Check the important files and directory rights"
echo "#-------------------------------------"
for i in /etc /etc/rc.d/init.d /tmp /etc/inetd.conf /etc/passwd /etc/shadow /etc/group /etc/security /etc/services /etc/rc*.d
do
ls  -ld $i
done
echo -n "Please check if the output is ok ? yes or no :"
read i
case $i in 
y|yes)
break
;;
n|no)
echo "Please recheck the output!"
echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
continue
;;
*)
echo "please input yes or no"
;;
esac
#8、---------------------------------------------------------------------
#echo "#配置rc.d下脚本的权限"
echo "Configure the scripts right(750) in rc.d directory"
echo "#-------------------------------------"
chmod -R 750 /etc/rc.d/init.d/*
chmod 755 /bin/su 改了之后只能root su，没有了s位别的用户无法成功su
chmod 664 /var/log/wtmp
#chattr +a /var/log/messages
#9、---------------------------------------------------------------------
echo "#查找系统中存在的SUID和SGID程序"
echo "Find the files have suid or Sgid"
echo "#-------------------------------------"
for PART in `grep -v ^# /etc/fstab | awk '($6 != "0") {print $2 }'`; do
find $PART \( -perm -04000 -o -perm -02000 \) -type f -xdev -print |xargs ls  -ld
done
echo -n "Please check if the output is ok ? yes or no :"
read i
case $i in 
y|yes)
break
;;
n|no)
echo "Please recheck the output!"
echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
continue
;;
*)
echo "please input yes or no"
;;
esac


#10、---------------------------------------------------------------------  
echo "#查找系统中任何人都有写权限的目录"
echo "Find the directory everyone have the write right"
echo "#-------------------------------------"
for PART in `awk '($3 == "ext2" || $3 == "ext3") \
{ print $2 }' /etc/fstab`; do
find $PART -xdev -type d \( -perm -0002 -a ! -perm -1000 \) -print |xargs ls  -ld
done
echo -n "Please check if the output is ok ? yes or no :"
read i
case $i in 
y|yes)
break
;;
n|no)
echo "Please recheck the output!"
echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
continue
;;
*)
echo "please input yes or no"
;;
esac
#11、---------------------------------------------------------------------
#echo "#查找系统中任何人都有写权限的文件"
echo "Find the files everyone have write right"
echo "#-------------------------------------"
for PART in `grep -v ^# /etc/fstab | awk '($6 != "0") {print $2 }'`; do
find $PART -xdev -type f \( -perm -0002 -a ! -perm -1000 \) -print |xargs ls -ld
done
echo -n "Please check if the output is ok ? yes or no :"
read i
case $i in 
y|yes)
break
;;
n|no)
echo "Please recheck the output!"
echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
continue
;;
*)
echo "please input yes or no"
;;
esac
#12、---------------------------------------------------------------------  
echo "#查找系统中没有属主的文件"
echo "Find no owner or no group files in system"
echo "#-------------------------------------"
for PART in `grep -v ^# /etc/fstab |grep -v swap| awk '($6 != "0") {print $2 }'`; do
find $PART -nouser -o -nogroup |grep  -v "vmware"|grep -v "dev"|xargs ls  -ld
done
echo -n "Please check if the output is ok ? yes or no :"
read i
case $i in 
y|yes)
break
;;
n|no)
echo "Please recheck the output!"
echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
continue
;;
*)
echo "please input yes or no"
;;
esac
#13、---------------------------------------------------------------------  
###echo "#查找系统中的隐藏文件"
##echo " Find the hiding file in system"
##echo "#-------------------------------------"
###linux执行报错\排除/dev”目录下的那些文件
####find  / -name \(".. *"  -o "…*"  -o ".xx" -o ".mail" \) -print -xdev
## #find  / -name "…*" -print -xdev | cat -v
##find  /  \( -name ".*"  -o -name  "…*"  -o -name ".xx" -o -name ".mail" \) -xdev
##echo -n "If you have check all the output files if correct yes or no ? :"
##read i
## case $i in 
## y|yes)
## break
## ;;
## n|no)
## echo "Please recheck the output!"
## echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
## continue
## ;;
## *)
## echo "please input yes or no"
## ;;
## esac
##
#14、---------------------------------------------------------------------    
echo "#判断日志与审计是否合规"
echo "Judge if the syslog audition if follow the rules"
echo "#-------------------------------------"
autmesg=`cat /etc/syslog.conf |egrep ^authpriv`
if [ ! -n "$autmesg" ]
then
echo "there don't have authpriv set in /etc/syslog.conf"
echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
echo -n "If you have know this y or n ?"
read i
case $i in 
y|yes)
break
;;
n|no)
echo "there don't have authpriv set in /etc/syslog.conf"
echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
continue
;;
*)
echo "please input yes or no"
;;
esac
else
# echo "日志与审计合规"
echo "syslog audition follow the rules"
fi
#15、---------------------------------------------------------------------    
echo "#关闭linux core dump"
echo "Turn off the system core dump"
echo "#-------------------------------------"
mesg1=`grep "* soft core 0" /etc/security/limits.conf`
mesg2=`grep "* hard core 0" /etc/security/limits.conf`
if [ ! -n "$mesg1" -o ! -n "$mesg2" ]
then
cp /etc/security/limits.conf /etc/security/limits.conf_$date
if [ ! -n "$mesg1" ]
then
echo "* soft core 0" >> /etc/security/limits.conf
fi
if [ ! -n "$mesg2" ]
then
echo "* hard core 0" >> /etc/security/limits.conf
fi
fi
#修改login文件使limits限制生效
cp /etc/pam.d/login /etc/pam.d/login_$date
echo "session required /lib/security/pam_limits.so" >> /etc/pam.d/login
#16、---------------------------------------------------------------------   
#登录超时设置
#检查/etc/pam.d/system-auth文件是否存在account required /lib/security/pam_tally.so deny=的相关设置
#建议设置为auth required pam_tally.so onerr=fail deny=6 unlock_time=300
#17、---------------------------------------------------------------------   
#su命令使用,对su命令使用进行限制设置
#检查/etc/pam.d/su文件设置
#文件中包含
#auth sufficient /lib/security/pam_rootok.so debug
#auth required /lib/security/pam_wheel.so group=isd
#20、---------------------------------------------------------------------  
echo "#登录超时自动退出"
echo "set session time out terminal "
echo "#-------------------------------------"
tmout=`grep -i TMOUT /etc/profile`
if [ ! -n "$tmout" ]
then 
echo
echo -n "do you want to set login timeout to 300s? [yes]:"
read i
case $i in 
y|yes)
cp /etc/profile /etc/profile_$date
echo "export TMOUT=300" >> /etc/profile
. /etc/profile
;;
n|no)
break
;;
*)
echo "please input yes or no"
;;
esac
else 
mesg=`echo $tmout |awk -F"=" '{print $2}'`
if [ "$mesg" -ne 300 ]
then
echo "The login session timeout is $mesg now will change to 300 seconds"
cp /etc/profile /etc/profile_$date
echo "export TMOUT=300" >> /etc/profile
. /etc/profile
fi
fi
sed  -i 's/HISTSIZE=1000/HISTSIZE=100/g' /etc/profile
#21、---------------------------------------------------------------------  
echo "#禁用telnet启用ssh"
echo "Stop telnet and start up sshd"
echo "#-------------------------------------"
mesg1=`lsof -i:23`
mesg2=`lsof -i:22`
if [ ! -n "$mesg2" ]
then
service start sshd 
chkconfig sshd on
mesg2=`lsof -i:22`
fi
if [ ! -n "$mesg1" -a ! -n "$mesg2" ]
then 
echo 
echo "Will Deactive telnet"
    chkconfig krb5-telnet off
chkconfig ekrb5-telnet off
fi
#22、---------------------------------------------------------------------   
#echo "#设置终端超时，使系统10分钟后自动退出不活动的Shell"
#echo "#-------------------------------------"
#mesg=`grep "export TMOUT=600" /etc/profile`
#if [ -z $mesg ]
#then
#echo "export TMOUT=600" >>/etc/profile
#. /etc/profile
#fi
#23、---------------------------------------------------------------------  
echo "#禁用不必要的服务"
echo "Stop unuseing services"
echo "#-------------------------------------"
list="avahi-daemon bluetooth cups firstboot hplip iscsi iscsid isdn kudzu pcscd rhnsd rhsmcertd rpcgssd rpcidmapd sendmail smartd  yum-updatesd netfs portmap autofs nfslock nfs"
for i in $list
do
chkconfig $i off
service $i stop
done
echo "change kernel parameter for network secure"
cp  /etc/sysctl.conf /etc/sysctl.conf.$date
#echo "net.ipv4.icmp_echo_ignore_all = 1">>/etc/sysctl.conf
sysctl -a |grep arp_filter|sed -e 's/\=\ 0/\=\ 1/g' >>/etc/sysctl.conf
sysctl -a |grep accept_redirects|sed -e 's/\=\ 1/\=\ 0/g' >>/etc/sysctl.conf
sysctl -a |grep send_redirects|sed -e 's/\=\ 1/\=\ 0/g' >>/etc/sysctl.conf
sysctl -a |grep log_martians |sed -e 's/\=\ 0/\=\ 1/g'>>/etc/sysctl.conf
sysctl -p 
#24、---------------------------------------------------------------------  
echo "设置热键"
#ctrl+alt+del
if [ -d  /etc/init ]
then
sed  -i 's/^[^#]/#&/g' /etc/control-alt-delete.conf
else
sed -i 's/^ca::/#&/g' /etc/inittab
fi
#25、---------------------------------------------------------------------  
echo "demo:禁止除了db2inst1的用户su到root"
usermod -G wheel db2inst1
sed -i '/pam_wheel.so use_uid/s/^#//g' /etc/pam.d/su
echo "SU_WHEEL_ONLY yes">>/etc/login.defs  
