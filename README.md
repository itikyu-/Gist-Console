# Gist-Console
Gistコード管理CUIツール
Gistへのアップロード・参照等を行うことが出来ます。

# 使い方

## 準備
1. [こちら](https://help.github.com/articles/creating-an-access-token-for-command-line-use/)を参考に個人トークンを発行して下さい。
2. ~/.config/github_personal_token というファイルを作成して個人トークンをここに保存して下さい。
3. 本リポジトリをPullして、binディレクトリ内のファイルに実行権限を付けて下さい。
4. お好みでPATHの通っているところにシンボリックリンクを作成して下さい。


## 実行例

### 概要(一覧)表示

一覧表示
```
$ gist-console list
```

言語で絞り込み
```
$ gist-console list -l Ruby Python
```

Descriptionで絞り込み
```
$ gist-console list -d hogehoge
```

非公開のみ
```
$ gist-console list -c 
```

### 個別表示

ファイルの内容を表示<br>
iオプションにて、GistIDを指定してやる必要があります。<br>
前方一致で検索して一意に特定できればID全体の指定は必要ありません。
```
$ gist-console show -i 12
```

ファイルとしてローカルに作成
```
$ gist-console show -i 12 -f
```

HTMLに埋め込むようのスクリプトを表示
```
$ gist-console show -i 12 -s
```

ローカルで実行した結果を表示
```
$ gist-console show -i 12 -e
```

### 投稿

Gistへの投稿<br>
Descriptionと公開・非公開をオプションにて指定
```
$ gist-console post -f main.rb input.txt -c -d "FileIOのサンプル"
```

## ヘルプ

ヘルプの表示
```
$ gist-console --help
```
