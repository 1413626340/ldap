#!/bin/bash
>/root/modify.ldif
read -p "请输入需要删除的用户 " userName
if [ -n $userName ];then
	CC=`id $userName`
	if [ $? -eq 0 ];then
		groupList=`groups $userName | cut -d : -f 2 `
		for groupName in ${groupList}
		do
                 echo "dn: cn=$groupName,ou=Group,dc=cs,dc=cn" >> modify.ldif
                 echo "changetype: modify" >> modify.ldif
                 echo "delete: memberuid" >> modify.ldif
                 echo "memberuid: $userName" >> modify.ldif
		 `ldapadd -x -D cn=csadmin,dc=cs,dc=cn -w 123456 -f modify.ldif`
		rm -rf /home/$groupName/$userName	
		done
 		`ldapdelete -x -D cn=csadmin,dc=cs,dc=cn -w 123456 "uid=$userName,ou=People,dc=cs,dc=cn"`
	else
		echo "该用户名不存在"
	fi
else
	echo "输入不能为空"
fi 
