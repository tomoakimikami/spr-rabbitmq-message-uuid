# DockerでRabbitMQ開発環境構築 #

基本方針として、erlangは任意のバージョンを使いたいので、OSが提供するパッケージ管理の仕組みを使わず、自力でビルドする。

## Docker ##

* 仮想マシンを作成

```bash:
$ docker-machine create --driver virtualbox rabbitmq
```

* 作成した仮想マシン情報を環境変数に反映

```bash:
$ eval `docker-machine env rabbitmq`
```

* コンテナ作成および起動

```bash:
$ docker run -it -name rabbitmq ubuntu:trusty /bin/bash

```
確認できたらとりあえずexitして、再接続

* コンテナ再起動および再接続

```bash:
$ docker start rabbitmq
$ docker exec -it rabbitmq /bin/bash
```

## Ubuntu ##

* パッケージ情報を最新に

```bash:
$ apt-get update
```

* 必要なパッケージを導入

```bash:
$ apt-get install build-essential libncurses5-dev openssl libssl-dev curl git-core python2.7 libxslt1-dev xmlto
```

### kerl ###

* 複数バージョン混在を考慮して、Erlangバージョン管理用にkerlを導入

```bash:
$ curl -O https://raw.githubusercontent.com/spawngrid/kerl/master/kerl
$ chmod a+x kerl
```

* (必要であれば)PATHを通す

```bash:
$ mkdir -p ~/bin
$ mv kerl ~/bin/
$ echo 'export PATH=$PATH:~/bin' >> ~/.bashrc
$ source ~/.bashrc
```

Erlangビルド用に、デフォルトのコンパイルオプションを保存しておく

```ini:~/.kerlrc
KERL_CONFIGURE_OPTIONS="--disable-hipe --enable-smp-support --enable-threads --enable-kernel-poll"
```

### Erlang ###

ここではバージョン18.3を使うこととする。

* 18.3をビルド

```bash:
$ kerl update releases
$ kerl build 18.3 18.3
$ kerl list builds
```

* ビルドした18.3を有効にする

```bash:
$ mkdir -p ~/.kerl/versions/18.3
$ kerl install 18.3 ~/.kerl/versions/18.3
$ . ~/.kerl/versions/18.3/activate
$ erl -v
```

### RabbitMQ ###

#### 作成したプラグインのビルド確認 ####

```bash:
$ git clone https://github.com/tomoakimikami/spr-rabbitmq-message-uuid.git
$ make
```

#### プラグインアーカイブファイル作成 ####

```bash:
$ make dist
```

* pluginsディレクトリ配下に*.ezファイルができているので、必要なもの(spr_rabbitmq_message_uuid.ez  uuid-1.4.0.ez)をRabbitMQのプラグインディレクトリへ配置し、rabbitmq-pluginsコマンドで有効化する。

