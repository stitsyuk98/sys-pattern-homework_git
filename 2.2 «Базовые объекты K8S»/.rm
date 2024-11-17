### Задание 1. Создать Pod с именем hello-world

1. Создать манифест (yaml-конфигурацию) Pod.
2. Использовать image - gcr.io/kubernetes-e2e-test-images/echoserver:2.2.
3. Подключиться локально к Pod с помощью `kubectl port-forward` и вывести значение (curl или в браузере).

### Решение 1

Выяснив порт по умолчанию в файле /etc/nginx/nginx.conf делаем(по умолчанию 8080 и 8443):

1. Создаем пространство для тестов
``` kubectl create namespace test```

2. Создаем под используя [манифест](manifests/echopod.yaml):
```kubectl apply -f manifests/echopod.yaml -n test ```

3. Форвардим внешний трафик на порт 8443 
``` kubectl port-forward -n test echoserver 8080:8443 --address <ip-адрес> ```

Получаем следующий ответ в браузере:
<img src='images/pod port-forward.png'/>

Вот результат подключения к поду:
<img src='images/connect_pod.png'/>

------

### Задание 2. Создать Service и подключить его к Pod

1. Создать Pod с именем netology-web.
2. Использовать image — gcr.io/kubernetes-e2e-test-images/echoserver:2.2.
3. Создать Service с именем netology-svc и подключить к netology-web.
4. Подключиться локально к Service с помощью `kubectl port-forward` и вывести значение (curl или в браузере).

### Решение 2

1. Создаем сервис используя [манифест](manifests/echoservice.yaml):
```kubectl apply -f manifests/echoservice.yaml -n test ```
Т.к. создается nodeport сервис, то nodeport назначается большим 30000

2. В результате получаем почти такой же вывод(только теперь client address совпадает с host , выделено):
<img src='images/service.png'/>


### Дополнительно

Чтобы не печатать манифест я пользовался командами:
1. Создания развертывания
```kubectl create deployment echoserver --image=gcr.io/kubernetes-e2e-test-images/echoserver:2.2 -n test```
2. Вывода манифеста развертывания:
```kubectl get deployment echoserver -n test -o yaml```
3. Создания сервиса:
```kubectl expose deployment echoserver -n test --port 8080 --target-port 8443 --type NodePort```
4. Вывода манифеста сервиса:
```kubectl get svc echoserver -n test -o yaml```