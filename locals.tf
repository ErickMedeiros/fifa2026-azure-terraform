locals {
  rg_name = "rg-prd-tik-cin-001"

  vnet_app_name  = "vnet-prd-inf-cin-001"
  vnet_data_name = "vnet-prd-inf-aes-001"

  subnet_front_name = "snet-prd-inf-fend-cin-001"
  subnet_back_name  = "snet-prd-inf-bend-cin-001"
  subnet_data_name  = "snet-prd-inf-data-aes-001"

  nsg_app_name  = "nsg-prd-inf-cin-001"
  nsg_data_name = "nsg-prd-inf-aes-001"

  vm_front_name = "vm-prd-tk-fend-cin-001"
  vm_back_name  = "vm-prd-tk-bend-cin-001"
  vm_data_name  = "vm-prd-tk-data-aes-001"

  address_space_app  = ["10.20.0.0/16"]
  address_space_data = ["10.30.0.0/16"]

  subnet_front_prefix = ["10.20.1.0/24"]
  subnet_back_prefix  = ["10.20.2.0/24"]
  subnet_data_prefix  = ["10.30.1.0/24"]
}
