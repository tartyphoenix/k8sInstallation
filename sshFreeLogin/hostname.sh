ips=`awk '{print $1}' ./ip.txt`
hosts=`awk '{printf("%s\t%s\n", $1, $2)}' ./ip.txt`"\n127.0.0.1\tlocalhost\n"
echo -e "$hosts" > /etc/hosts
rm -rf /root/authen.pub /root/.ssh/authorized_keys
touch /root/authen.pub

for ip in $ips;
do   
  host=`awk '/'$ip'/ {print $2}' ./ip.txt`
  passwd=`awk '/'$ip'/ {print $3}' ./ip.txt`
  expect -c "
  spawn scp /etc/hosts root@$ip:/etc/hosts
  expect \"password: \" {send \"$passwd\r\"}
  interact
  "
  expect -c "
    spawn ssh root@$ip
    expect {
      \"yes/no\" {send \"yes\r\"}
      \"password: \" {send \"$passwd\r\"}
    }
    expect \"\# \" {send \"rm -rf /root/.ssh/authorized_keys\r\"}
    expect \"\# \" {send \"touch /root/.ssh/authorized_keys\r\"}
    expect \"\# \" {send \"chmod 600 /root/.ssh/authorized_keys\r\"}
    expect \"\# \" {send \"hostnamectl set-hostname $host\r\"}
    expect \"\# \" {send \"cd /root/.ssh\rrm -rf id_rsa.pub id_rsa\rssh-keygen -t rsa\r\"}
    expect \"/id_rsa): \" {send \"\r\"}
    expect \"passphrase): \" {send \"\r\"}
    expect \"passphrase again: \" {send \"\r\"}
    expect \"\# \" {send \"exit\r\"}
    interact
  "
  expect -c "
  spawn scp root@$ip:/root/.ssh/id_rsa.pub /root/id_rsa.pub
  expect \"password: \" {send \"$passwd\r\"}
  interact
  "
  cat /root/id_rsa.pub >> /root/authen.pub 
  rm -rf id_rsa.pub
done
for ip in $ips;
do
  passwd=`awk '/'$ip'/ {print $3}' ./ip.txt`
  expect -c "
    spawn scp /root/authen.pub root@$ip:/root/.ssh/authorized_keys
    expect \"password: \" {send \"$passwd\r\"}
    interact
  " 
done
rm -rf /root/authen.pub
