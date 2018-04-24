# max2l_microservices
max2l microservices repository
## Homework 13 Технология_контейнеризации Введение в Docker
### В процессе сделано
- Установлен `docker`
- Установлен `docker-compose`
- Запущено несколько контейнеров
- Изучены основные команды `docker`
### Как запустить проект:

- Ниже указными командами можно проверить версию `docker` и его текущее состояние. 
```
docker version
docker info
```
- Список запущенных контейнеров можно посмотреть командой
```
docker ps
```
- Список скаченных образов можно посмотреть командой
```
docker images
```
- Запустить контейнер из образа 
```
docker run имя_образа
```
- Запустить остановленный контейнер
```
docker start id_контейнера
```
- Присоединиться к запущенному контейнеру
```
docker exec -it id_контейнера bash
docker attach id_контейнера
```
- Для вывода списока всех контейнеров
```
docker ps -a
```
- Для удаления контейнера или образа 
```
docker rm -f id_контейнера
docker rmi -f id_образа 
```
- Создать новай образ из существующего контейнера 
```
docker commit id_контейнера имя_образа
```
- Остановить запущенный контейнер
```
docker stop -f id_контейнера
docker kill -f id_контейнера
```
- Посмотреть занятое на диске место.
```
docker system df
```
## Homework 14. Docker контейнеры
### В процессе сделано
 - Установлено ПО `docker-machine`
 - Создан новый проект в GCP
 - gcloud настроен для работы с новым проектом
 - В GCP создан Docker-хост
 - Проверена работа систем namspases (PID, net, user space). При запуске контейнера с namspases PID по умолчанию в контейнере виден только процесс htop, при запуске namspases PID видны все процессы хоста.
 - Создан `Docker` файл для запуска ПО `Puma` в контейнере
 - Создан образ docker
 - Создана учетная запись в ресурсе https://hub.docker.com/
 - Созданый образ загружен в репозиторий hub.docker.com
 - Произведен анализ изменений в запускаемом контейнере и созданого образа.
 - Создан шаблон для packer
 - Создана конфигурация для поднятия нескольких инстансев
 - Созданы плейбуки с использованием динамических инвентори для установки докера и запуска там нескольких приложений.
### Как запустить проект:
 - Проверка статуса Docker машин
```
docker-machine ls
```
  - Определение переменных окружения для работы docker с удаленным docker-хостом
```
eval $(docker-machine env docker-host)
```
 - Запуска контейнера c различными степенями изоляции namspases PID
```
docker run --rm -ti tehbilly/htop
docker run --rm --pid host -ti tehbilly/htop
```
 - Сборка образа docker
```
docker build -t reddit:latest .
```
 - Запуск контейнера используя namespase network host
```
docker run --name reddit -d --network=host reddit:latest
```
 - Поменять tag у образа и загрузить его в репозиторий на hub.docker.com 
```
docker tag reddit:latest max2l/otus-reddit:1.0
docker push max2l/otus-reddit:1.0
```
 - Запуск образа из удалённого репозитория
``` 
docker run --name reddit -d -p 9292:9292 max2l/otus-reddit:1.0 
```
 - Создание образа ОС с установленным docker 
```
cd docker-monolith/infra/
packer validate packer/packer_with_docker.json
packer build packer/packer_with_docker.json
```
 - Создание инстансев для работы `Puma`
```
cd docker-monolith/infra/terraform
terraform plan
terraform apply
```
  - Развертывание инфраструктуры.
```
cd docker-monolith/infra/ansible
ansible-playbook playbook/site.yml
```
## Homework 15. Docker-образа. Микросервисы.pdf
### В процессе сделано:
 - Созданы Docker файлы для сборки образов микросервисов
 - Произведена сборка микросервисов на основании ранее созданых файлов

### Как запустить проект:
  - Создание docker machine в GCP
```
export GOOGLE_PROJECT=docker-201806
docker-machine create --driver google \
  --google-machine-image https://www.googleapis.com/compute/v1/projects/ubuntu-os-cloud/global/images/family/ubuntu-1604-lts \
  --google-machine-type n1-standard-1 \
  --google-zone europe-west1-b \
  docker-host 
```
  - Сборка образов микросервисов
 ```
 docker pull mongo:latest
 docker build -t max2l/post:1.0 ./post-py
 docker build -t max2l/comment:1.0 ./comment
 docker build -t max2l/ui:1.0 ./ui
 ```