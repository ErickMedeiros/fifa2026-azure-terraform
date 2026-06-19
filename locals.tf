locals {
  rg_name = "rg-prd-tik-mxc-001"

  vnet_app_name  = "vnet-prd-inf-mxc-001"
  vnet_data_name = "vnet-prd-inf-chc-001"

  subnet_front_name = "snet-prd-inf-fend-mxc-001"
  subnet_back_name  = "snet-prd-inf-bend-mxc-001"
  subnet_data_name  = "snet-prd-inf-data-chc-001"

  nsg_app_name  = "nsg-prd-inf-mxc-001"
  nsg_data_name = "nsg-prd-inf-chc-001"

  vm_front_name = "vm-prd-tk-fend-mxc-001"
  vm_back_name  = "vm-prd-tk-bend-mxc-001"
  vm_data_name  = "vm-prd-tk-data-chc-001"

  address_space_app  = ["10.20.0.0/16"]
  address_space_data = ["10.30.0.0/16"]

  subnet_front_prefix = ["10.20.1.0/24"]
  subnet_back_prefix  = ["10.20.2.0/24"]
  subnet_data_prefix  = ["10.30.1.0/24"]
}
