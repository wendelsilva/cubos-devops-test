variable "postgres_user" {
  type = string
  sensitive = true
  nullable = false
}

variable "postgres_password" {
  type = string
  sensitive = true
  nullable = false
}