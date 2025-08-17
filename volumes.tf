resource "docker_volume" "database" {
  name = "database"
}

resource "docker_volume" "elasticsearch_data" {
  name = "elasticsearch_data"
}