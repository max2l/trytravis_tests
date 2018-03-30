resource "google_compute_instance_group" "lb-instance-group" {
  name      = "lb-instance-group"
  instances = ["${google_compute_instance.app.*.self_link}"]
  zone      = "${var.zone}"

  named_port {
    name = "lb-puma-port"
    port = "9292"
  }
}

resource "google_compute_http_health_check" "lb-health-check" {
  name               = "lb-health-check"
  request_path       = "/"
  port               = "9292"
  check_interval_sec = 1
  timeout_sec        = 1
}

resource "google_compute_backend_service" "lb-backend-service" {
  name        = "lb-backend-service"
  port_name   = "lb-puma-port"
  protocol    = "HTTP"
  timeout_sec = 10

  health_checks = ["${google_compute_http_health_check.lb-health-check.self_link}"]

  backend {
    group = "${google_compute_instance_group.lb-instance-group.self_link}"
  }
}

resource "google_compute_url_map" "lb-url-map" {
  name            = "lb-url-map"
  default_service = "${google_compute_backend_service.lb-backend-service.self_link}"

  host_rule {
    hosts        = ["*"]
    path_matcher = "allpaths"
  }

  path_matcher {
    name            = "allpaths"
    default_service = "${google_compute_backend_service.lb-backend-service.self_link}"

    path_rule {
      paths   = ["/"]
      service = "${google_compute_backend_service.lb-backend-service.self_link}"
    }
  }
}

resource "google_compute_target_http_proxy" "lb-http-proxy" {
  name        = "lb-http-proxy"
  description = "a description"
  url_map     = "${google_compute_url_map.lb-url-map.self_link}"
}

resource "google_compute_global_forwarding_rule" "default" {
  name       = "lb-global-forwarding-rule"
  target     = "${google_compute_target_http_proxy.lb-http-proxy.self_link}"
  port_range = "80"
}

