# Setup of apps running on a virtual Kubernetes cluster

## Initial setup

### Persistent volume for databases

The k3s cluster uses per-app directories inside `/data/kubernetes/` on the host which are exposed to the cluster as a PersistentVolume. As the volume is simply `local-storage`, is uses affinity to a single worker only (`k3s-worker0`) so that all DB services will end up running on that node.

Provision the per-app persistent volumes prior to creating the app deployments with:

```
kubectl apply -f db-volume.yaml
```

### App-specific secrets

Create secrets for Bookstack and LXM by filling in the following templates:

* `apps/bookstack/secrets.yaml`

* `apps/lxm/secrets.yaml`

Note that the secret values in these manifests must be base64-encoded.

Use e.g. the following to eoncode the values and take care not to include `echo`'s default newline in the encoded value:

```
echo -n "secret value" | base64
```

Finally, apply the above manifests to create the secrets.

### App services and deployments

Each of the apps running on the cluster is represented by a directory in `kubernetes/apps`. Inside each of these directories, there is a self-contained manifest file named `all.yaml` which needs to be applied in order to create the app's service, deployment and PVC-s.
