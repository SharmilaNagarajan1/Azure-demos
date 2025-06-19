terraform {
  required_providers {
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 3.1.0"
    }
  }
}

data "azuread_domains" "aad"{
    only_initial = true
}
