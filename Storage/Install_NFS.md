## Configuring NFS Storage PV

## **`Install the software on your master node `**
- Install the software on your master node
```
sudo apt-get update && sudo apt-get install -y nfs-kernel-server
```

- Make and populate a directory to be shared. Also give it proper permissions
```
$ sudo mkdir /opt/sfw 
$ sudo chmod 1777 /opt/sfw/ 
$ echo software > /opt/sfw/hello.txt
```

- Edit the NFS server file to share out the newly created directory. In this case we will share the directory with all. Vim the file and add the below line
```
$ sudo vim /etc/exports

/opt/sfw/ *(rw,sync,no_root_squash,subtree_check)
```

- Cause /etc/exports to be re-read
```
$ sudo exportfs -ra
```

## **`Testing By Mounting Resource To Worker Nodes `**
- ssh to worker node : worker1 [Switcing to the Worker Node]
- Install nfs software on the worker nodes
```
$ sudo apt-get -y install nfs-common
```

- Test by mounting the /opt/sfw path to /mnt. Use kubeadm-master server’s public IP Address
```
$ sudo mount <publicIp_NFSServer>:/opt/sfw /mnt
$ ls -l /mnt
```

### **` Note: Exit back to the Master node after performing the above Task 2 steps on both the worker nodes `**