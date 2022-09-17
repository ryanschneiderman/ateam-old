variable "region" {}

variable "environmentvar" {
  type = list(any)
  default = [
    { "name" : "POSTGRES_USER", "value" : "postgres" },
    { "name" : "POSTGRES_PORT", "value" : "5432" },
    { "name" : "POSTGRES_HOST", "value" : "sunapi.cdfnwda8o6fh.us-east-1.rds.amazonaws.com" },
    { "name" : "RAILS_ENV", "value" : "development" },
    { "name" : "RAILS_MASTER_KEY", "value" : "aaa43aac0e699bb1f185439259a7d1db" },
    { "name" : "RAILS_MAX_THREADS", "value" : "5" },
    { "name" : "RAILS_LOG_TO_STDOUT", "value" : "ENABLE" },
  ]
}

variable "container_port" {}

variable "app_name" {}
