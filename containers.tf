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
  networks_advanced {
    name = docker_network.cubos_observability_network.name
  }
  restart = "on-failure"
}

resource "docker_container" "kibana" {
  image = docker_image.kibana.image_id
  name = "kibana"
  networks_advanced {
    name = docker_network.cubos_public_network.name
  }
  networks_advanced {
    name = docker_network.cubos_observability_network.name
  }
  ports {
    internal = 5601
    external = 5601
    ip = "127.0.0.1"
  }
  restart = "on-failure"
  env = [ 
    "ELASTICSEARCH_HOSTS=http://elasticsearch:9200",
   ]
   healthcheck {
    test = [ "CMD", "curl", "-s", "-f", "http://kibana:5601" ]
    interval = "30s"
    timeout = "10s"
    retries = 5
  }
  depends_on = [ docker_container.elasticsearch ]
}

resource "docker_container" "elasticsearch" {
  image = docker_image.elasticsearch.image_id
  name = "elasticsearch"
  networks_advanced {
    name = docker_network.cubos_observability_network.name
  }
  volumes {
    container_path = "/usr/share/elasticsearch/data"
    volume_name = docker_volume.elasticsearch_data.name
  }
  healthcheck {
    test = [ "CMD", "curl", "-s", "-f", "http://elasticsearch:9200"]
    interval = "30s"
    timeout = "10s"
    retries = 5
  }
  env = [
    "discovery.type=single-node",
    "xpack.security.enabled=false"
  ]
  restart = "on-failure"
  wait = true
}

resource "docker_container" "fluentd" {
  image = docker_image.fluentd.image_id
  name = "fluentd"
  volumes {
    container_path = "/fluentd/etc"
    host_path = "${path.cwd}/fluentd/conf"
  }
  volumes {
    container_path = "/fluentd/log/"
    host_path = "${path.cwd}/fluentd/log"
  }
  volumes {
    container_path = "/fluentd/logs/backend"
    host_path = "${path.cwd}/backend/logs"
  }
  networks_advanced {
    name = docker_network.cubos_private_network.name
  }
  networks_advanced {
    name = docker_network.cubos_observability_network.name
  }
  restart = "on-failure"
  depends_on = [ docker_container.elasticsearch ]
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
  volumes {
    container_path = "/server/logs"
    host_path = "${path.cwd}/backend/logs"
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