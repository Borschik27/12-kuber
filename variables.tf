variable "cloud_id" {
  type        = string
}

variable "folder_id" {
  type        = string
}

variable "vpc_name" {
  type        = string
}

variable "subnet_name" {
  type        = string
}

variable "default_zone" {
  type        = string
}

variable "default_cidr" {
  type        = list(string)
}

variable "vms_ssh_root_key" {
  type        = string 
}

variable "vms_ssh_root_key_file" {
  type        = string 
}

variable "ppkyc" {
  type        = string
  description = "Path to key"
}

variable "platform_id" {
  type        = string
  description = "Platform ID"
}

variable "image_family" {
  type        = string
  description = "ISO Img"
}

##### for terraform.tfvars
variable "vms_resources" {
  type = map(object({
    name          = string
    cores         = number
    memory        = number
    hdd_size      = number
    hdd_type      = string
    core_fraction = number
    platform_id   = string
    zone          = string
    cidr_block    = string
    hostname      = string
    chose         = string
    local_ip      = string
  }))
}

variable "vm_user" {
  description = "Username for the VM user"
  type        = string
}

variable "vm_user_password" {
  description = "Password for the VM user"
  type        = string
}

variable "vm_u_group" {
  description = "User group for the VM user"
  type        = string
}

variable "vm_u_shell" {
  description = "Shell for the VM user"
  type        = string
}

variable "sudo_cloud_init" {
  description = "Sudo permissions for the user"
  type        = list(string)
}

variable "pack_list" {
  description = "List of packages to install via Cloud-init"
  type        = list(string)
  default     = []
}
