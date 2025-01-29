
### Решение для данного задания находится в репозитории [06-kuber](https://github.com/Borschik27/06-kuber), где уже приложен проект для развертки хостов в облаке YC и дальнейшей настройки этих хостов с помощью ansible, так же там описаны действия по созданию и настройки гластера с помощью kubeadm, а в [README.md](https://github.com/Borschik27/06-kuber/blob/main/README.md), уже описана пошаговая установка кластера kubernetes с использование (CALICO в виде сетвого плагина, и metallb в качестве loadbalancer)

### В ansible/roles/ содержиться описание настройки ролей для master и для worker и добавлена роль для HAproxy, в этих ролях описана полная подготовка вируальных машин к тому что бы просто подключиться на них и начать инициализацию кластера.

### При работе в облаке вместо создания виртуального ip (VIP) с помощью keepalived создади internal-lb создадим группу хостов для него и добавим в группу узлы ha-proxy через terraform. 

### Для уставновки калстера в режиме HA по условиям задания требуется:
 1. Минимум 3 master-ноды: для кворума рекомендуется нечётное число нод. Например, 3 master-ноды и 2 worker-ноды.
 2. Минимальные системные требования для каждой master-ноды:
    CPU: 2 ядра. RAM: 4 ГБ. Диск: 50 ГБ.

Примеры конфиг файлов нахотять в этом git-проекте "roles/*/files"

После развертки получаем вот такую структуру:

Узлы:
![image](https://github.com/user-attachments/assets/bd7f6c12-cf69-49c2-ac90-1b1eb513b017)

LoadBalancer:
![image](https://github.com/user-attachments/assets/08b6e4b5-f568-4b33-8309-01ffebea23ff)

Перейдем к настройке кластера, воспользуемся примером init-конфига:
```
apiVersion: kubeadm.k8s.io/v1beta3
kind: InitConfiguration
localAPIEndpoint:
  advertiseAddress: <ip-address>
  bindPort: 6443

---
apiVersion: kubeadm.k8s.io/v1beta3
kind: ClusterConfiguration
networking:
  podSubnet: 192.168.240.0/24 # Default CIRD 192.168.0.0/16
  serviceSubnet: 10.96.0.0/24 # Default mask /12
  dnsDomain: cluster.local
controlPlaneEndpoint: <network-lb>:<port>
```

Именим параметры и обновим конфиг:
```
 cat init-config-old.yaml
apiVersion: kubeadm.k8s.io/v1beta3
kind: InitConfiguration
localAPIEndpoint:
  advertiseAddress: 10.1.1.11
  bindPort: 6443

---
apiVersion: kubeadm.k8s.io/v1beta3
kind: ClusterConfiguration
networking:
  podSubnet: 192.168.240.0/24
  serviceSubnet: 10.96.0.0/24
  dnsDomain: cluster.local
controlPlaneEndpoint: 10.1.1.250:6443
```
Параметр: `controlPlaneEndpoint: 10.1.1.250:6443` указывает на на созданный LoadBalancer


Получим конфиг новой версии со всеми дополнительными параметрами
```
kubeadm config migrate --old-config init-config-old.yaml --new-config init-config-new.yaml
```

Выполним `sudo kubeadm init --config=init-config-new.yaml --upload-certs`
И получаем ответ и видим что в качестве controlPlaneEndpoint используется адрес NetworkLoadBalancer
```
Your Kubernetes control-plane has initialized successfully!

To start using your cluster, you need to run the following as a regular user:

  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config

Alternatively, if you are the root user, you can run:

  export KUBECONFIG=/etc/kubernetes/admin.conf

You should now deploy a pod network to the cluster.
Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:
  https://kubernetes.io/docs/concepts/cluster-administration/addons/

You can now join any number of control-plane nodes running the following command on each as root:

  kubeadm join 10.1.1.250:6443 --token fc.c2 \
        --discovery-token-ca-cert-hash sha256:f306f363d \
        --control-plane --certificate-key cbd4b7843a82

Please note that the certificate-key gives access to cluster sensitive data, keep it secret!
As a safeguard, uploaded-certs will be deleted in two hours; If necessary, you can use
"kubeadm init phase upload-certs --upload-certs" to reload certs afterward.

Then you can join any number of worker nodes by running the following on each as root:

kubeadm join 10.1.1.250:6443 --token fcfn76.79dld9beekk8hpc2 \
        --discovery-token-ca-cert-hash sha256:f306f363d
```

Подключим все узлы установим K9S и посмотрик как это будет выглядет:
![image](https://github.com/user-attachments/assets/dab58dd7-d76a-4a30-8f4a-26384c88f458)

![image](https://github.com/user-attachments/assets/a96eec1f-5f55-41b1-b03b-22f9b1822b76)
