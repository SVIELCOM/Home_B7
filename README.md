main.tf - код для развертывания виртуалок в яндексе

kubernetes-setup/master-playbook.yml 	- ансибл-плейбук для разворачивания кластера кубера

kubernetes-setup/node-playbook.yml 		- ансибл-плейбук для разворачивания рабочей ноды в кластер

kubernetes-setup/join-command			- файл генерится автоматически

inventory								- файл генерится автоматически

kubernetes-setup/admin-*yml				- файлы добавления юзера для доступа в дашборд

terraform/_templates/inventory.tpl 		- файл шаблона для создания файла inventory

kubernetes-dashboard.png - скриншот DASHBOARD-а, который я так и не смог запустить с помощью 
kubectl proxy, 
получилось только через 
kubectl port-forward -n kubernetes-dashboard service/kubernetes-dashboard 8080:443

Страница открылась https://localhost:8080

11й пункт сделал руками, т.к. долго разбирался с версиями дашборда, которая бы открывалась через прокси.
Доступ внутрь дашборда через файл конфига не работает от слова совсем. Не разбирался, добавил юзера, запросил токен и с ним вошел.

