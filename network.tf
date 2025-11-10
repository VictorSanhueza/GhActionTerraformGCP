# VPC en modo custom (sin subredes automáticas)
resource "google_compute_network" "vpc" {
  name                    = "gha-demo-vpc"
  auto_create_subnetworks = false
}

# Subred regional
resource "google_compute_subnetwork" "subnet" {
  name          = "gha-demo-subnet"
  ip_cidr_range = "10.10.0.0/24"
  region        = var.region
  network       = google_compute_network.vpc.id
}

# Firewall: ICMP y SSH
resource "google_compute_firewall" "allow-ssh-icmp" {
  name    = "gha-allow-ssh-icmp"
  network = google_compute_network.vpc.name

  allow {
    protocol = "icmp"
  }
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  source_ranges = ["0.0.0.0/0"]
}
