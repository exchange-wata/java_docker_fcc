# Java Docker 学習環境

ローカル PC に JDK をインストールせずに、Docker を使って Java 開発環境を構築します。

## 環境構成

- **Java**: Eclipse Temurin 21 (LTS)
- **Gradle**: 8.11.1
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
# Gradleでビルド
./gradlew build

# Gradleで実行
./gradlew run

# または直接Javaで実行
java -cp build/classes/java/main com.example.app.Main
```

### 4. コンテナの停止

```bash
docker-compose down
```

## Tips

- コンテナ内の `/workspace` ディレクトリは、ホストのプロジェクトディレクトリとマウントされています
- ホスト側でファイルを編集すると、コンテナ内にも反映されます
- コンテナを停止しても、ファイルは保持されます

## バージョンの確認

コンテナ内で以下のコマンドを実行:

```bash
# Javaバージョン確認
java -version

# Gradleバージョン確認
./gradlew --version
```

## Gradle コマンド

```bash
# ビルド
./gradlew build

# クリーンビルド
./gradlew clean build

# 実行
./gradlew run

# テスト
./gradlew test

# タスク一覧
./gradlew tasks
```

## プロジェクト構造

```
java_docker_fcc/
├── src/
│   ├── main/
│   │   ├── java/
│   │   │   └── com/example/app/
│   │   │       └── Main.java
│   │   └── resources/
│   └── test/
│       └── java/
├── build.gradle          # ビルド設定
├── settings.gradle       # プロジェクト設定
├── gradlew              # Gradle Wrapper (Unix/Mac)
└── gradle/
    └── wrapper/         # Gradle Wrapper設定
```
