all:
  hosts:
    localhost:
      ansible_connection: local
%{ for vm_name, vm_data in vm_details ~}
    ${vm_name}:
      ansible_host: ${vm_data.network_interface[0].nat_ip_address}
      ansible_user: ${vm_user}
      ansible_port: 22
      ansible_connection: ssh
      local_ip: ${vm_data.network_interface[0].ip_address}
%{ endfor ~}
  children:
    kuber-cluster:
      children:
        masters:
          hosts:
%{ for vm_name, vm_data in vm_details ~}
%{ if startswith(vm_name, "kuber") ~}
            ${vm_name}:
%{ endif ~}
%{ endfor ~}
        workers:
          hosts:
%{ for vm_name, vm_data in vm_details ~}
%{ if startswith(vm_name, "worker") ~}
            ${vm_name}:
%{ endif ~}
%{ endfor ~}
        ha-proxy:
          hosts:
%{ for vm_name, vm_data in vm_details ~}
%{ if startswith(vm_name, "ha-proxy") ~}
            ${vm_name}:
%{ endif ~}
%{ endfor ~}