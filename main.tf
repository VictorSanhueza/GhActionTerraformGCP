# Habilitar API de Compute (idempotente)
resource "google_project_service" "compute" {
  project             = var.project_id
  service             = "compute.googleapis.com"
  disable_on_destroy  = false
}

# VM en tu VPC/subred
resource "google_compute_instance" "vm" {
  name         = var.vm_name
  machine_type = var.machine_type
  zone         = var.zone

  depends_on = [
    google_project_service.compute,
    google_compute_network.vpc,
    google_compute_subnetwork.subnet
  ]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
      size  = 20
      type  = "pd-balanced"
    }
  }

  network_interface {
    network    = google_compute_network.vpc.id
    subnetwork = google_compute_subnetwork.subnet.id
    access_config {} # IP pública
  }

  metadata = {
    # placeholder; si vas a usar OS Login, configurar aparte
    ssh-keys = "google-ssh"
  }

  dynamic "service_account" {
    for_each = var.service_account_email == null ? [] : [1]
    content {
      email  = var.service_account_email
      scopes = ["https://www.googleapis.com/auth/cloud-platform"]
    }
  }

  tags = ["http-server", "https-server"]
}
