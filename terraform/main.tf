provider "google" {
  version = "1.4.0"
  project = "${var.project}"
  region  = "${var.region}"
}

resource "google_compute_instance" "runner" {
  name         = "docker-runner-${count.index}"
  machine_type = "g1-small"
  zone         = "${var.zone}"

  count = "${var.count_instances}"

  connection {
    type        = "ssh"
    user        = "docker-user"
    agent       = false
    private_key = "${file(var.private_key_path)}"
  }

  boot_disk {
    initialize_params {
      image = "${var.disk_image}"
    }
  }

  network_interface {
    network       = "default"
    access_config = {}
  }

  tags = ["docker-runner"]

  provisioner "remote-exec" {
    script = "files/deploy.sh"
  }

}

resource "google_compute_project_metadata_item" "default" {
  key   = "ssh-keys"
  value = "docker-user:${file(var.public_key_path)}}"
}
