
### Решение для данного задания находится в репозитории [06-kuber](https://github.com/Borschik27/06-kuber), где уже приложен проект для развертки хостов в облаке YC и дальнейшей настройки этих хостов с помощью ansible, так же там описаны действия по созданию и настройки гластера с помощью kubeadm, а в [README.md](https://github.com/Borschik27/06-kuber/blob/main/README.md), уже описана пошаговая установка кластера kubernetes с использование (CALICO в виде сетвого плагина, и metallb в качестве loadbalancer)

### В ansible/roles/ содержиться описание настройки ролей для master и для worker, в этих ролях описана полная подготовка вируальных машин к тому что бы просто подключиться на них и начать инициализацию кластера.

### Для уставновки калстера в режиме HA по условиям задания требуется:
 1. Минимум 3 master-ноды: для кворума рекомендуется нечётное число нод. Например, 3 master-ноды и 2 worker-ноды.
 2. Минимальные системные требования для каждой master-ноды:

    CPU: 2 ядра. RAM: 4 ГБ. Диск: 50 ГБ.

Давайте переведем наш уже рабочий кластер на keepalived для этого создадим с помощью terraform еще 2 ноды и добавим их в кластер в виде мастер нод

Добавили 2 ноды и настроили их дальше подключаем

Так как кластер уже инициалезирован для присоединения двух новых нод надо 

```
sudo kubeadm init phase upload-certs --upload-certs
[upload-certs] Storing the certificates in Secret "kubeadm-certs" in the "kube-system" Namespace
[upload-certs] Using certificate key:
```
```
sudo kubeadm token create --print-join-command
```

```
sudo kubeadm join 10.1.1.31:6443 --token  --discovery-token-ca-cert-hash sha256: --control-plane --certificate-key 
```

После присоединения теперь у нас 3 master узла
![image](https://github.com/user-attachments/assets/397d0aac-7d5c-41e8-8e25-e3977b47d893)


Создадим конфиг файл для keepalived на каждом из узлов:
Конфиг на каждом из улов одинаковый отличается только параметр `priority <lvl>` и `state <BACKUP/MASTER>`

MASTER:
```
 cat /etc/keepalived/keepalived.conf
vrrp_instance VI_1 {
    state MASTER
    interface eth0
    virtual_router_id 51
    priority 100
    advert_int 1
    authentication {
        auth_type PASS
        auth_pass mySecurePassword
    }
    virtual_ipaddress {
        10.1.1.100
    }
}
```

SLAVE:
```
 cat /etc/keepalived/keepalived.conf
vrrp_instance VI_1 {
    state BACKUP
    interface eth0
    virtual_router_id 51
    priority 99
    advert_int 1
    authentication {
        auth_type PASS
        auth_pass mySecurePassword
    }
    virtual_ipaddress {
        10.1.1.100
    }
}
```

Выведем запрос в виде shell-команды

```
sudo kubectl --server=https://10.1.1.31:6443 --certificate-authority=/etc/kubernetes/pki/ca.crt --client-certificate=/etc/kubernetes/pki/apiserver-kubelet-client.crt --client-key=/etc/kubernetes/pki/apiserver-kubelet-client.key get nodes
```
![image](https://github.com/user-attachments/assets/ac2c96f7-13b9-49e2-a31b-998a31e5c9ba)

