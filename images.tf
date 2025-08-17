resource "docker_image" "nginx" {
  name         = "nginx:stable-bookworm"
  keep_locally = false
}

resource "docker_image" "postgres" {
  name         = "postgres:15.8-bookworm"
  keep_locally = false
}

resource "docker_image" "frontend" {
  name         = "frontend"
  keep_locally = false
  build {
    context = "${path.cwd}/frontend"
    tag     = ["frontend:dev"]
  }
}

resource "docker_image" "backend" {
  name         = "backend"
  keep_locally = false
  build {
    context = "${path.cwd}/backend"
    tag     = ["backend:dev"]
  }
}