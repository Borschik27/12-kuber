#cloud-config
users:
  - name: ${uname}
    groups: ${ugroup}
    shell: ${shell}
    sudo: ["${s_com}"]
    plain_text_passwd: ${vm_user_password}
    lock_passwd: false
    ssh_authorized_keys:
      - ${ssh_key}
package_update: true
package_upgrade: true
packages:
  - ${pack}