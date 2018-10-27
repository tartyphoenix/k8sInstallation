
for svc in etcd kube-apiserver kube-controller-manager kube-scheduler kube-proxy kubelet flanneld; do
  systemctl restart $svc
  systemctl enable $svc
  systemctl status $svc
done
