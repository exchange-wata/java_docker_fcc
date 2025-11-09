# Java Docker 学習環境

ローカル PC に JDK をインストールせずに、Docker を使って Java 開発環境を構築します。

## 環境構成

- **Java**: OpenJDK 17
- **エディタ**: vim, nano (コンテナ内で使用可能)
- **Git**: インストール済み

## 使い方

### 1. コンテナの起動

```bash
docker-compose up
```

### 2. コンテナに入る

```bash
docker-compose exec java bash
```

### 3. Java プログラムの実行

コンテナ内で以下のコマンドを実行:

```bash
# 実行
# 任意のディレクトリへ移動後
java Main
```

### 4. コンテナの停止

```bash
docker-compose down
```

## Tips

- コンテナ内の `/workspace` ディレクトリは、ホストのプロジェクトディレクトリとマウントされています
- ホスト側でファイルを編集すると、コンテナ内にも反映されます
- コンテナを停止しても、ファイルは保持されます

## Java バージョンの確認

コンテナ内で以下のコマンドを実行:

```bash
java -version
```
