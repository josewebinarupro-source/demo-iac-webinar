terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

provider "docker" {}

resource "docker_network" "webinar_net" {
  name = "webinar-network"
}

resource "docker_image" "nginx" {
  name = "nginx:latest"
}

resource "docker_container" "web" {
  name  = "webinar-web"
  image = docker_image.nginx.image_id
  ports {
    internal = 80
    external = 8080
  }
  volumes {
    host_path      = "/home/joseac/demo-iac-webinar/html"
    container_path = "/usr/share/nginx/html"
  }
  networks_advanced {
    name = docker_network.webinar_net.name
  }
}

resource "docker_image" "postgres" {
  name = "postgres:15"
}

resource "docker_container" "db" {
  name  = "webinar-db"
  image = docker_image.postgres.image_id
  env = [
    "POSTGRES_PASSWORD=webinar2026",
    "POSTGRES_DB=demodb"
  ]
  ports {
    internal = 5432
    external = 5432
  }
  networks_advanced {
    name = docker_network.webinar_net.name
  }
}

resource "docker_image" "app" {
  name = "webinar-app:latest"
  build {
    context = "/home/joseac/demo-iac-webinar/app"
  }
}

resource "docker_container" "app" {
  name  = "webinar-app"
  image = docker_image.app.image_id
  env = [
    "DB_HOST=webinar-db",
    "DB_NAME=demodb",
    "DB_USER=postgres",
    "DB_PASS=webinar2026"
  ]
  ports {
    internal = 5000
    external = 5000
  }
  networks_advanced {
    name = docker_network.webinar_net.name
  }
}

resource "docker_image" "pgadmin" {
  name = "dpage/pgadmin4:latest"
}

resource "docker_container" "pgadmin" {
  name  = "webinar-pgadmin"
  image = docker_image.pgadmin.image_id
  env = [
    "PGADMIN_DEFAULT_EMAIL=admin@webinar.com",
    "PGADMIN_DEFAULT_PASSWORD=webinar2026"
  ]
  ports {
    internal = 80
    external = 8081
  }
  networks_advanced {
    name = docker_network.webinar_net.name
  }
}

resource "docker_image" "portainer" {
  name = "portainer/portainer-ce:latest"
}

resource "docker_volume" "portainer_data" {
  name = "portainer_data"
}

resource "docker_container" "portainer" {
  name  = "webinar-portainer"
  image = docker_image.portainer.image_id
  ports {
    internal = 9000
    external = 9000
  }
  volumes {
    host_path      = "/var/run/docker.sock"
    container_path = "/var/run/docker.sock"
  }
  volumes {
    volume_name    = docker_volume.portainer_data.name
    container_path = "/data"
  }
  networks_advanced {
    name = docker_network.webinar_net.name
  }
}
