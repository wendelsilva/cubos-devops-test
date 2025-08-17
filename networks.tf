resource "docker_network" "cubos_private_network" {
  name = "cubos_private_network"
  attachable = true
  driver = "bridge"
  internal = true
}

resource "docker_network" "cubos_observability_network" {
  name = "cubos_observability_network"
  attachable = true
  driver = "bridge"
  internal = true
}

resource "docker_network" "cubos_public_network" {
  name = "cubos_public_network"
  attachable = true
  driver = "bridge"
}