for svc in kube-proxy kubelet flanneld;
do
  systemctl start $svc
  systemctl enable $svc
  systemctl status $svc
done
