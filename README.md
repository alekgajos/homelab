# homelab
Personal mini-homelab setup configuration.

Features:

* VPN access with Wireguard,
* Terraform-managed virtual K3s cluster composed of Incus/LXC containers,
* Apps deployed to the K3s cluster:
    * Bookstack,
    * Joplin server,
* Firewall configuration with Netfilter.

## Overview:

The homelab is a single PC running Debian Linux which acts as:

* gateway to services running in LXC containers with NFT firewall and VPN access,

* host for Incus containers constituting a K3s cluster as well as other special-purpose Incus containers such as dev environments etc.

The Incus containers are managed with Terraform using [terraform-provider-incus](https://registry.terraform.io/providers/lxc/incus/latest/docs).
