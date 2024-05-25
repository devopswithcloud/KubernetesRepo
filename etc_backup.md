```bash
# Download etcdctl

# Do remember , there is no need to do this step in exam. It will be already be available in the cluster
wget https://github.com/etcd-io/etcd/releases/download/v3.4.32/etcd-v3.4.32-linux-amd64.tar.gz
untar etcd-v3.4.32-linux-amd64.tar.gz
cp etcd-v3.4.32-linux-amd64/etcd* /usr/bin/

# get the files path
cat /etc/kubernetes/manifests/etcd.yaml | grep -i files*

# Mention the path to store the snapshot, take the one mentioned in the exam
ETCDCTL_API=3 etcdctl --endpoints=https://127.0.0.1:2379 --cacert=/etc/kubernetes/pki/etcd/ca.crt --cert=/etc/kubernetes/pki/etcd/server.crt --key=/etc/kubernetes/pki/etcd/server.key snapshot save newbackup.db


kubectl delete deploy backupdeploy


# Mention the path to retrive the snapshot, take the one mentioned in the exam .
# --data-dir , check if its available , else u can bypass it 
ETCDCTL_API=3 etcdctl --endpoints=https://127.0.0.1:2379 --cacert=/etc/kubernetes/pki/etcd/ca.crt --cert=/etc/kubernetes/pki/etcd/server.crt --key=/etc/kubernetes/pki/etcd/server.key  --data-dir=/var/lib/etcd-backup snapshot restore newbackup.db


# modify the etcd file
vi /etc/kubernetes/manifests/etcd.yaml
# make sure u add the volume level not the mount level
  - hostPath:
      path: /var/lib/etcd-backup
```
