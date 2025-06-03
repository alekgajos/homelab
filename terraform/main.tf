terraform {
  required_providers {
    incus = {
      source = "lxc/incus"
    }
  }
}

resource "incus_profile" "k3s-profile" {
  name = "k3s-container-profile"

  config = {
    "boot.autostart" = true
    "security.privileged" = true
      "raw.lxc" = <<EOF
      lxc.apparmor.profile = unconfined
      lxc.cgroup.devices.allow = a
      lxc.cap.drop =
      lxc.mount.auto = proc:rw sys:rw
      EOF
  }

  device {
    type = "disk"
    name = "root"

    properties = {
      pool = incus_storage_pool.pool_k3s.name
      path = "/"
    }
  }

  device {
    type = "nic" 
    name = "eth0"
    properties = {
      network = "incusbr0"
    }
  }
}

resource "incus_profile" "k3s-init" {
  name = "k3s-container-profile-init"

  #  config = {
  #    "cloud-init.user-data" = <<-EOF
  #    #cloud-config
  #    runcmd:
  #      - echo 'L /dev/kmsg - - - - /dev/null' > /etc/tmpfiles.d/kmsg.conf
  #    users:
  #      - name: alek
  #      - sudo: ALL=(ALL) NOPASSWD:ALL
  #      - groups: [users, admin]
  #      - shell: /bin/bash
  #    EOF
  #  }
}

resource "incus_profile" "k3s-master-config" {
  name = "k3s-master-config"

  config = {
    "cloud-init.user-data" = <<-EOF
    #cloud-config
    runcmd:
      - echo 'L /dev/kmsg - - - - /dev/null' > /etc/tmpfiles.d/kmsg.conf
      - systemd-tmpfiles --create
      - apt-get -y install curl
      - curl -sfL https://get.k3s.io | sh -
    EOF
  }
}

resource "incus_profile" "k3s-worker-config" {
  name = "k3s-worker-config"

  config = {
    "cloud-init.user-data" = <<-EOF
    #cloud-config
    runcmd:
      - echo 'L /dev/kmsg - - - - /dev/null' > /etc/tmpfiles.d/kmsg.conf
      - systemd-tmpfiles --create
      - apt-get -y install curl
      - curl -sfL https://get.k3s.io | K3S_URL="https://${incus_instance.k3s_master.ipv4_address}:6443" K3S_TOKEN="${chomp(data.local_file.k3s_token.content)}" sh -s -- agent
    EOF
  }
}

resource "incus_storage_pool" "pool_k3s" {
  name   = "pool_k3s"
  driver = "dir"
  config = {
    source = "/var/lib/incus/storage-pools/pool_k3s"
  }
}

resource "incus_instance" "k3s_master" {
  name = "k3s-master"
  image = "images:debian/13/cloud"
  profiles  = [incus_profile.k3s-profile.name, incus_profile.k3s-init.name, incus_profile.k3s-master-config.name]

  provisioner "local-exec" {
    command = "until incus file pull k3s-master/var/lib/rancher/k3s/server/token /tmp/k3s_token;do sleep 1;done"
    when = create
  }

  device {
    name = "kubernetes_volume"
    type = "disk"
    properties = {
      path   = "/data/kubernetes"
      source = "/data/kubernetes"
      shift = true
    }
  }
}

data "local_file" "k3s_token" {
  filename = "/tmp/k3s_token"
  depends_on = [incus_instance.k3s_master]
}

resource "incus_instance" "k3s_worker" {
  count = 2
  name = "k3s-worker${count.index}"
  image = "images:debian/13/cloud"
  profiles  = [incus_profile.k3s-profile.name,
                incus_profile.k3s-init.name,
                incus_profile.k3s-worker-config.name]

  device {
    name = "kubernetes_volume"
    type = "disk"
    properties = {
      path   = "/data/kubernetes"
      source = "/data/kubernetes"
      shift = true
    }
  }
}

