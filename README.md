# homelab

Personal mini-homelab setup configuration.

Features:

* VPN access with [Wireguard](https://www.wireguard.com/),
* Terraform-managed virtual K3s cluster composed of [Incus](https://linuxcontainers.org/incus/introduction/)/[LXC](https://linuxcontainers.org/lxc/introduction/) containers,
* Apps deployed to the K3s cluster:
  * [Bookstack](https://www.bookstackapp.com/),
  * [Joplin](https://joplinapp.org/) server,
* Firewall configuration with Nftables.

## Overview

The homelab is a single PC running Debian Linux which acts as:

* gateway to services running in LXC containers with NFT firewall and VPN access,

* host for Incus containers constituting a K3s cluster as well as other special-purpose Incus containers such as dev environments etc.

The Incus containers are managed with Terraform using [terraform-provider-incus](https://registry.terraform.io/providers/lxc/incus/latest/docs).

## Contents

* [kubernetes](kubernetes/README.md) - manifest files for infrastructure and services running in the virtual cluster,

* [terraform](terraform/README.md) - TF configuration of the machines comprising the cluster.

## TODO

* [ ] Kubernetes log aggregation
* [ ] Reverse proxy for services running in the cluster
