FROM eclipse-temurin:21-jdk

# 開発ツールとGradleのインストール
RUN apt-get update && \
    apt-get install -y vim nano git wget unzip && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Gradleのインストール（Java 21対応）
ENV GRADLE_VERSION=8.11.1
RUN wget https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip -P /tmp && \
    unzip -d /opt/gradle /tmp/gradle-${GRADLE_VERSION}-bin.zip && \
    ln -s /opt/gradle/gradle-${GRADLE_VERSION}/bin/gradle /usr/bin/gradle && \
    rm /tmp/gradle-${GRADLE_VERSION}-bin.zip

WORKDIR /workspace

COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["/bin/bash"]