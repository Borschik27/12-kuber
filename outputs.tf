######For vms_platform
output "vm_details" {
  description = "Details for each VM"
  
  value = {
    for vm_name, vm_data in yandex_compute_instance.vm : vm_name => {
      name    = vm_data.name
      hostname = vm_data.hostname
      ip      = vm_data.network_interface[0].nat_ip_address
      local_ip = vm_data.network_interface[0].ip_address
    }
  }
}