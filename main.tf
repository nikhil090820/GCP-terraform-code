# #service account 
# resource "google_service_account" "terraform-demo" {
#   account_id   = "devops-project"
#   display_name = "Service Account Using Terraform for devops project"
# }

# #Binding service account with the storage admin role
# resource "google_project_iam_binding" "storage-admin" {
#   depends_on = [google_service_account.terraform-demo]
#   project    = "devops-171"
#   role       = "roles/storage.admin"
#   members = [
#     "serviceAccount:${google_service_account.terraform-demo.email}"
#   ]
# }

# #Binding service account with the compute role
# resource "google_project_iam_binding" "compute-admin" {
#   depends_on = [google_service_account.terraform-demo]
#   project    = "devops-171"
#   role       = "roles/compute.admin"
#   members = [
#     "serviceAccount:${google_service_account.terraform-demo.email}"
#   ]
# }

# #Binding service account with the Container admin role
# resource "google_project_iam_binding" "container-admin" {
#   depends_on = [google_service_account.terraform-demo]
#   project    = "devops-171"
#   role       = "roles/container.admin"
#   members = [
#     "serviceAccount:${google_service_account.terraform-demo.email}"
#   ]
# }

# #VPC 
# resource "google_compute_network" "this" {
#   name                            = "vpc-devops"
#   delete_default_routes_on_create = false
#   auto_create_subnetworks         = false
#   routing_mode                    = "REGIONAL"
# }

# # SUBNETS
# resource "google_compute_subnetwork" "this_public" {
#   name                     = "subnetwork-vpc-devops-public"
#   ip_cidr_range            = "10.10.10.0/24"
#   region                   = "us-central1"
#   network                  = google_compute_network.this.id
#   private_ip_google_access = false
#   depends_on               = [google_compute_network.this]
# }
# resource "google_compute_subnetwork" "this_private" {
#   name                     = "subnetwork-vpc-devops-private"
#   ip_cidr_range            = "10.10.20.0/24"
#   region                   = "us-central1"
#   network                  = google_compute_network.this.id
#   private_ip_google_access = true
#   depends_on               = [google_compute_network.this]
#   # secondary_ip_range = {
#   #   cluster_secondary_range_name = "pods"
#   #   services_secondary_range_name = "service"
#   #   ip_cidr_range = "10.20.20.0/24"
#   # }
# }

# #Firewall rules
# resource "google_compute_firewall" "default" {
#   name    = "devops-firewall"
#   network = google_compute_network.this.id

#   allow {
#     protocol = "icmp"
#   }

#   allow {
#     protocol = "tcp"
#     ports    = ["80", "8080", "1000-2000", "22", "443"]
#   }

#   source_ranges = ["0.0.0.0/0"]
# }

# # NAT ROUTER for accessing private instances in subnet 
# resource "google_compute_router" "this" {
#   name    = "devops-router"
#   region  = google_compute_subnetwork.this_private.region
#   network = google_compute_network.this.id
# }

# resource "google_compute_router_nat" "this" {
#   name                               = "devops-router-nat"
#   router                             = google_compute_router.this.name
#   region                             = google_compute_router.this.region
#   nat_ip_allocate_option             = "AUTO_ONLY"
#   source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"
#   subnetwork {
#     name                    = google_compute_subnetwork.this_private.id
#     source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
#   }
# }

#vm instance 1 to check 
resource "google_compute_instance" "public_vm" {
  name         = "my-instance-public"
  machine_type = "n2-standard-2"
  zone         = "us-central1-a"

  tags = ["foo", "bar"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
      labels = {
        my_label = "value"
      }
    }
  }

  // Local SSD disk
  scratch_disk {
    interface = "NVME"
  }

  network_interface {
    # subnetwork = google_compute_subnetwork.this_public.id
    network = "default"
    access_config {

    }
  }

  metadata = {
    foo = "bar"
  }
}

# #vm instance 2 to check 
# resource "google_compute_instance" "private_vm" {

#   name         = "my-instance-private"
#   machine_type = "n2-standard-2"
#   zone         = "us-central1-a"

#   tags = ["foo", "bar"]

#   boot_disk {
#     initialize_params {
#       image = "debian-cloud/debian-11"
#       labels = {
#         my_label = "value"
#       }
#     }
#   }

#   // Local SSD disk
#   scratch_disk {
#     interface = "NVME"
#   }

#   network_interface {
#     subnetwork = google_compute_subnetwork.this_private.id
#   }

#   metadata = {
#     foo = "bar"
#   }
# }



# # GKE Cluster
# resource "google_container_cluster" "primary" {
#   name     = "gke-cluster-test"
#   location = "us-central1"
#   # network = google_compute_network.this.id
#   network = google_compute_network.this.name
#   subnetwork = google_compute_subnetwork.this_private.name

#   # We can't create a cluster with no node pool defined, but we want to only use
#   # separately managed node pools. So we create the smallest possible default
#   # node pool and immediately delete it.
#   remove_default_node_pool = true
#   initial_node_count       = 1
#   node_config {
#     service_account = google_service_account.terraform-demo.email
#   }
#     private_cluster_config {
#     enable_private_endpoint = false
#     enable_private_nodes    = true
#     master_ipv4_cidr_block  = "10.10.30.0/28"
#   }
#   master_authorized_networks_config {
    
#     cidr_blocks {
#       cidr_block = format("%s/32",google_compute_instance.bastion.network_interface[0].access_config[0].nat_ip)
#         # cidr_block = "10.10.20.0/28"
#     }
#   }
#   depends_on = [google_service_account.terraform-demo]
# }

# #node pool for the GKE
# resource "google_container_node_pool" "primary_preemptible_nodes" {
#   name       = "my-node-pool"
#   location   = "us-central1"
  
#   cluster    = google_container_cluster.primary.name
#   node_count = 2
#   node_locations = [
#     "us-central1-a"
#   ]
#   # when you set just the region (us-central1) you are creating a regional cluster in 3 zones.
#   #  The initial_node_count field is per zone. So even if you set it to 1, you are getting 1 per 
#   # zone. Adding node_locations turns the cluster into a zonal one
#   node_config {
#     preemptible  = true
#     machine_type = "e2-medium"

#     # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
#     service_account = google_service_account.terraform-demo.email
#     oauth_scopes = [
#       "https://www.googleapis.com/auth/cloud-platform"
#     ]
#   }
#   depends_on = [google_service_account.terraform-demo]
# }



# #bastion resource for gke
# resource "google_compute_instance" "bastion" {
#   name         = "bastion-vm-gke"
#   machine_type = "e2-medium"
#   zone         = "us-central1-a"
#   boot_disk {
#     initialize_params {
#       image = "debian-cloud/debian-11"
#     }
#   }
#   network_interface {
#     network    = google_compute_network.this.self_link
#     subnetwork = google_compute_subnetwork.this_public.self_link
#     access_config {

#     }
#   }
#   tags                    = ["bastion"]
#   metadata_startup_script = <<-EOT
#   #!/bin/bash
#   sudo apt-get update
#   sudo apt-get install kubectl
#   EOT
# }

# # Use local provisioners or remote provisioners

# # create a service account in gke to create a LB

# # deploy helm in gke

# # GCP Loadbalancer

# # ArgoCD