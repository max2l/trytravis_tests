resource "google_compute_instance" "db" {
  name         = "reddit-db"
  machine_type = "g1-small"
  zone         = "${var.zone}"
  tags         = ["reddit-db"]

  boot_disk {
    initialize_params {
      image = "${var.db_disk_image}"
    }
  }

  network_interface {
    network       = "default"
    access_config = {}
  }

  metadata {
    ssh-keys = "appuser:${file(var.public_key_path)}"
  }
}

resource "null_resource" "db" {
  count = "${var.deploy_mongodb ? 1 : 0}"

  triggers = {
    cluster_instance_ids = "${join(",", google_compute_instance.db.*.id)}"
  }

#  connection {
#    host = "${element(google_compute_instance.db.*.network_interface.0.access_config.0.assigned_nat_ip, 0)}"
#  }

  connection {
    host = "${element(google_compute_instance.db.*.network_interface.0.access_config.0.assigned_nat_ip, 0)}"
    type        = "ssh"
    user        = "appuser"
    private_key = "${file(var.private_key_path)}"
  }

  provisioner "remote-exec" {
    script = "${path.module}/files/install_mongodb.sh"
  }
}

resource "google_compute_firewall" "firewall_mongod" {
  name    = "allow-mongo-default"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["27017"]
  }

  target_tags = ["reddit-db"]                 
  source_tags = ["reddit-app"]
}
