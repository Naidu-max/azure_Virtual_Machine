# Terraform Block
terraform {
  required_version = ">= 1.0.0"
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = ">= 2.0" 
    }
    random = {
      source = "hashicorp/random"
      version = ">= 3.0"
    }
  }
}

# Provider Block
provider "azurerm" {
    subscription_id = "77618802-0818-4173-8674-95a126ef0cc2"
 features {}          
}

# Random String Resource
resource "random_string" "myrandom" {
  length = 6
  upper = false 
  special = false
    
}


