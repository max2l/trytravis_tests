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
---
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
 - Манивес для деплоя dashboard находится в файле `kubernetes/reddit/kubernetes-dashboard.yaml`. Он взят по ссылке https://docs.giantswarm.io/guides/install-kubernetes-dashboard/#deploying-dashboard 

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
---
## Homework 15. Docker-образа. Микросервисы

### В процессе сделано:
  - Созданы Docker файлы для сборки образов микросервисов
  - Произведена сборка микросервисов на основании ранее созданных файлов
  - Создан том `reddit_db` для хранения данных MongoDB
  - Контейнеры docker запушены с ранее созданным томом.
  - Изменены сетевые алиасы и определены переменные окружения для запуска Docker контейнеров.
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
  - Произведен другой подход при оптимизации размера образов. Для сборки ПО используются промежуточный образ и после сборки все необходимые файлы копируются в конечный образ. Для этого используются несколько директив `FROM` в Docker файлах. Размер образов после сборки показан ниже.
```
max2l/ui 5.0 1bc0d5a4815a 18 minutes ago 48.9MB
max2l/ui 4.0 d69f1960093b 8 days ago 61.7MB
max2l/ui 3.0 04d702032f85 8 days ago 206MB
max2l/ui 2.0 d52ab9f8c18f 8 days ago 461MB
max2l/ui 1.0 aad5472f5a45 8 days ago 777MB
```
```
max2l/comment 4.0 17ddf9efd54a 27 minutes ago 40.8MB
max2l/comment 3.0 634ff7b3ec7e 8 days ago 53.6MB
max2l/comment 2.0 12fc7affcc34 8 days ago 198MB
max2l/comment 1.0 3bd4aa40389b 8 days ago 769MB
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
docker run -d --network=reddit -p 9292:9292 -e "POST_SERVICE_HOST=post_new_alias" -e "COMMENT_SERVICE_HOST=comment_new_alias" max2l/ui:2.0
```
---
## Homework 16. Docker. сети, docker-compose.
### В процессе сделано:
  - Произведена установка `docker-compose`.
  - Запушен контейнер с сетевым драйвером `none`. Произведена диагностика работы сетевого стека контейнера.
  - Запущено несколько контейнеров Docker с образом `Nginx` в сетевом пространстве хоста. При запуске второго и последующего контейнера они падают с ошибкой. Это связано с тем, что порт 80 на хосте уже занят первым запущенным контейнером. Увидеть это можно выполнив команду
```
docker logs db4aeed79c69
2018/05/01 11:17:01 [emerg] 1#1: bind() to 0.0.0.0:80 failed (98: Address already in use)
nginx: [emerg] bind() to 0.0.0.0:80 failed (98: Address already in use)
2018/05/01 11:17:01 [emerg] 1#1: bind() to 0.0.0.0:80 failed (98: Address already in use)
nginx: [emerg] bind() to 0.0.0.0:80 failed (98: Address already in use)
2018/05/01 11:17:01 [emerg] 1#1: bind() to 0.0.0.0:80 failed (98: Address already in use)
nginx: [emerg] bind() to 0.0.0.0:80 failed (98: Address already in use)
2018/05/01 11:17:01 [emerg] 1#1: bind() to 0.0.0.0:80 failed (98: Address already in use)
nginx: [emerg] bind() to 0.0.0.0:80 failed (98: Address already in use)
2018/05/01 11:17:01 [emerg] 1#1: bind() to 0.0.0.0:80 failed (98: Address already in use)
nginx: [emerg] bind() to 0.0.0.0:80 failed (98: Address already in use)
2018/05/01 11:17:01 [emerg] 1#1: still could not bind()
```
  - При запуске контейнеров с драйвером `none` для каждого контейнера создается отдельный Network Name Space. Это необходимо для изоляции сетевого стека контейнеров друг от друга и от хоста. При запуске контейнеров с сетевым драйвером `host` они создаться в Network Name Space `default`.
  - При запуске контейнеров с сетевым драйвером `bridge` взаимосвязь контейнеров происходит за счет сетевого моста, что в свою очередь дает ряд новых особенностей.
    - Можно производить запуск нескольких контейнеров использующих фиксированные порты не опасаясь конфликта с сетевым стеком хоста на котором запушен Docker
    - Каждый запушенный `bridge` интерфейс имеет префикс сети создаваемой в Docker и он связан с сетевыми интерфейсом внутри контейнера входящего в эту сеть.
    - Создаваемые сети могут быть изолированы друг от друга.
    - Созданные в Docker сети транслируются в сеть сервера на котором он запушен.
    - В случае определения портов при запуске контейнера, эти порты будут транслироваться в сеть Docker хоста
    - Для трансляции портов используется `docker-proxy`
  - Настроен `docker-compose.yml` для автоматизации запуска контейнеров используя `docker-compose`
  - При запуске контейнеров через `docker-compose` необходимо определить переменные окружения в файле `.env`
  - Базовое имя проекта образуется из названия корневой директории. Задать другое базовое имя можно либо переименовав текущую директорию, либо задав переменную окружения COMPOSE_PROJECT_NAME, либо запустить проект с опцией `-p`. В случае запуска проекта с этой опцией все дальнейшие действия так же необдодимо производить с этой опцией. 
```
docker-compose -p new_project_base_name up -d
docker-compose -p new_project_base_name down
```
  - Для возможности редактирования кода каждого из приложений без пересборки образов.
    - Cозданы тома с типом `bind`.
    - Источники этих томов находятся в директориях `src/ui/`, `src/comment/`, `src/post-py/`.
    - Целевая директория этих томов находится в каталоге `/app` 
  - Для запуска приложений Puma в `docker-compose.override.yml` переопределены команды запуска по умолчанию ипи старте Docker контейнеров.
     
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
  - Список Network Name Space
```
sudo ip netns
```
  - Просмотр сетевых интерфейсов в определенном сетевом Name Space
```
sudo ip netns exec 234f51036f69 ip a
sudo ip netns exec default ip a
```
  - Запуск проекта reddit с сетевым драйвером `bridge` 
```
docker network create reddit
docker run -d --network=reddit --network-alias=post_db --network-alias=comment_db mongo:latest
docker run -d --network=reddit --network-alias=post max2l/post:1.0
docker run -d --network=reddit --network-alias=comment max2l/comment:1.0
docker run -d --network=reddit -p 9292:9292 max2l/ui:1.0
```
 - Запуск контейнеров в изолированных сетях 
```
 docker network create back_net --subnet=10.0.2.0/24
 docker network create front_net --subnet=10.0.1.0/24
 docker run -d --network=front_net -p 9292:9292 --name ui max2l/ui:1.0
 docker run -d --network=back_net --name comment max2l/comment:1.0
 docker run -d --network=back_net --name post max2l/post:1.0
 docker run -d --network=back_net --name mongo_db --network-alias=post_db --network-alias=comment_db mongo:latest
 docker network connect front_net post
 docker network connect front_net comment
```
 - Список сетевых namespaces 
```
sudo ip netns
564e8fa2b2b7
52a698935e1b
default
```
 - Список запушенных контейнеров
```
docker ps
CONTAINER ID        IMAGE                        COMMAND                 CREATED             STATUS              PORTS               NAMES
2ebdb7ee5007        joffotron/docker-net-tools   "sh -c 'sleep 10000'"   2 minutes ago       Up 2 minutes                            net_test5
9c3ba2c1a484        joffotron/docker-net-tools   "sh -c 'sleep 10000'"   2 minutes ago       Up 2 minutes                            net_test4
f79e4fce0e14        joffotron/docker-net-tools   "sh -c 'sleep 10000'"   2 minutes ago       Up 2 minutes                            net_test3
cfaee642096f        joffotron/docker-net-tools   "sh -c 'sleep 10000'"   2 minutes ago       Up 2 minutes                            net_test1
c6014c9bfd54        joffotron/docker-net-tools   "sh -c 'sleep 10000'"   2 minutes ago       Up 2 minutes                            net_test2
```
 - Сетевые интерфейсы в Network Name Space `default`
```
sudo ip netns exec default ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever
2: ens4: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1460 qdisc pfifo_fast state UP group default qlen 1000
    link/ether 42:01:0a:84:00:02 brd ff:ff:ff:ff:ff:ff
    inet 10.132.0.2/32 brd 10.132.0.2 scope global ens4
       valid_lft forever preferred_lft forever
    inet6 fe80::4001:aff:fe84:2/64 scope link
       valid_lft forever preferred_lft forever
4: docker0: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc noqueue state DOWN group default
    link/ether 02:42:37:a8:dd:3a brd ff:ff:ff:ff:ff:ff
    inet 172.17.0.1/16 brd 172.17.255.255 scope global docker0
       valid_lft forever preferred_lft forever
```
  - Сетевые интерфейсы в Network Name Space созданом при запуске контейнера с сетевым драйвером `none`
```
sudo ip netns exec 0e4e37b7ec14 ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
```
```
sudo ip netns exec 234f51036f69 ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
```
  - Комманды для связи контейнеров с другими сетями docker.
```
docker network connect front_net post
docker network connect front_net comment
```
---
## Homework 17. Gitlab CI. Построение процесса непрерывной интеграции.
### В процессе сделано:
  - Создана виртуальная машина в GCP и произведена omnibus-установка `GitLab CI` с использованием docker-compose.
  - Отключена регистрация новых пользователей.
  - В группе `homework` Создан новый проект `example`
  - Произведена интеграция git репозитория `max2l_microservices` в созданном инстансе `GitLab CI`.
  - Описан `pipeline` в файле `.gitlab-ci.yml`.
  - Создан и зарегистрирован `Runner`.
  - Настроенно тестирование проекта с использованием `pipeline`.
  - Произведено тестирование проекта.
  - Настроенна интеграция `gitlab` и `slack`.
  - Для установки нескольких инстансев `Gitlab Runner` разработана конфигурация для `Terraform`. Количество поднимаемых интансев необходимо задать в переменной `count_instances` изменив файл `terraform/terraform.tfvars`. Для оптимизации времени разворачивания инстансев можно создать образ с установленным `docker` и `Girlab Runner` используя `Packer`.
  - Если необходимо произвести установку `Runner` не в облаке, а на "железных" серверах с предустановленной OC, то для этого можно использовать `Ansible`. Предварительно на серверах должны быть "разложены" ssh ключи. 
  - Если это действие необходимо произвести только один раз, то можно использовать утилиту `pdsh`. При этом на всех серверах должен быть настроем доступ по ssh ключам.
### Как запустить проект:
  - Интеграции git репозитоиря `GitLab CI`.
```
git checkout -b gitlab-ci-1
git remote add gitlab http://max2l_microservices/homework/example.git
git push gitlab gitlab-ci-1
```
  - Создание `Runner`.
```
docker run -d --name gitlab-runner --restart always \
-v /srv/gitlab-runner/config:/etc/gitlab-runner \
-v /var/run/docker.sock:/var/run/docker.sock \
gitlab/gitlab-runner:latest
```
  - Регистрация `Runner`.
```
docker exec -it gitlab-runner gitlab-runner register
```
или 
```
docker exec -it gitlab-runner gitlab-runner register \
    --non-interactive \
    --url "http://35.233.54.249/" \
    --registration-token "Token for runer in gitlab" \
    --executor "docker" \
    --docker-image alpine:latest \
    --description "docker-runner" \
    --tag-list "linux,xenial,ubuntu,docker" \
    --run-untagged \
    --locked="false"
```
  - Запуск нескольких инстансев `Runner`.
    - Количество запускаемых инстансев задается в переменной `count_instances`. Для этого необходимо отредактировать файл `terraform/terraform.tfvars`
    - Далее необходимо выполнить команды
```
terraform play
terraform apply
```
---
## Homework 18. Gitlab CI. Непрерывная поставка
### В процессе сделано:
  - Создан новый проект в `GitLab` с именем `example2`
  - Ветка `gitlab-ci-2` настроена для работы с новым проектом.
  - Настроен `runner` для работы с новым проектом.
  - Настроены окружения `dev`, `stage` и `prod` для работы с новым проектом.
  - Настроено два `job` для запуска проекта с использованием кнопки.
  - Настроена работа этапов `stage` и `production` только при наличии тегов в ветке репозитория.
  - Настроены динамические окружения для работы `GitLab`
  - Создан контейнер `max2l/docker_machine_gcp` содержащий `docker`, `docker-machine` и `google-cloud-sdk` для упрощения развертывания и удаления новых серверов и для деплоя приложений.
  - Настроено создание нового сервера при пуше в репозиторий ветки отличной от `master`.
  - Настроено удаление созданного сервера с использованием кнопки.
  - В шаге `build` настроена сборка нового контейнера с приложением `reddit`.
  - Настроено развертывание приложения на созданном сервере.
   
### Как запустить проект:
  - Запуск остановленого проэкта
```
docker-machine start docker-host
```
  - Соединение с виртуальной машиной для изменения настроек
```
docker-machine start docker-host
```
  - При запуске сервера с использованием `docker-machine` необходимо убедиться, что IP сервера не изменился. Если IP изменился, то необходимо:
    - Поменять IP адрес в настройках `runner` по пути `/srv/gitlab-runner/config/config.toml`.
    - Поменять настройки `GitLab` в docker-compose файле по пути `/srv/gitlab/docker-compose.yml`
  - Все созданные `job` должны работать без ошибок.
  - При пуше ветки отличной от мастера должен создаться новый сервер.
  - На сервере должно развернуться `reddit` приложение.
---
## Homework 19. Введение в мониторинг. Системы мониторинга
### В процессе сделано:
  - Произведена настройка правил фаервола для работы с `Prometheus` и `Puma`.
  - Создан Docker хост в GCE и на нем развернута система монитринга `Prometheus`.
  - Произведен анализ метрик и целей `Targets` которые `Prometheus` собирает по умолчанию.
  - Произведена настройка `Prometheus` для интеграции микросервисов приложения `Puma`.
  - Произведена пере сборка Docker образов для интеграции с `Prometheus`
  - Автоматизирован запуск контейнеров с помощью `docker-compose`.
  - Произведен анализ метрик, целей и healthchecks микросервисов приложения `Puma`
  - Настроен `Node exporter` для сбора информации о работе Docker хоста.
  - Произведен анализ метрик которые формирует `Node exporter`.
  - Созданые Docker образы сохранены в **docker hub**.
  - Добавлен в `Prometeus` мониторинг базы `MongoDB` с помощью экспортера `mirantisworkloads/mongodb-prometheus-exporter`.
  - Добавлен мониторинг микросервисов **comment**, **post**, **ui** с помощью blackbox экспортера `Cloudprober`.
  - Создан `Makefile` для автоматизации сборки Docker образов и сохранения их в `Git Hub`.
### Как запустить проект:
  - Правила фаервола для работы `Prometheus` и `Puma`.
```
gcloud compute firewall-rules create prometheus-default --allow tcp:9090
gcloud compute firewall-rules create puma-default --allow tcp:9292
```
  - Создание Docker хоста в GCE.
```
export GOOGLE_PROJECT=docker-201806
docker-machine create --driver google \
        --google-machine-image https://www.googleapis.com/compute/v1/projects/ubuntu-os-cloud/global/images/family/ubuntu-1604-lts \
        --google-machine-type n1-standard-1 \
        --google-zone europe-west1-b docker-host
docker-machine ls
eval $(docker-machine env docker-host)
```
  - Просмотреть все метрики можно по url `http://gcp_host_ip:9292/metrics`.
  - Просмотреть `targets` можно по url `http://gcp_host_ip:9292/targets`.
  - Удаление Docker хоста в GCP.
```
docker-machine rm docker-host
```
  - Ссылки на docker images.
```
https://hub.docker.com/r/max2l/prometheus/
https://hub.docker.com/r/max2l/ui/
https://hub.docker.com/r/max2l/post/
https://hub.docker.com/r/max2l/comment/
https://hub.docker.com/r/max2l/cloudprober/
```
  - Удаление Docker сервера.
```
docker-machine rm docker-host
```
---
## Homework 20.Мониторинг приложения. Визуализация. Алертинг.
### В процессе сделано:
  - Создан отдельный файл `docker-compose-monitoring.yml` для разворачивания контейнеров относящихся к мониторингу.
  - Развернут анализатор ресурсов `cAdvisor`.
  - Развернута система мониторинга `Grafana`.
  - Произведена интеграция `cAdvisor` и `Grafana` с системой мониторинга `Prometeus`.
  - Добавлена информация о post сервисе в конфигурацию `Prometheus`.
  - Создан график для отображения частоты вазова страниц микросервиса UI.
  - Создан график для отображения частоты вазова страниц с HTTP кодами `4XX` `5XX`.
  - Создан график отображающий 95 перцентиль выборки времени отображения запросов с помощью функции `histogram_quantile()`
  - Настроена интеграция `alertmanager` с `slack` чатом.
  - В `Makefile` добавлена сборка docker образа `alertmanager`
  - Настроен механизм сбора метрик системой монитоирнга `Prometheus` c использованием внутренего механизма `docker`.
  - Настроен dashboard в системе монитоирнга `grafana` для сбора метрик docker. Он сохранен в файле `Docker Engine Metrics-1527599358801.json`.
  - Настроен сбор метрик докер контейнеров с помощю `Teregram`. Настроено постраение графиков в `Grafana`. Dashboard сохранен в файле `Prometheus Telegraf Docker-1527679877145.json`.
  - Настроены уведомления при превышении 95 перцентиля времени ответа UI.
  - Настроены email нотификации.
### Как запустить проект:
  - Запуск контейнеров с микросервисами приложения `Puma`
```
docker-compose up -d
```
  - Запуск контейнеров для мониторинга приложения `Puma`
```
docker-compose -f docker-compose-monitoring.yml up -d
```
  - Создание правила firewall для доступа к анализатору ресурсов `cAdvisor`.
```
gcloud compute firewall-rules create cadvisor-default --allow tcp:8080
```
  - Создание правила firewall для доступа к системе мониторинга `Grafana`.
```
gcloud compute firewall-rules create grafana-default --allow tcp:3000
```
 - Запуск `Grafana`
```
docker-compose -f docker-compose-monitoring.yml up -d grafana
```
  - Пересоздание docker инфраструктуры мониторинга.
```
docker-compose -f docker-compose-monitoring.yml down
docker-compose -f docker-compose-monitoring.yml up -d
```
  - Выражение дня построения графика отображающего 95 перцентиль выборки времени отображения запросов.
```
histogram_quantile(0.95, sum(rate(ui_request_latency_seconds_bucket[5m])) by (le))
```
  - Создание правила firewall для доступа к `Alertmanager`.
```
gcloud compute firewall-rules create alertmanager-default --allow tcp:9093
```
---
## Homework 21. Логирование и треисинг.
### В процессе сделано:
  - Собраны Docker образы для работы со стеком ELK.
  - Развернут Docker хост в облаке GCP.
  - Создан compose файл `docker/docker-compose-logging.yml` для разворачивания стека ELK.
  - В дикектории `logging/fluentd` созданы файлы для разворачивания docker контейнера `Fluentd`. Его зауск нербходимо производить с использованием compose файла `docker/docker-compose-logging.yml`.
  - В файле `logging/fluentd/fluent.conf` описана конфигурация `Fluentd`.
  - Настроена отправка логирования событий возникающих при работе контейнера `post` в `Fluentd`.
  - Произведен анализ логов работы контейнеров приложения `Puma`.
  - Созданы фильтры для разбивки структурированных и не структурированных логов на поля.
  - Развернут сервис для распределенного трейсинга `Zipkin`.
  - Произведен анализ "долгой" работы микросервисов приложения `Puma` с использованием `Zipkin`. В ходе анализа установлено:
    - Самая большая задержка при работе приложения связана с долгим откликом микросервиса `post`. Каждое обращение книму занимает не менее 3 секунд.
    - В микросервисе `post` наиболее долго отрабатывает span `db_find_single_post`
    - Долгая работа связана из - за присутствия в коде декоратора `@zipkin_span` выражения `time.sleep(3)`.
    
### Как запустить проект:
 - Создание docker хоста
```
docker-machine create --driver google --google-machine-image     https://www.googleapis.com/compute/v1/projects/ubuntu-os-cloud/global/images/family/ubuntu-1604-lts \
    --google-machine-type n1-standard-1 \
    --google-open-port 5601/tcp \
    --google-open-port 9292/tcp \
    --google-open-port 9411/tcp \
    logging
```
  - Cборка docker образа `Fluentd`.
```
docker build -t max2l/fluentd
```
  - Запуск микросервисов приложения `Puma`
```
docker-compose up -d
```
  - Просмотр событий формируемых при работе docker контейнера микросервиса `post`.
```
docker-compose logs -f post
```
  - Запуск контенеров `ELK` и `Fluentd`
```
docker-compose -f docker-compose-logging.yml up -d
```
  - Фильтр для `UI` сервиса который производит разбивку неструктурированного лога на поля. 
```
<filter service.ui>
  @type parser
  format grok
  grok_pattern service=%{WORD:service} \| event=%{WORD:event} \| path=%{GREEDYDATA:path} \| request_id=%{GREEDYDATA:request_id} \| remote_addr=%{IPV4:remote_addr} \| method= %{WORD:method} \| response_status=%{NUMBER:response_status}
  key_name message
</filter>
```
  - Настройка firewall для доступа к приложению `Zipkin`.
```
gcloud compute firewall-rules create zipkin-default --allow tcp:9411
```
---
## Homework 22. Введение в Kubernetes.
### В процессе сделано:
  - Созданы манифест файлы для разворачивания микросервисов приложения `Puma`
  - Развернут `Kubernates` кластер. Дле этого было сделано.
    - Установлены `cfssl`, `cfssljson` и `kubectl`.
    - В GCP создана сеть `kubernetes-the-hard-way ` и правила фаервола `kubernetes-the-hard-way-allow-internal` `kubernetes-the-hard-way-allow-external` для взаимодействия между элементами кластера в этой сети.
    - Зарезервирован публичный IP адрес.
    - Развернуты ноды для управления кластером `Kubernetes`.
    - Развернуты `Workers` ноды.
    - Созданы сертификаты необходимые для работы кластера. 
    - Созданы конфигурационные файлы.
    - Создан конфигурационный файл для формирования ключа шифрования.
    - Развернут и запущен `etcd`  кластер.
    - Настроено и  запущено  `Kubernetes Control Plane`.
    - Настроен и  запущен  `Kubernetes API Server`.
    - Настроен и  запущен `Kubernetes Controller Manager`.
    - Настроен `Kubernetes Scheduler`.
    - Активирован `HTTP Health Checks`.
    - Настроена RBAC авторизация для Kubelet.
    - Настроен и запушен `Frontend Load Balancer`.
    - Настроены Worker ноды.
    - Настроен `Kubelet` на Worker нодах.
    - Настроен `Kubernetes Proxy` на Worker нодах.
    - Настоен `kubectl` для удаленого доступа.
    - Настроена `Pod Network` маршрутизация. 
    - Установлен `DNS Cluster Add-on`.
  - Установлены микросервисы приложения `Puma` на `Kubernetes` кластер.
  - Созданы плейбуки для автоматизации процесса создания кластера `Kubernetes`.
  
### Как запустить проект:
  - Запуск кластера `etcd`
    ```
    sudo systemctl daemon-reload
    sudo systemctl enable etcd
    sudo systemctl start etcd
    ```
  - Запуск  `Controller Services`
    ```
    sudo systemctl daemon-reload
    sudo systemctl enable kube-apiserver kube-controller-manager kube-scheduler
    sudo systemctl start kube-apiserver kube-controller-manager kube-scheduler
    ```
  - Запуск `Frontend Load Balancer`.
    ```
    sudo systemctl restart nginx
    sudo systemctl enable nginx
    ```
  - Запуск worker services
    ```
    sudo systemctl daemon-reload
    sudo systemctl enable containerd kubelet kube-proxy
    sudo systemctl start containerd kubelet kube-proxy
    ```
  - Просмотр таблицы маршрутизации для `Pod Network`
    ```
    gcloud compute routes list --filter "network: kubernetes-the-hard-way"
    ```
  - Установка микросервисов приложения `Puma` на кластер `Kubernates`. 
    ```
    kubectl apply -f kubernetes/reddit/mongo-deployment.yml
    kubectl apply -f kubernetes/reddit/comment-deployment.yml
    kubectl apply -f kubernetes/reddit/post-deployment.yml
    kubectl apply -f kubernetes/reddit/ui-deployment.yml
    ```
  - Создание кластера `Kubernetes` с использованием ansible плейбуков
    ```
    ansible-playbook kubernetes/ansible/create_kubernates_gcp.yml
    ansible-playbook kubernetes/ansible/remove_kubernates_gcp.yml 
    ```
---
## Homework 23. Kubernetes.Controllers,Security.
### В процессе сделано:
  - Развернуто локальное окружение для работы с `Kubernetes`.
    - Установлен `kubectl`.
    - Установлен `Minikube`.
    - Запушен Minukube-кластер.
    - Произведена проверка работы кластера.
    - Изучена конфигурация `kubectl`.
    - Созданы Deployment ресурсы для микросервисов приложения `Puma`.
    - Все микросервисы запушены в `Kubernetes` кластере.
    - Настроена взаимосвязь с использованием `Services` между микросервисами приложения.
    - Настроены переменные окружения для взаимодействия контейнеров с контейнером базы `mongodb`.
    - Настроено взаимодействие с микросервисом `ui` из внешней сети.
    - Произведен анализ работы кластера используя `dashboard`
    - Настроен отдельный `Namespace` для запуска в нем микросервисов.
    - Добавлена информация о `Namespace` в `UI`
  - Развернут `Kubernetes` в GKE.
    - Создан кластер в GCP с использованием web консоли.
    - Настроено подключение minikube к кластеру `Kubernetes`.
    - Настроены правила фаервола для подключению к приложению `Puma` из внешней сети.
  - Запущен reddit в `Kubernetes`.
  - Произведен запуск `Dashboard`и анализ работы кластера.
  - Настроен запуск кластера GCP c использованием `terraform`

### Как запустить проект:
  - Запуск микросервисов в кластере.
  ```
  kubectl apply -f ui-deployment.yml
  kubectl apply -f post-deployment.yml
  kubectl apply -f comment-deployment.yml
  kubectl apply -f mongo-deployment.yml
  ```
  - Проверка статуса депроя микросервисов
  ```
  kubectl get deployment
  ```
  - Просмотр pods с использованием `selector`
  ```
  kubectl get pods --selector component=ui
  ```
  - Проблос порта на локальную машину.
  ```
  kubectl port-forward <pod-name> 8080:9292
  ```
  - Просмотр `Services`.
  ```
  kubectl describe service comment
  ```
  - Запуск команд внутри pods.
  ```
  kubectl exec -ti <pod-name> nslookup comment
  ```
  - Просмотр событий внутри pod
  ```
  kubectl logs <pod-name>
  ``` 
  - Удаление сервисов.
  ```
  kubectl delete -f mongodb-service.yml
  kubectl delete service mongodb
  ```
  - Запуск микросервиса `UI` в веб браузере.
  ```
  minikube service ui
  ```
  - Просмотр всех сервисов.
  ```
  minikube services list
  ```
  - Просмотр всех расширений `Minicube`
  ```
  minikube addons list
  ```
  - Просмотр всех объектов в namespase `kube-sysytem`
  ```
  kubectl get all -n kube-system --selector k8s-app=kubernetes-dashboard
  ```
  - Запуск dashboard.
  ```
  minikube service kubernetes-dashboard -n kube-system
  ```
  - Деплой всех манифест файлов.
  ```
  kubectl apply -f ./kubernetes/reddit
  ```
  - Запуск `Puma` в `namespace` dev
  ```
  kubectl apply -n dev -f
  minikube service ui -n dev
  ```
  - Определение внешнего IP и порта для соединения с кластером.
  ```
  kubectl get nodes -o wide
  kubectl describe service ui|grep NodePort
  ```
  - Запуск кластера `Kubernetes` с использованием `terraform`.
  ```
  cd kubernetes/terraform/
  terraform apply
  ```
---
## Homework 24. Kubernetes. Network. Storage.
### В процессе сделано:
  - Изучено назначение и принцип работы компонентов `kube-dns`, `kubenet` и `kube-proxy`
  - Произведена настройка и проверка работы приложения `Puma` с использованием балансировщика GCP.
  - Произведена настройка `LoadBalancer` с использованием контролера для балансировки `Ingress Controller`.
  - Произведена терминация TLS трафика на балансировщике, для этого:
    - Создан само подписанный сертификат.
    - Сертификат загружен в кластер `Kubernetes`.
    - Произведена проверка загруженного сертификата.
    - Произведена настройка `Ingress` балансировщика для работы только с https трафиком.
    - Созданный объект `Secret` описан в виде манифеста.
  - Для проекта `docker-201806` в GCE включен `network-policy`.
  - Произведена настройка политик ограничения сетевого трафика между микросервисами приложения `Puma`.
  - Произведена настройка работы базы данных `MongoDB` с использованием различных видов томов `Volumes`.
  - Изучены особенности различных типов томов и механизмов работы с дисковыми хранилищами `emptyDir`, `gcePersistentDisk`, `PersistentVolume`.
  - Настроено динамическое выделение `Volumes` с использованием различных `StorageClass`.
### Как запустить проект:
  - После настройки работы приложения с использованием балансировщика `GCP` необходимо:
    - Узнать внешний IP для доступа к балансировщику.
      ```
      kubectl get service  -n dev --selector component=ui
      ```
    - Приложение `Puma` должно быть доступно по url `http://external_lb_ip`.
    - В web консоли GCP будет создано правило для балансировки.
  - Просмотр работы `Ingress Controller`.
    ```
    kubectl get ingress -n dev
    ```
  -  Настройка терминации https трафика.
      - Генерация сертификата
        ```
        openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout tls.key -out tls.crt -subj "/CN=external_ingress_ip"
        ```
      - Загрузка сертификата в кластер `Kubernetes`
        ```
        kubectl create secret tls ui-ingress --key tls.key --cert tls.crt -n dev
        ```
      -  Проверка загрузки сертификата.
          ```
          kubectl describe secret ui-ingress -n dev
          ```
      -  Применение настроек балансировщика описанных в манифест файле.
          ```
          kubectl delete ingress ui -n dev
          kubectl apply -f ui-ingress.yml -n dev
          ```
  - Для проверки настройки терминации https можно использовать url https://external_lb_ip
  - Включение `network-policy` для GKE
   ```
   gcloud beta container clusters update   --zone=us-central1-a --update-addons=NetworkPolicy=ENABLED
   gcloud beta container clusters update  docker-201806 --zone=us-central1-a  --enable-network-policy
   ```
  - Применение политик `network-policy`
    ```
    kubectl apply -f mongo-network-policy.yml -n dev
    ```
  - Создание диска в GCP
    ```
    gcloud compute disks create --size=25GB --zone=us-central1-a reddit-mongo-disk
    ```
  - Монтирование  диска к POD-ам.
    ```
    kubectl apply -f mongo-deployment.yml -n dev
    ```
  - Добавление `PersistentVolume` в кластер.
    ```
    kubectl apply -f mongo-volume.yml -n dev
    ```
  - Добавление запроса `PersistentVolumeClaim` в кластер.
    ```
    kubectl apply -f mongo-claim.yml -n dev
    ```
  - Подключение `PersistentVolumeClaim` к нашим Pod-ам.
    ```
    kubectl apply -f mongo-deployment.yml -n dev
    ```
  - Добавление `StorageClass` в крастер.
    ```
    kubectl apply -f storage-fast.yml -n dev
    kubectl apply -f mongo-claim-dynamic.yml -n dev
    kubectl apply -f mongo-deployment.yml -n dev
    ```
  - Просмотр созданных `Persistent Volumes`.
    ```
    kubectl get persistentvolume -n dev
    ```
---
## Homework 25. Интеграция Kubernetes в GitlabCI.
### В процессе сделано:
  - Произведена установка клиентской и серверной части `Helm`.
  - Подготовлена структура файлов для установки `Chart` для `UI` компонента.
  - Произведена установка `Chart` для `UI` компонента.
  - `Chart` для `UI` изменен для запуска нескольких ресурсов.
  - Произведена шаблонизация сущностей используемых для компонента `UI`.
  - Установлено несколько релизов `UI`.
  - Произведена проверка работы запущенных `UI` релизов.
  - Добавлены пользовательские переменные для `Chart` компонента `UI`.
  - Настроены `Charts` для компонентов `POST` и `COMMENT`.
  - Произведена интеграция `Charts` с `MongoDB`.
  - Созданы `helpers` и функции `templates` для всех `Charts`.
  - Создан единый `Chart` `reddit` который объединит все ранее созданные компоненты.
  - Добавлен `Chart` из общедоступного репозитория `stable/mongodb`.
  - Определены переменные окружения и настроенно взаимодействия между `Chard's`.
  - Добавлен новый пул узлов для разворачивания `gitlab`.
  - Произведена установка `gitlab` 
  - Созданы проекты для работы с микросервисами.
  - Настроен задачи CI `Build`,`Test`,`Release` для проектов `UI`, `Post`, `Comment`.
  - Произведена проверка корректности сборки образов.
  - Произведена настройка конфигурации ингреса и values для микросервиса `UI`.
  - Настроена запуск приложения в отдельном окружении для при комите в бранче отличном от мастера.
  - Настроено удаление отдельного созданного временного окружения.
  - Созданы 2 окружения (`Staging` и `Production`) в gitlab.
### Как запустить проект:
  - Запуск tiller-сервера
    ```
    kubectl apply -f tiller.yml
    helm init --service-account tiller
    ```
  - Проверка установки серверной части `Helm`.
    ```
    kubectl get pods -n kube-system --selector app=helm
    ```
  - Усановка `Chart`.
    ```
    helm install --name test-ui-1 ui/
    ```
  - Проверка установки `Chart`.
    ```
    helm ls
    ```
  - Установка нескольких релизов `UI`.
    ```
    helm install ui --name ui-1
    helm install ui --name ui-2
    helm install ui --name ui-3
    ```
  - Проверка созданных ингрессов.
    ```
    kubectl get ingress
    ```
  - Обновление установленных релизов.
    ```
    helm upgrade ui-1 ui/
    helm upgrade ui-2 ui/
    helm upgrade ui-3 ui/
    ```
  - Загрузить зависимости единого `Chart` `reddit`.
    ```
    helm dep update ./reddit
    ```
  - Поиск `Charts` в общедоступном репозитории.
    ```
    helm search mongo
    ```
  - Установка приложения с использованием общедоступного `Charts`
    ```
    helm install reddit --name reddit-test
    ```
  - Обновление релиза.
    ```
    helm upgrade reddit-test ./reddit
    ```
  - Установка `gitlab`
    ```
    helm install --name gitlab . -f values.yaml
    ```
  - Проверка запушенных pod's приложения `gitlab`
    ```
    kubectl get pods
    ```
---
