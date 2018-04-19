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
```
---
## Homework 09. Управление конфигурацией. Основные DevOps инструменты
### Описание конфигурации
 - Произведенна установка ПО Ansible. Проверить, что он установлен можно коммандой `ansible --version`
 - В файл `ansible/inventory` описание инстансев и групп виртуальных машин.
 - В файле `ansible/ansible.cfg` описана конфигурация по умолчанию и оснавные настройки Ansible. Это позволило вынести излишнюю информацию из файла `inventory` и повысить его удобочитаемости.
 - В файле `inventory.yml` содержиться описание хостов и в групп в формате YAML.
 - В файле `ansible/clone.yml` описан плейбук для клонирования репозитория.
### Подключение
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
 
 ### В процессе сделано:
 - Произведена установка ПО Ansible.
 - Создан файл `inventory`. в этом файле содержаться описание хостов и групп хостов.
 - Основные повторяющиеся настойки inventory вынесены в файл `ansible.cfg`
 - Файл `inventory` трансформирован в файл `inventory.json`. В новом файле содержаться описания групп и хостов в формане JSON.
 - Изучено использование модукей и плейбуков Ansible.
 - Создан скрипт `forDinamicInventory.sh` для работы с динамическими inventory.
 - Настройка работа Ansible с динамическими inventory. 

## Homework 10. Расширенные возможности Ansible
### Описание конфигурации
 - В плейбуке `ansible/reddit_app_one_play.yml` описан сценарий установки и настойки для MongoDB и Puma
 - В плейбуке `ansible/reddit_app_multiple_plays.yml` производится установка MongoDB и Puma через несколько сценариев установки.
 - В плейбуке `site.yml`  импортируются файлы  `ansible/app.yml`, `ansible/clone.yml`, `ansible/deploy.yml` и `ansible/db.yml` для установки ПО.
 - Скрипт `gce.py` необходим для использования динамических inventory. Информация о хостах и переменных берется из GCP.
 -  Плейбуки  `ansible/packer_app.yml` и `ansible/packer_db.yml` необходимы для сборки образов с помощью Packer для  GCP
 -  Шаблоны  `ansible/templates/db_config.j2` и `ansible/templates/mongod.conf.j2` необходимы для создания  фаилов `/etc/mongod.conf
` и  `/home/appuser/db_config`.
 -  Файл `ansible/files/puma.service` необходим для запуска ПО Puma используя системный менеджер systemd
### Подключение
 - Для установки и настройки ПО с использованием плейбкука `ansible/reddit_app_one_play.yml` используются теги `app-tag` `deploy-tag`. При использовании этого плейбука необходимо задавать группу хостов
```
reddit_app.yml --limit db
ansible-playbook reddit_app.yml --limit app --tags app-tag
ansible-playbook reddit_app.yml --check --limit app --tags deploy-tag
```
 - Для использования прейбука `ansible/reddit_app_multiple_plays.yml` так же необходимо использовать теги, но группу хостов уже использовать не нужно.
```
ansible-playbook reddit_app2.yml --tags db-tag
ansible-playbook reddit_app2.yml --tags app-tag --check
ansible-playbook reddit_app2.yml --tags deploy-tag --check
```
 - Для плейбука `site.yml` ненужно задавать ни тегов, ни группы хостов. 
```
ansible-playbook site.yml
```
 - Сборка образов для GCP производится командами.
```
packer build -var-file=packer/variables.json packer/app.json
packer build -var-file=packer/variables.json packer/db.json
```
 - 
### В процессе сделано:
 - Созданы плейбуки для установки и настройки Puma и  MongoDB c использованием различных методик (Прлеибук -> один сценайий устиновки, плейбук -> несколько сценариев установки, прейбук -> импорт других плейбуков.).
 - Созданы плейбуки для сборки GCP образов ОС c использованием Packer. 
 - Пересозданы образы ОС `reddit-app-base` и `reddit-db-base`
 - Настроено использование динамических инвентори с использованием файла `gce.py`.
## Homework 11. Ansible роли, окружения и best practices
### Описание конфигурации
 - В каталогах `ansible/roles/db` и `ansible/roles/app` расположены роли для установки и настройки MongoDB и Puma
 - В каталогах `ansible/environments/prod` и `ansible/environments/stage` находятся файлы для работы  с Prod и Stage окружениями.
 - В файлах `ansible/environments/prod/group_vars/tag_reddit-app`, `ansible/environments/prod/group_vars/tag_reddit-db`, `ansible/environments/stage/group_vars/tag_reddit-app`, `ansible/environments/stage/group_vars/tag_reddit-db` описываются переменные для раблоты с динамическими инвентори.
 - В каталоге `ansible/playbooks` расположены плейбуки для вызова ролей.
 - В файле `.travis.yml` определены команды для тестирования синтаксиса файлов и корректности настройки проекта.
 - Файл `ansible/vault.key` предназначен для шифрования с помощью Ansible Vault.
### Подключение
 - Для создания виртуальных машин необходимо выполнить команды
```
terraform destroy
terraform apply -auto-approve=false
```
 - Для создания новых ролей необходимо выполнить команды `ansible-galaxy init app` и `ansible-galaxy init db`
 - По умолчанию плейбуки работают со Stage окружением. Для работы с Prod окружением необходимо явно указать инвентори файл для Prod окружения.
```
$ ansible-playbook -i environments/prod/inventory playbooks/site.yml 
```
 - Файлы содержащие конфиденциальную информацию зашифрованы с помощью Ansible Vault
```
ansible-vault encrypt environments/prod/credentials.yml
ansible-vault encrypt environments/stage/credentials.yml
```
 - Запустить тесты без создания PR и отправки изменений в GitHub можно командой `trytravis`
### В процессе сделано:
 - Ранее созданные плейбуки перенесены в отдельно созданные роли.
 - Созданы и описаны два окружения `Prod` и `Stage`. Проект настроен для работы с этими окружениями.
 - Установлена и настроена коммьюнити роль  Nginx.
 - Конфиденциальные данные зашифрованы с помощью Ansible Vault
 - Проект настроен для работы с динамическими инвентори
 - Настроено использование `Travis-ci` для запуска авто тестов без создания PR и без push изменений в `GitLab`.
## Homework 12. Локальная разработка и тестирование Ansible ролей и плейбуков
### Описание конфигурации
- В файле `ansible/Vagrantfile` описана конфигурация для работы `Vagrant` 
- В файле `ansible/roles/db/tasks/config_mongo.yml` описана настройка конфигурации для `MongoDB`
- В файле `ansible/roles/app/tasks/ruby.yml` описана установка `Ruby`
- Инвентори сформированные `Vagrant` хранятся в файле `.vagrant/provisioners/ansible/inventory/vagrant_ansible_inventory`
- В файле `ansible/Vagrantfile` можно определить имя пользователя из под которого будет работать приложение `Puma`
### Подключение
- Проверить скачивание образа виртуальной машины `box` и статуса виртуальных машин можно командами
```
vagrant box list
vagrant status
```
- Соединиться с запущенными виртуальными машинами можно командами 
```
vagrant ssh appserver
vagrant ssh dbserver
```
- Применить роли на запушенных VM можно командами 
```
vagrant provision dbserver
vagrant provision appserver
```
- Создать и удалить VM можно командами
```
vagrant up
vagrant destroy -f
```
- 
### В процессе сделано:
- Установлен и настроен VirtualBox и Vagrant
- Сознана конфигурация `Vagrant` для разворачивания двух виртуальных машин
- Настроено взаимодействие `Vagrant` c ролями `Ansible` которые были созданы в предыдущем ДЗ
- Доработаны роли `Ansible` для работы с `Vagrant`
- Произведено тестирование применения ролей на запушенных VM.
- Произведена параметризация роли app для работы ПО из под любого пользователя. 
- Настроена конфигурация `Nginx` для работы с приложением `Puma`
- Настроено тестирование Ansible ролей используя ПО `Molecule`
- Роль `db` вынесена в отдельный репозиторий `https://github.com/max2l/db_role_for_mongo`
- Настроено тестирование вынесенной роли с помощью `Molecule` в облаке `GCP`
- Настроена отправка сообщений в канал [Slack](https://devops-team-otus.slack.com/messages/C6U5JSKSQ/) 

[![Build Status](https://travis-ci.org/Otus-DevOps-2018-02/max2l_infra.svg?branch=ansible-4)](https://travis-ci.org/Otus-DevOps-2018-02/max2l_infra)
