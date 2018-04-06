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

 - В файле `packer/ubuntu16.json` описаны параметры (proj_id и source_image_family) для сборки пользовательского образа в GCP с помощью packer. В файле `packer/variables.json.example` содержиться пример пользовательских параметров для сборки. Пороверить корректность всех параметров можно командой: 
```
packer validate -var-file=packer/variables.json  packer/ubuntu16.json
```

Или командой 
```
packer validate -var 'proj_id=valued-clarity-198010' -var 'source_image_family=ubuntu-1604-lts'  packer/ubuntu16.json
```

 - В файле `packer/immutable.json` содержаться параметры для сборки образа и запуска приложения Puma после старта микросервера.
 - Директория `packer/scripts/` содержит скрипты для установки ПО и сборки приложения Puma.
 - Файл `packer/files/puma.service` необходим для запуска Puma через `systemd`
 - Файл `config-scripts/create-reddit-vm.sh` содержит комманды для запуска миркросервера и создания правил фаервола для доступа из внешней сети к приложению Puma.
 - В директории `terraform` содержаться файлы для создания облачной инфраструктуры с попощью программы terraform
 - Если добавить ssh ключи через web интерфейс `https://console.cloud.google.com` то после выполнения комманды `terraform apply` эти ключи будут удалены.
 - В файле `outputs.tf` определяються переменные для создаваемых микросерверов и для балансировшика нагрузки.
 - В директории `terraform/files` лежат файлы для развертывания и запуска приложения Puma
 - В файле `terraform/lb.tf` описываться конфигурация балатсировщика GCP. 
 - В директории `modules` созданны модули для terraform
 - В Модуле `app` описывается разворачивание микросервера и деплой приложения
 - В Модуле `db` настраивается база MongoDB и произбодится её настройка для работы с внешним окружением.
 - В Модуле `db` настраивается база MongoDB и произбодится её настройка для работы с внешним окружением.
 - В Модуле `vpc` производится настройка серевого экрана для удаленного доступа с микросерверам.
 - В директориях `stage/` и `prod/` настроенна работа с двумя окружениями.
 - Файлы состояний храняться в облаке GCP. 

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

 - Сборку пользовательского образа без приложения Puma необходимо производить коммандой.
```
packer build -var-file=packer/variables.json  packer/ubuntu16.json
```

или передав опции `proj_id` и `source_image_family` из командной строки.
```
packer build -var 'proj_id=valued-clarity-198010' -var 'source_image_family=ubuntu-1604-lts'  packer/ubuntu16.json
```

 - Сборку пользовательского образа с приложением Puma необходимо производить коммандой.
```
packer build packer/immutable.json
```

 - Для запуска микросервера и для настройки правил фаервола необходимо выполнить скрипт `config-scripts/create-reddit-vm.sh`

 - Для проверки конфигурационных файлов, запуска микросервисов и балансировщика GCP необходимо выполнить комманды
```
terraform plan
terraform apply
``` 
 - Для доступа к приложению через балансировщик GCP нужно использовать IP адрес определенной в output переменной `gcp_lb_external_ip`
 
 - Для разворачивания инфраструктуры микосерверов в любом из окружений необходимо выполнить комманды `terraform plan` и `terraform apply` соответствующих директориях. Для прод окужения `terraform/prod/`, для stage `terraform/stage/`   
 - После развертывания инрастуктуы приложение будет доступно по порту 9292 на внешнем IP адесе. Его можно узнать из переменной `app_external_ip`
 - Доступ к микосерверам запушеным из `prod` окружения можно осуществить только с одного IP адреса, а к серверам из `stage` окужения из любой точки сети. 

## Сетевые настройки
```
bastion_IP = 35.195.18.128
someinternalhost_IP = 10.132.0.3
testapp_IP = 130.211.68.73
testapp_port = 9292 
```
## Output переменные terraform
```
app_external_ip - IP адреса микросервисов
gcp_lb_external_ip - IP адрес балансировщика GCP

# Homework 09. Управление конфигурацией. Основные DevOps инструменты

## Описание конфигурации
 - Произведенна установка ПО Ansible. Проверить, что он установлен можно коммандой `ansible --version`
 - В файл `ansible/inventory` описание инстансев и групп виртуальных машин.
 - В файле `ansible/ansible.cfg` описана конфигурация по умолчанию и оснавные настройки Ansible. Это позволило вынести излишнюю информацию из файла `inventory` и повысить его удобочитаемости.
 - В файле `inventory.yml` содержиться описание хостов и в групп в формате YAML.
 - В файле `ansible/clone.yml` описан плейбук для клонирования репозитория.

## Подключение
 - Произвести взаимодействие со всеми файлами описаными в inventory можно исмользуя группу `all` 
```
ansible all -m ping
```
 - Переопределить inventory файл можно опцией `-i`
```
ansible all -m ping -i inventory.yml
```
 - Опция `-m` позволяет задать используемый модуль 
```
ansible all -m command  -a 'uname -a' -i inventory.yml
```
 - Выполнить плейбук можно коммандой `ansible-playbook`
```
ansible-playbook clone.yml
```
 - Скрипт forDinamicInventory.sh позволяет использовать динамические inventory. Их описание содерзаться в файле `inventory.json` 
 - Для испольования димамический inventory необходимо определить скрипт формируюший данные о хостах или группах хостой в формете json. Это можно сделать либо с помощью опции `-i`, либо определив параметр параметра `inventory` в секции `[defaults]` у файла `ansible.cfg`. Этот параметр, должет содержать в виде значения скрипт, который формирует выходные данные в формате JSON.
