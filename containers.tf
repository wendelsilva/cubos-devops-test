resource "docker_container" "nginx" {
  image = docker_image.nginx.image_id
  name = "nginx-server"
  ports {
    internal = 80
    external = 8080
  }
  volumes {
    container_path = "/etc/nginx/conf.d/"
    host_path = "${path.cwd}/nginx/"
  }
  networks_advanced {
    name = docker_network.cubos_private_network.name
  }
  networks_advanced {
    name = docker_network.cubos_public_network.name
  }
  restart = "on-failure"
}

resource "docker_container" "frontend" {
  image = docker_image.frontend.image_id
  name  = "frontend-app"
  networks_advanced {
    name = docker_network.cubos_private_network.name
  }
  restart = "on-failure"
}

resource "docker_container" "backend" {
  image = docker_image.backend.image_id
  name  = "backend-app"
  networks_advanced {
    name = docker_network.cubos_private_network.name
  }
  restart = "on-failure"
}

resource "docker_container" "postgres" {
  image = docker_image.postgres.image_id
  name  = "postgres"
  networks_advanced {
    name = docker_network.cubos_private_network.name
  }
  networks_advanced {
    name = docker_network.cubos_public_network.name
  }
  ports {
    internal = 5432
    external = 5432
    ip = "127.0.0.1"
  }
  volumes {
    container_path = "/docker-entrypoint-initdb.d/init.sql"
    host_path = "${path.cwd}/sql/script.sql"
  }
  volumes {
    container_path = "/var/lib/postgresql/data"
    volume_name = docker_volume.database.name
  }
  env = [ 
        "PGDATA=/var/lib/postgresql/data", 
        "POSTGRES_PASSWORD=${var.postgres_password}",
        "POSTGRES_USER=${var.postgres_user}"
    ]
  restart = "on-failure"
}