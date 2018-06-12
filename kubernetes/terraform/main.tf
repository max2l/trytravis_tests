resource "google_container_cluster" "puma" {
  name               = "puma-kubernates"
  zone               = "us-central1-a"
  initial_node_count = 1
  project = "${var.gcp_project}"
 
 
  node_config {
    oauth_scopes = [
      "https://www.googleapis.com/auth/compute",
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]
    
  machine_type     = "${var.gcp_machime_type}"
  disk_size_gb     = "20"
    
    labels {
      app = "reddit"
    }
  }
}

resource "google_compute_firewall" "firewall_rule_kubernetes" {
  name    = "kuber-firewall"
  network = "default"
  project = "${var.gcp_project}"

  allow {
    protocol = "tcp"
    ports    = ["30000-32767"]
  }

  description   = "Create the firewall rule for access to kubernetes."
  source_ranges = ["0.0.0.0/0"]
}
