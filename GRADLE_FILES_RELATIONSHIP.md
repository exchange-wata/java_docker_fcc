# Gradle ファイル間の関係性ガイド

## 📋 目次

- [ファイル構成概要](#ファイル構成概要)
- [起動フロー](#起動フロー)
- [各ファイルの詳細](#各ファイルの詳細)
- [ファイル間の連携](#ファイル間の連携)
- [実践例](#実践例)
- [デバッグコマンド](#デバッグコマンド)

---

## 📁 ファイル構成概要

### コアファイル

```
java_docker_fcc/
├── settings.gradle                    # プロジェクトのルート設定
├── build.gradle                       # ビルド定義（最重要）
├── gradle.properties                  # グローバル設定（オプション）
└── gradle/
    └── wrapper/
        ├── gradle-wrapper.jar
        └── gradle-wrapper.properties  # Gradleバージョン指定
```

---

## 🔄 起動フロー

### ./gradlew build を実行した時の流れ

```
1. gradlew スクリプトが実行される
         ↓
2. gradle/wrapper/gradle-wrapper.properties を読み込み
   - 使用するGradleのバージョンを確認
         ↓
3. 指定バージョンのGradleをダウンロード（初回のみ）
   - ~/.gradle/wrapper/dists/ にキャッシュ
         ↓
4. settings.gradle を読み込み
   - プロジェクト名を決定
   - サブプロジェクトの構造を決定
         ↓
5. gradle.properties を読み込み（存在する場合）
   - グローバル設定を適用
         ↓
6. build.gradle を読み込み
   - プラグインを適用
   - 依存関係を解決
   - タスクを定義
         ↓
7. タスクグラフを構築
   - タスクの依存関係を解析
         ↓
8. タスクを実行
   - compileJava → test → jar など
```

**フェーズ別の整理**:

| フェーズ   | 実行内容               | 関連ファイル                    |
| ---------- | ---------------------- | ------------------------------- |
| **初期化** | プロジェクト構造の決定 | settings.gradle                 |
| **設定**   | ビルド設定の読み込み   | build.gradle, gradle.properties |
| **実行**   | タスクの実行           | src/, build/                    |

---

## 📝 各ファイルの詳細

### 1. settings.gradle - プロジェクトの入口

**読み込まれるタイミング**: Gradle 起動時（一番最初）

**主な役割**:

- プロジェクト名の定義
- マルチモジュール構成の定義
- プラグイン管理リポジトリの設定

#### シングルプロジェクト構成（現在）

```groovy
rootProject.name = 'java-docker-study'
```

#### マルチプロジェクト構成

```groovy
rootProject.name = 'my-company-project'

// サブプロジェクトを含める
include 'common'          // 共通ライブラリ
include 'api'             // API層
include 'web'             // Web層
include 'batch'           // バッチ処理
```

**ディレクトリ構造**:

```
my-company-project/
├── settings.gradle              # ルート設定
├── build.gradle                 # ルートのビルド設定
├── common/
│   ├── build.gradle
│   └── src/
├── api/
│   ├── build.gradle
│   └── src/
├── web/
│   ├── build.gradle
│   └── src/
└── batch/
    ├── build.gradle
    └── src/
```

#### 高度な使い方

```groovy
rootProject.name = 'java-docker-study'

// プラグイン管理（全サブプロジェクトで共通）
pluginManagement {
    repositories {
        gradlePluginPortal()
        mavenCentral()
    }

    // プラグインのバージョンを一元管理
    plugins {
        id 'org.springframework.boot' version '3.1.0'
    }
}

// 依存関係解決の設定
dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.FAIL_ON_PROJECT_REPOS)
    repositories {
        mavenCentral()
        maven { url 'https://jitpack.io' }
    }
}
```

---

### 2. build.gradle - ビルドスクリプト

**読み込まれるタイミング**: settings.gradle の後

**主な役割**:

- プラグインの適用
- 依存関係の定義
- タスクの定義
- ビルド設定

#### ファイル構造の詳細解説

```groovy
// ===============================
// 1. プラグイン適用
// ===============================
plugins {
    id 'java'           // Javaプロジェクトの基本機能
                        // - compileJava, test, jar タスクを追加
                        // - src/main/java, src/test/java を認識

    id 'application'    // 実行可能アプリケーション機能
                        // - run タスクを追加
                        // - mainClass 設定を提供
}

// ===============================
// 2. プロジェクトメタデータ
// ===============================
group = 'com.example'           // Maven座標のgroupId
                                // パッケージ名と一致させるのが慣例
version = '1.0-SNAPSHOT'        // バージョン番号
                                // SNAPSHOT = 開発中
                                // → 生成されるJAR: java-docker-study-1.0-SNAPSHOT.jar

// ===============================
// 3. Java設定
// ===============================
java {
    sourceCompatibility = JavaVersion.VERSION_21
    // ソースコードで使えるJava機能のバージョン
    // Java 21の文法（レコード、パターンマッチングなど）が使える

    targetCompatibility = JavaVersion.VERSION_21
    // 生成される.classファイルの互換性バージョン
    // Java 21 JVMで実行可能
}

// ===============================
// 4. アプリケーション設定
// ===============================
application {
    mainClass = 'com.example.app.Main'
    // gradle run で実行されるクラス
    // public static void main(String[] args) を持つクラス
}

// ===============================
// 5. リポジトリ設定
// ===============================
repositories {
    mavenCentral()      // Maven Central Repository
                        // 世界最大のJavaライブラリリポジトリ
                        // https://repo.maven.apache.org/maven2/

    // その他のリポジトリ例
    // google()         // Google's Maven repository
    // mavenLocal()     // ローカルの ~/.m2/repository
    // maven { url 'https://jitpack.io' }  // カスタムリポジトリ
}

// ===============================
// 6. 依存関係定義
// ===============================
dependencies {
    // テスト用ライブラリ
    testImplementation 'org.junit.jupiter:junit-jupiter:5.9.3'
    testRuntimeOnly 'org.junit.platform:junit-platform-launcher'

    // 依存関係の記法: 'group:name:version'
    // implementation 'com.google.guava:guava:31.1-jre'
}

// ===============================
// 7. タスク設定
// ===============================
tasks.named('test') {
    useJUnitPlatform()  // JUnit 5を使用
}

// ===============================
// 8. カスタムタスク
// ===============================
task watch(type: JavaExec) {
    group = 'application'
    description = 'Run the application with auto-reload'
    classpath = sourceSets.main.runtimeClasspath
    mainClass = application.mainClass
    standardInput = System.in
}
```

---

### 3. gradle-wrapper.properties

**場所**: `gradle/wrapper/gradle-wrapper.properties`

**役割**: Gradle Wrapper のバージョン管理

```properties
distributionBase=GRADLE_USER_HOME          # ダウンロード先のベースディレクトリ
distributionPath=wrapper/dists             # 実際の保存パス
distributionUrl=https\://services.gradle.org/distributions/gradle-8.11.1-bin.zip
                                           # ダウンロードするGradleのURL
zipStoreBase=GRADLE_USER_HOME              # ZIPファイルの保存先
zipStorePath=wrapper/dists                 # ZIPの保存パス
```

**実際の保存場所**:

```
~/.gradle/wrapper/dists/gradle-8.11.1-bin/
└── [hash]/
    └── gradle-8.11.1/
        ├── bin/
        ├── lib/
        └── ...
```

**バージョンの変更**:

```bash
# Gradleバージョンを8.11.1に更新
gradle wrapper --gradle-version 8.11.1

# または gradle-wrapper.properties を直接編集
```

---

### 4. gradle.properties（オプション）

**場所**: プロジェクトルートまたは `~/.gradle/gradle.properties`

**役割**: プロジェクト全体のプロパティ設定

**作成例**:

```properties
# ================================
# Gradle実行設定
# ================================
org.gradle.daemon=true              # Gradleデーモンを使用（ビルド高速化）
org.gradle.parallel=true            # 並列ビルドを有効化
org.gradle.caching=true             # ビルドキャッシュを有効化
org.gradle.configureondemand=true   # オンデマンド設定（大規模プロジェクト用）

# JVMメモリ設定
org.gradle.jvmargs=-Xmx2g -XX:MaxMetaspaceSize=512m -XX:+HeapDumpOnOutOfMemoryError

# ================================
# プロジェクト設定
# ================================
version=1.0.0
group=com.example

# ================================
# カスタムプロパティ
# ================================
# build.gradle で project.property('myCustomProperty') でアクセス可能
myCustomProperty=someValue
databaseUrl=jdbc:postgresql://localhost:5432/mydb

# ================================
# プロファイル別設定
# ================================
# gradle -Pprofile=prod build でアクセス
profile=dev
```

**build.gradle でプロパティを使用**:

```groovy
def dbUrl = project.hasProperty('databaseUrl')
    ? project.property('databaseUrl')
    : 'jdbc:h2:mem:testdb'

println "Using database: ${dbUrl}"
```

---

## 🔗 ファイル間の連携

### ケース 1: シングルプロジェクト（現在の構成）

```
settings.gradle
  ↓ プロジェクト名を定義: 'java-docker-study'

build.gradle
  ↓ ビルド設定を定義
  ├── plugins: java, application
  ├── dependencies: JUnit
  └── mainClass: com.example.app.Main

src/main/java/com/example/app/Main.java
  ↓ コンパイル (compileJava タスク)

build/classes/java/main/com/example/app/Main.class
  ↓ パッケージング (jar タスク)

build/libs/java-docker-study-1.0-SNAPSHOT.jar
```

### ケース 2: マルチプロジェクト構成

**settings.gradle**:

```groovy
rootProject.name = 'my-app'
include 'common', 'api', 'web'
```

**ルートの build.gradle（共通設定）**:

```groovy
// 全サブプロジェクトに適用
subprojects {
    apply plugin: 'java'

    java {
        sourceCompatibility = JavaVersion.VERSION_21
        targetCompatibility = JavaVersion.VERSION_21
    }

    repositories {
        mavenCentral()
    }

    dependencies {
        testImplementation 'org.junit.jupiter:junit-jupiter:5.9.3'
    }
}

// 特定のプロジェクトのみに適用
project(':api') {
    dependencies {
        implementation project(':common')
    }
}
```

**api/build.gradle（個別設定）**:

```groovy
dependencies {
    // 他のモジュールに依存
    implementation project(':common')

    // 外部ライブラリ
    implementation 'org.springframework.boot:spring-boot-starter-web:3.1.0'
}
```

**依存関係の解決順序**:

```
gradle :api:build を実行
         ↓
settings.gradle で 'common' と 'api' を認識
         ↓
api が common に依存していることを検出
         ↓
:common:build を先に実行
         ↓
common/build/libs/common.jar を生成
         ↓
:api:build を実行（common.jar をクラスパスに含む）
         ↓
api/build/libs/api.jar を生成
```

---

## 📊 依存関係の解決フロー

### 外部ライブラリのダウンロード

```
1. build.gradle の dependencies ブロックを読み込み
   implementation 'com.google.guava:guava:31.1-jre'
         ↓
2. repositories で指定されたリポジトリに接続
   mavenCentral() → https://repo.maven.apache.org/maven2/
         ↓
3. guava のPOMファイルをダウンロード
   guava-31.1-jre.pom を確認
         ↓
4. 推移的依存関係を解析
   guava が依存する他のライブラリを確認
         ↓
5. すべての依存ライブラリをダウンロード
   guava-31.1-jre.jar
   failureaccess-1.0.1.jar
   listenablefuture-9999.0.jar
   jsr305-3.0.2.jar
         ↓
6. ~/.gradle/caches/ にキャッシュ
   ~/.gradle/caches/modules-2/files-2.1/
   └── com.google.guava/
       └── guava/
           └── 31.1-jre/
               └── [hash]/
                   └── guava-31.1-jre.jar
         ↓
7. コンパイル時にクラスパスに追加
   javac -cp ~/.gradle/caches/.../guava-31.1-jre.jar:... Main.java
```

### 依存関係の競合解決

**例**: 2 つのライブラリが異なるバージョンの guava に依存している場合

```groovy
dependencies {
    implementation 'com.library.a:library-a:1.0'  // guava 30.0に依存
    implementation 'com.library.b:library-b:2.0'  // guava 31.1に依存
}
```

**Gradle の解決戦略**:

1. デフォルト: 最新バージョンを採用 (guava 31.1)
2. 強制指定も可能:

```groovy
configurations.all {
    resolutionStrategy {
        // 特定バージョンを強制
        force 'com.google.guava:guava:30.0'

        // バージョン競合でビルド失敗させる
        failOnVersionConflict()
    }
}
```

---

## 🎯 実践例

### 例 1: 外部ライブラリの追加

**ステップ 1: build.gradle に追加**:

```groovy
dependencies {
    implementation 'com.fasterxml.jackson.core:jackson-databind:2.15.2'
}
```

**ステップ 2: Gradle が自動実行する処理**:

```
gradle build を実行
         ↓
repositories (mavenCentral) に接続
         ↓
jackson-databind-2.15.2.jar をダウンロード
jackson-core-2.15.2.jar (推移的依存)
jackson-annotations-2.15.2.jar (推移的依存)
         ↓
~/.gradle/caches/ にキャッシュ
         ↓
コンパイル時にクラスパスに追加
```

**ステップ 3: Java コードで使用**:

```java
package com.example.app;

import com.fasterxml.jackson.databind.ObjectMapper;
import java.util.HashMap;
import java.util.Map;

public class Main {
    public static void main(String[] args) throws Exception {
        ObjectMapper mapper = new ObjectMapper();

        Map<String, Object> data = new HashMap<>();
        data.put("name", "John");
        data.put("age", 30);

        String json = mapper.writeValueAsString(data);
        System.out.println(json);  // {"name":"John","age":30}
    }
}
```

**ステップ 4: ビルドと実行**:

```bash
gradle build    # jackson-databind がクラスパスに含まれる
gradle run      # 正常に実行される
```

---

### 例 2: マルチモジュール構成の実装

**ステップ 1: ディレクトリ構造を作成**:

```bash
mkdir -p common/src/main/java/com/example/common
mkdir -p api/src/main/java/com/example/api
```

**ステップ 2: settings.gradle**:

```groovy
rootProject.name = 'my-app'
include 'common', 'api'
```

**ステップ 3: common/build.gradle**:

```groovy
plugins {
    id 'java-library'  // ライブラリプロジェクト用
}

dependencies {
    // 共通ライブラリの依存関係
    implementation 'com.google.guava:guava:31.1-jre'
}
```

**ステップ 4: common モジュールのコード**:

```java
// common/src/main/java/com/example/common/Utils.java
package com.example.common;

public class Utils {
    public static String formatMessage(String message) {
        return "[APP] " + message;
    }
}
```

**ステップ 5: api/build.gradle**:

```groovy
plugins {
    id 'java'
    id 'application'
}

dependencies {
    // common モジュールに依存
    implementation project(':common')
}

application {
    mainClass = 'com.example.api.Main'
}
```

**ステップ 6: api モジュールのコード**:

```java
// api/src/main/java/com/example/api/Main.java
package com.example.api;

import com.example.common.Utils;  // common モジュールのクラスを使用

public class Main {
    public static void main(String[] args) {
        String message = Utils.formatMessage("Hello from API");
        System.out.println(message);  // [APP] Hello from API
    }
}
```

**ステップ 7: ビルドと実行**:

```bash
# api をビルド（自動的に common もビルドされる）
gradle :api:build

# api を実行
gradle :api:run
```

**実行時の依存関係解決**:

```
gradle :api:run
         ↓
settings.gradle が common と api を認識
         ↓
api が project(':common') に依存していることを検出
         ↓
:common:compileJava を実行
common/build/classes/java/main/ に .class ファイルを生成
         ↓
:api:compileJava を実行
common のクラスをクラスパスに含める
         ↓
:api:run を実行
Utils.formatMessage() が使用可能
```

---

### 例 3: プロファイル別設定

**gradle.properties**:

```properties
# デフォルトは開発環境
profile=dev
```

**build.gradle**:

```groovy
// プロファイルに応じて設定を変更
ext {
    profile = project.hasProperty('profile') ? project.property('profile') : 'dev'

    // プロファイル別の設定
    config = [
        dev: [
            dbUrl: 'jdbc:h2:mem:testdb',
            logLevel: 'DEBUG'
        ],
        prod: [
            dbUrl: 'jdbc:postgresql://prod-server:5432/mydb',
            logLevel: 'INFO'
        ]
    ][profile]
}

// 設定を表示
task showConfig {
    doLast {
        println "Profile: ${profile}"
        println "DB URL: ${config.dbUrl}"
        println "Log Level: ${config.logLevel}"
    }
}

// リソースファイルを生成
task generateConfig {
    doLast {
        def configFile = file("$buildDir/resources/main/application.properties")
        configFile.parentFile.mkdirs()
        configFile.text = """
database.url=${config.dbUrl}
logging.level=${config.logLevel}
"""
    }
}

processResources.dependsOn generateConfig
```

**実行**:

```bash
# 開発環境でビルド
gradle build

# 本番環境でビルド
gradle build -Pprofile=prod

# 設定を確認
gradle showConfig
gradle showConfig -Pprofile=prod
```

---

## 🔍 デバッグコマンド

### プロジェクト構造の確認

```bash
# プロジェクト一覧を表示
gradle projects

# 出力例:
# Root project 'my-app'
# +--- Project ':common'
# \--- Project ':api'
```

### 依存関係の確認

```bash
# 全依存関係ツリーを表示
gradle dependencies

# 特定の設定の依存関係のみ
gradle dependencies --configuration runtimeClasspath
gradle dependencies --configuration compileClasspath

# 特定のライブラリの依存経路を調査
gradle dependencyInsight --dependency guava --configuration runtimeClasspath

# 出力例:
# com.google.guava:guava:31.1-jre
#    variant "compile" [
#       ...
#    ]
#    \--- com.library.a:library-a:1.0
#         \--- compileClasspath
```

### タスクの確認

```bash
# 実行可能なタスク一覧
gradle tasks

# 全タスク（内部タスク含む）
gradle tasks --all

# タスクの依存関係を表示（実際には実行しない）
gradle build --dry-run

# 出力例:
# :compileJava SKIPPED
# :processResources SKIPPED
# :classes SKIPPED
# :jar SKIPPED
# :assemble SKIPPED
# :compileTestJava SKIPPED
# :processTestResources SKIPPED
# :testClasses SKIPPED
# :test SKIPPED
# :check SKIPPED
# :build SKIPPED
```

### プロパティの確認

```bash
# プロジェクトプロパティを表示
gradle properties

# 出力例:
# name: java-docker-study
# version: 1.0-SNAPSHOT
# group: com.example
# ...
```

### ビルドの詳細ログ

```bash
# 詳細ログを表示
gradle build --info

# デバッグログを表示
gradle build --debug

# スタックトレースを表示
gradle build --stacktrace

# ビルドスキャン（オンライン分析）
gradle build --scan
```

### キャッシュのクリア

```bash
# プロジェクトのビルド成果物を削除
gradle clean

# Gradleキャッシュをクリア
rm -rf ~/.gradle/caches/

# 依存関係を強制再ダウンロード
gradle build --refresh-dependencies
```

---

## 📋 まとめ

### ファイルの読み込み順序と役割

| 順序 | ファイル                    | 役割                  | スコープ     |
| ---- | --------------------------- | --------------------- | ------------ |
| 1    | `gradlew`                   | Wrapper スクリプト    | 実行         |
| 2    | `gradle-wrapper.properties` | Gradle バージョン指定 | Wrapper      |
| 3    | `settings.gradle`           | プロジェクト構造定義  | ルート       |
| 4    | `gradle.properties`         | グローバル設定        | 全体         |
| 5    | `build.gradle`              | ビルド定義            | モジュール毎 |
| 6    | `src/`                      | ソースコード          | -            |

### データの流れ

```
gradle-wrapper.properties
         ↓
   (Gradleダウンロード)
         ↓
settings.gradle → プロジェクト構造決定
         ↓
gradle.properties → グローバル設定
         ↓
build.gradle → プラグイン適用
         ↓
build.gradle → リポジトリ接続
         ↓
build.gradle → 依存関係ダウンロード
         ↓
src/ → コンパイル
         ↓
build/ → 成果物生成
```

### 重要な概念

1. **Gradle Wrapper**: チーム全員が同じ Gradle バージョンを使用
2. **マルチプロジェクト**: 複数モジュールを 1 つのビルドで管理
3. **推移的依存**: ライブラリが依存する他のライブラリも自動ダウンロード
4. **キャッシュ**: `~/.gradle/caches/` で依存関係を再利用
5. **タスクグラフ**: タスクの依存関係を解析して最適な順序で実行

---

## 🚀 次のステップ

1. **実際にマルチプロジェクト構成を試す**

   ```bash
   mkdir -p common/src/main/java api/src/main/java
   # settings.gradle と各 build.gradle を作成
   ```

2. **外部ライブラリを追加してみる**

   ```groovy
   dependencies {
       implementation 'com.google.code.gson:gson:2.10.1'
   }
   ```

3. **カスタムタスクを作成する**

   ```groovy
   task hello {
       doLast {
           println 'Hello, Gradle!'
       }
   }
   ```

4. **ビルドスキャンで最適化する**
   ```bash
   gradle build --scan
   ```
