# Habilitamos las APIs necesarias (idempotente)
resource "google_project_service" "compute" {
  project = var.project_id
  service = "compute.googleapis.com"
  disable_on_destroy = false
}

resource "google_storage_bucket" "tfstate" {
  name          = "${var.project_id}-tfstate"
  location      = var.region
  force_destroy = true
}

# VM básica en la VPC default y subnet default
resource "google_compute_instance" "vm" {
  name         = var.vm_name
  machine_type = var.machine_type
  zone         = var.zone

  # Depende de tener la API compute habilitada
  depends_on = [google_project_service.compute]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
      size  = 10
      type  = "pd-balanced"
    }
  }

network_interface {
  subnetwork   = google_compute_subnetwork.subnet.id
  access_config {} # para IP pública
}


  metadata = {
    ssh-keys = "google-ssh" # placeholder; si querés usar OS Login, configurar aparte
  }

  service_account {
    email  = var.service_account_email != null ? var.service_account_email : null
    scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }

  tags = ["http-server", "https-server"]
}
