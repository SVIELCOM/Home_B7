terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "0.78.2"
    }
  }
}

provider "yandex" {
  service_account_key_file = "./keys/yandex/key.json"
  cloud_id                 = "b1gm927ukaa70tqajugl"
  folder_id                = "b1gc6voj6kklco2mpnnn"
  zone                     = "ru-central1-a"
}

resource "yandex_compute_instance" "node1" {
  name        = "node1"
  platform_id = "standard-v3"
  resources {
    cores         = 4
    memory        = 4
    core_fraction = 100 #must be 100 to avoid Kubernetes cluster initialization errors
  }

  scheduling_policy {
    preemptible = false
  }

  boot_disk {
    initialize_params {
      # ubuntu 20-04
      image_id = "fd8kdq6d0p8sij7h5qe3"
      size     = 20
      type     = "network-ssd"
    }
  }


  network_interface {
    subnet_id = "e9bp42kcejc94uaga548"
    nat       = true
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }
}

resource "yandex_compute_instance" "node2" {
  name        = "node2"
  platform_id = "standard-v3"
  resources {
    cores         = 4
    memory        = 4
    core_fraction = 100
  }

  scheduling_policy {
    preemptible = false
  }

  boot_disk {
    initialize_params {
      # ubuntu 20-04
      image_id = "fd8kdq6d0p8sij7h5qe3"
      size     = 20
      type     = "network-hdd"
    }
  }


  network_interface {
    subnet_id = "e9bp42kcejc94uaga548"
    nat       = true
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }
}


data "template_file" "inventory" {
  template = file("./terraform/_templates/inventory.tpl")

  vars = {
    user  = "ubuntu"
    host1 = "k8s-master.svielcom.ru"
    host2 = "k8s-worker.svielcom.ru"
  }
}

resource "local_file" "save_inventory" {
  content  = data.template_file.inventory.rendered
  filename = "./inventory"
}

resource "yandex_dns_recordset" "rs1" {
  zone_id = "dnsebj4b7b4lgrscdiqf"
  name    = "k8s-master.svielcom.ru."
  type    = "A"
  ttl     = 200
  data    = [yandex_compute_instance.node1.network_interface[0].nat_ip_address]
}

resource "yandex_dns_recordset" "rs2" {
  zone_id = "dnsebj4b7b4lgrscdiqf"
  name    = "k8s-worker.svielcom.ru."
  type    = "A"
  ttl     = 200
  data    = [yandex_compute_instance.node2.network_interface[0].nat_ip_address]
}

resource "yandex_dns_recordset" "rs1local" {
  zone_id = "dnsegj1k94sca91qdfbc"
  name    = "k8s-master.svielcom.ru."
  type    = "A"
  ttl     = 200
  data    = [yandex_compute_instance.node1.network_interface[0].ip_address]
}

resource "yandex_dns_recordset" "rs2local" {
  zone_id = "dnsegj1k94sca91qdfbc"
  name    = "k8s-worker.svielcom.ru."
  type    = "A"
  ttl     = 200
  data    = [yandex_compute_instance.node2.network_interface[0].ip_address]
}

