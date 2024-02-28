# eks-sample-app
## 前提
Docker,docker-composeがインストールされていること。
## ビルド手順
下記コマンドでビルドの実施
```
$ docker-compose build
…
```

Dockerコンテナの起動・確認
```
$ docker-compose up -d
⠿ Container eks-sample-app-app-1  Running

$ docker-compose ps
NAME                   COMMAND                  SERVICE             STATUS              PORTS
eks-sample-app-app-1   "/entrypoint.sh /sta…"   app                 running             443/tcp, 0.0.0.0:8080->80/tcp
```

curlもしくはブラウザから表示する
```
$ curl localhost:8080
Hello World from Kubernetes!!
```