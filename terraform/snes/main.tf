terraform {
  required_version = ">= 0.13"

  required_providers {
    ansiblevault = {
      source = "MeilleursAgents/ansiblevault"
      version = "~> 2.2.0"
    }
  }
}

provider "ansiblevault" {
  vault_path = "../../vault_password"
  root_folder = "../../"
}
