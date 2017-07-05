provider "google" {
	region = "${var.region}"
	project = "${var.project_id}"
  // Uncomment if running from a local machine
  // credentials = "${file(var.account_file_path)}"
}

// create a new barman instance
resource "google_compute_instance" "barman" {
  name = "barman"
  zone = "${var.zone}"
  machine_type = "${var.machine_type}"
  disk {
    image = "debian-8-jessie-v20170426"
    type = "pd-standard"
    size = "${var.disk_size}"
  }

  network_interface {
    network = "default"

    access_config {
      nat_ip =""
    }
  }
}

<[ #replicas ]>
// create <[ hostname ]> instance
resource "google_compute_instance" "<[ hostname ]>" {
  name = "<[ hostname ]>"
  zone = "${var.zone}"
  machine_type = "${var.machine_type}"
  
  disk {
    image = "debian-8-jessie-v20170426"
    type = "${var.disk_type}"
    size = "${var.disk_size}"
  }

  network_interface {
    network = "default"

    access_config {
      nat_ip =""
    }
  } 
}
<[ /replicas ]>

<[ #test ]>
// create testing instance
resource "google_compute_instance" "testing" {
  name = "testing"
  zone = "${var.zone}"
  machine_type = "${var.machine_type}"
  
  disk {
    image = "debian-8-jessie-v20170426"
    type = "${var.disk_type}"
    size = "${var.disk_size}"
  }

  network_interface {
    network = "default"

    access_config {
      nat_ip =""
    }
  } 
}
<[ /test ]>

resource "google_compute_instance_group" "cluster" {
  name = "postgres-cluster"
  description = "Cluster containing db management instance and replicas"

  instances = [
    "${google_compute_instance.barman.self_link}",
    <[ #replicas ]>
    "${google_compute_instance.<[ hostname ]>.self_link}",
    <[ /replicas ]>
  ]

  named_port {
    name = "postgres"
    port = "5432"
  }

  zone = "${var.zone}"
}
