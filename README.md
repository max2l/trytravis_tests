# max2l_infra
max2l Infra repository

## Описание конфигурации
 - В Данном домашнем задании используются 2 микросервера. Первый хост имеет имя `bastion` и внешний IP адрес 35.195.18.128. Второй хост c именем `someinternalhost` имеет только внутрений IP адрес 10.132.0.3. Связь с someinternalhost можно произвести только через bastion используя протокол SSH или VPN.
 - Для создания микросерверов и правил firefall можно воспользоваться консольной коммандой `gcloud`. Пример комманды для создания микросервиса: 
```
gcloud compute instances create reddit-app --boot-disk-size=10GB --image-family ubuntu-1604-lts --image-project=ubuntu-os-cloud --machine-type=g1-small --tags puma-server --restart-on-failure   --metadata-from-file startup-script=startupScript.sh
```
 - Пример комманды для добавления правил firewall:
```
gcloud compute --project=valued-clarity-198010 firewall-rules create default-puma-server  --direction=INGRESS --priority=1000 --network=default --action=ALLOW --rules=tcp:9292 --source-ranges=0.0.0.0/0 --target-tags=puma-server
```
 - Установку и сборку программного необходимо проиводить с помошью скриптов `install_mongodb.sh`, `install_ruby.sh` и `deploy.sh`. Для автоматизации этой процедуры при создании виртуальной можно воспользоваться скриптом `startupScript.sh` 
 ## Подключение
 - Для упрошения доступа к хостам через bastion хост можно создать алиас. Для этого необходимо в файл ` ~/.ssh/config` добавить следушие строчки

```
Host someinternalhost
  HostName 10.132.0.3
  User appuser
  ProxyCommand ssh -i ~/.ssh/appuser -A appuser@35.195.18.128 nc %h %p
```
И прописать в файл `~/.bashrc` или в `~/.bash_profile` строчку 
```
alias someinternalhost='ssh someinternalhost'
```
Или можно прописать алиас в виде
```
alias someinternalhost='ssh -A -i ~/.ssh/appuser -tt  appuser@35.195.18.128 ssh -tt 10.132.0.3'
```
Предворительно, для использования алиасов,  необходимо загрузить приватный ssh ключ в `ssh-agent` с помощью комманды `ssh-add`

 - Для подключения к собраному ПО Puma необходимо использовать протокол `http` и порт `9292`

## Сетевые настройки
```
bastion_IP = 35.195.18.128
someinternalhost_IP = 10.132.0.3
```
