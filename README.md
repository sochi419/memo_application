## 概要
Sinatraで作成したシンプルなメモアプリです。
メモを作成、編集、削除、一覧で表示する機能があります。
## 手順

メモアプリをインストールする。
任意のディレクトリへ移動し、以下でGitHubリポジトリをクローンしてください。
````
$ git clone https://github.com/sochi419/memo_application
````

bundle install を実行し、必要なGemをインストールしてください。
````
& bundle install
````

### ※ 事前にデータベースの作成が必要になります

(事前にローカルにPostgresqlをインストールしてください)
PostgreSQLで自分のアカウントにログインする。

postgres起動
````
brew services start postgresql
````
データベース作成する。まず、postgresというDBに移動する。
````
psql postgres
````

`mydb`というデータベースを作成する。(データベース名は`mydb`以外にしないで下さい。)
````
create database mydb;
````


先ほど作成したデータベース`mydb`に移動。
````
psql mydb
````

`id`, `title`, `body`カラムを搭載したテーブル`books`を作成する。(テーブル名は`books`以外にしないで下さい。)
````
create table books(id integer, title text, body text);
````

## 実行
下記コマンドを実行してください
````
ruby memo.rb
````


ブラザウザへ下記URIを入力してください。
````
 http://localhost:4567/
````





