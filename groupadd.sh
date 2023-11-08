#!/bin/bash
> /root/group.ldif
read -p "请输入组名: " groupName
read -p "请输入部门名: " departName 
if [ -n "$groupName" ];then
   `ldapsearch -x -LLL -b cn=$groupName,ou=Group,dc=cs,dc=cn`

   if [ $? -eq  0 ];then
   	echo "该组已存在"
   else
	`groupadd $groupName`
	groupID=`cat /etc/group | grep $groupName | awk -F: '{ print $3 }'`
	`groupdel $groupName`
	echo "dn: cn=$groupName,ou=Group,dc=cs,dc=cn" >> group.ldif
	echo "objectClass: posixGroup" >> group.ldif
	echo "cn: $groupName" >> group.ldif
	echo "gidNumber: $groupID" >> group.ldif
   
	if [ -z "$departName" ];then
   		echo "description;lang-department: 空" >> group.ldif  
	else
		echo "description;lang-department: $departName" >> group.ldif
	fi
   	
	Flag=`ldapadd -x -D cn=csadmin,dc=cs,dc=cn -w 123456 -f group.ldif`
	mkdir -p /home/$groupName
	chmod 750 /home/$groupName
	
   fi

else
   echo "输入不允许为空"
fi
