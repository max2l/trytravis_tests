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
  - Произведена сборка микросервисов на основании ранее созданных файлов
  - Создан том `reddit_db` для хранения данных MongoDB
  - Контейнеры docker запушены с ранее созданным томом.
  - Изменены сетевые алиасы для запуска контейнеров и определены переменные окружения для запуска этих контейнеров.
  - Произведена пересборка образов на образе alpine:3.7. Место, занимаемое на диске после пересборки показано ниже.

```
REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
max2l/ui            1.0                 aad5472f5a45        16 hours ago        777MB
max2l/ui            2.0                 d52ab9f8c18f        3 minutes ago       461MB
max2l/ui            3.0                 04d702032f85        6 seconds ago       206MB
max2l/comment       1.0                 3bd4aa40389b        17 hours ago        769MB
max2l/comment       2.0                 12fc7affcc34        10 minutes ago      198MB
max2l/post          1.0                 29a4cc69ad96        17 hours ago        102MB
max2l/post          2.0                 9fd9b7022067        About an hour ago   61.8MB
```
  - Произведена дополнительная оптимизация Docker файлов для уменьшения размера образов. В одном слое сделана установка ПО, сборка приложения и удаление ПО необходимого для сборки. Этот подход позволил еще больше сократить размер образа. Но я не думаю, что этот подход следует применять в дальнейшем. При его использовании усложняется отладка сборки и дальнейшее сопровождение образов. Для решения подобного рода задач лучше использовать отдельный Build сервер.

```
REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
max2l/post          3.0                 a06ae092a763        2 minutes ago       59.5MB
max2l/comment       3.0                 634ff7b3ec7e        About an hour ago   53.6MB
max2l/ui            4.0                 d69f1960093b        About an hour ago   61.7MB
max2l/ui            3.0                 04d702032f85        3 hours ago         206MB
max2l/ui            2.0                 d52ab9f8c18f        3 hours ago         461MB
max2l/comment       2.0                 12fc7affcc34        3 hours ago         198MB
max2l/post          2.0                 9fd9b7022067        3 hours ago         61.8MB
max2l/ui            1.0                 aad5472f5a45        19 hours ago        777MB
max2l/comment       1.0                 3bd4aa40389b        19 hours ago        769MB
max2l/post          1.0                 29a4cc69ad96        19 hours ago        102MB
mongo               latest              a0f922b3f0a1        5 days ago          366MB
```

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
  - Создане сети для приложения
```
docker network create reddit
```
  - Запуск контейнеров 
```
docker run -d --network=reddit --network-alias=post_db --network-alias=comment_db mongo:latest
docker run -d --network=reddit --network-alias=post max2l/post:1.0
docker run -d --network=reddit --network-alias=comment max2l/comment:1.0
docker run -d --network=reddit -p 9292:9292 max2l/ui:2.0
```
  - Создание volume
```
 docker volume create reddit_db
```
  - Запуск MongoDB  с томом `reddit_db`
```
docker run -d --network=reddit --network-alias=post_db --network-alias=comment_db -v reddit_db:/data/db mongo:latest
```
  - Запуск контейнеров c другими сетевым алиасами
```
docker run -d --network=reddit --network-alias=post_db_new_alias --network-alias=comment_db_new_alias mongo:latest
docker run -d --network=reddit --network-alias=post_new_alias -e "POST_DATABASE_HOST=post_db_new_alias" max2l/post:1.0
docker run -d --network=reddit --network-alias=comment_new_alias -e "COMMENT_DATABASE_HOST=comment_db_new_alias" max2l/comment:1.0
docker run -d --network=reddit -p 9292:9292 -e "POST_SERVICE_HOST=post_new_alias" -e "COMMENT_SERVICE_HOST=comment_new_alias"  max2l/ui:2.0
```


