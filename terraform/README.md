## Setting up Kubernetes

### Setting up kubectl access from the host

Copy the kubectl config file to the host
```
lxc exec k3s-master cat /etc/rancher/k3s/k3s.yaml > ~/.kube/config
```
and edit the file to change `cluster.server` IP address from localhost
to the address of `k3s-master`.
