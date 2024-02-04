```bash
# Mention the path to store the snapshot, take the one mentioned in the exam
ETCDCTL_API=3 etcdctl --endpoints=https://127.0.0.1:2379 --cacert=/etc/kubernetes/pki/etcd/ca.crt --cert=/etc/kubernetes/pki/etcd/server.crt --key=/etc/kubernetes/pki/etcd/server.key snapshot save newbackup.db

# Mention the path to retrive the snapshot, take the one mentioned in the exam .
# --data-dir , check if its available , else u can bypass it 
ETCDCTL_API=3 etcdctl --endpoints=https://127.0.0.1:2379 --cacert=/etc/kubernetes/pki/etcd/ca.crt --cert=/etc/kubernetes/pki/etcd/server.crt --key=/etc/kubernetes/pki/etcd/server.key  snapshot restore newbackup.db


```
