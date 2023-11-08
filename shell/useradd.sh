#!/bin/bash
> /root/user.ldif
> /root/group.ldif
> /root/modify.ldif
read -p "请输入用户名: " uname
read -p "请输入组名:" groupname
read -p "请输入管理员密码: " passwd
if [ -n $uname ] && [ -n $groupname ];then
	result=`ldapsearch -x -b cn=$groupname,ou=Group,dc=cs,dc=cn | grep result: | awk '{ print $3 }'`
	gid=`ldapsearch -x -LLL -b cn=$groupname,ou=Group,dc=cs,dc=cn  | grep gidNumber | awk '{ print $2 }'`
	`useradd $uname`
	if [ $? -eq 0 ] && [ "$result" = "Success" ];then
		uid=`id -u $uname`
		`userdel -rf $uname`
	 	echo "dn: uid=$uname,ou=People,dc=cs,dc=cn">>user.ldif
		echo "objectClass: inetOrgPerson">>user.ldif
		echo "objectClass: posixAccount">>user.ldif
		echo "objectClass: shadowAccount">>user.ldif
		echo "uid: $uname">>user.ldif
		echo "cn: $uname">>user.ldif
		echo "sn: $uname">>user.ldif
		echo "userPassword: 123456">>user.ldif
		echo "uidNumber: $uid">>user.ldif
		echo "gidNumber: $gid">>user.ldif
		echo "loginShell: /bin/bash">>user.ldif
		echo "homeDirectory: /home/$groupname/$uname">>user.ldif
	
		Flag=`ldapadd -x -D cn=csadmin,dc=cs,dc=cn -w $passwd -f user.ldif`

		 echo "dn: cn=$groupname,ou=Group,dc=cs,dc=cn" >> modify.ldif
                 echo "changetype: modify" >> modify.ldif
                 echo "add: memberuid" >> modify.ldif
                 echo "memberuid: $uname" >> modify.ldif

		Flag=`ldapadd -x -D cn=csadmin,dc=cs,dc=cn -w $passwd -f modify.ldif`

		
		mkdir /home/$groupname/$uname
		chown $uname:$groupname /home/$groupname/$uname
		chmod 750 /home/$groupname/$uname	
	else
		echo "创建不成功,用户名存在或添加的组不存在"
	fi
else
	echo "输入不能为空"
fi
