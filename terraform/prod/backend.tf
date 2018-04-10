terraform {
  backend "gcs" {
    bucket = "max2l-bucket-state",
    prefix = "prod"
  }
}
