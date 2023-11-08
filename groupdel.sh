#!/bin/bash
>modify.ldif
read -p "请输入想要删除的组名: " groupName
if [ -n $groupname ];then
	result=`ldapsearch -x -b  "cn=$groupName,ou=Group,dc=cs,dc=cn" | grep result: | awk '{ print $3 }'`
	if [ "$result"="Success" ];then
		Flag=`ldapsearch -x -LLL  -b  "cn=$groupName,ou=Group,dc=cs,dc=cn" | grep memberuid`
		if [  -z $Flag  ];then
			`ldapdelete -x -D cn=csadmin,dc=cs,dc=cn -w 123456 "cn=$groupName,ou=Group,dc=cs,dc=cn"`
		rm -rf /home/$groupName
			echo "已成功删除"
		else
			echo "该组依旧存在用户 无法删除"
		fi
	fi
else
 	echo "输入不能为空"
fi
