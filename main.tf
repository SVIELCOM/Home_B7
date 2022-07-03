terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "0.68.0"
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
    cores         = 2
    memory        = 4
    core_fraction = 20
  }

  scheduling_policy {
    preemptible = true
  }

  boot_disk {
    initialize_params {
      # ubuntu 20-04
      image_id = "ubuntu-20-04-lts-v20220620"
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
    cores         = 2
    memory        = 2
    core_fraction = 20
  }

  scheduling_policy {
    preemptible = true
  }

  boot_disk {
    initialize_params {
      # ubuntu 20-04
      image_id = "ubuntu-20-04-lts-v20220620"
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
    host1 = join("", [yandex_compute_instance.node1.network_interface[0].nat_ip_address])
    host2 = join("", [yandex_compute_instance.node2.network_interface[0].nat_ip_address])
  }
}

resource "local_file" "save_inventory" {
  content  = data.template_file.inventory.rendered
  filename = "./inventory"
}
