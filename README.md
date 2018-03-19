# max2l_infra
max2l Infra repository

## Описание конфигурации
В Данном домашнем задании используются 2 микросервера. Первый хост имеет имя bastion и внешний IP адрес 35.195.18.128. Второй хост c именем someinternalhost имеет только внутрений IP адрес 10.132.0.3. Связь с someinternalhost можно произвести только через bastion используя протокол SSH или VPN.

## Подключение

Для упрошения доступа к хостам через bastion хост можно создать алиас. Для этого необходимо в файл
```
  ~/.ssh/config
```

добавить следушие строчки  
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

Предворительно необходимо загрузить приватный ssh ключ в `ssh-agent` с помощью `ssh-add`   

## Сетевые настройки
```
bastion_IP = 35.195.18.128
someinternalhost_IP = 10.132.0.3
```

