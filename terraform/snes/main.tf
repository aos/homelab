terraform {
  required_version = ">= 0.13"

  required_providers {
    ansiblevault = {
      source  = "MeilleursAgents/ansiblevault"
      version = "~> 2.2.0"
    }

    proxmox = {
      source  = "Telmate/proxmox"
      version = "~> 2.9.5"
    }
  }
}

locals {
  raw_inventory = yamldecode(file("${path.module}/../../inventory.yml"))
  inventory = {
    for k, v in local.raw_inventory.all.children : k => v.hosts
  }
}

provider "ansiblevault" {
  vault_path  = "${path.module}/../../vault_password"
  root_folder = "${path.module}/../../"
}

data "ansiblevault_path" "pve_creds" {
  for_each = toset(["vault_pve_ansible_user", "vault_pve_ansible_password_hyper01"])
  path     = "group_vars/hypervisors/vault.yml"
  key      = each.key
}

provider "proxmox" {
  pm_tls_insecure = true
  pm_api_url      = "https://${local.inventory.hypervisors.hyper01.ansible_host}:8006/api2/json"
  pm_user         = data.ansiblevault_path.pve_creds["vault_pve_ansible_user"].value
  pm_password     = data.ansiblevault_path.pve_creds["vault_pve_ansible_password_hyper01"].value
  pm_otp          = ""
}
