#!/bin/bash
set -e

# Gradle Wrapperが存在しない場合は生成
if [ ! -f /workspace/gradlew ]; then
    echo "🔧 Generating Gradle Wrapper (version: ${GRADLE_VERSION})..."
    cd /workspace
    gradle wrapper --gradle-version ${GRADLE_VERSION}
fi

# gradlewに実行権限を付与
if [ -f /workspace/gradlew ]; then
    chmod +x /workspace/gradlew
fi

# 渡されたコマンドを実行
exec "$@"
