FROM openjdk:26-ea-trixie

# 開発ツールのインストール
RUN apt-get update && \
    apt-get install -y vim nano git && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /workspace

# デフォルトでbashを起動
CMD ["/bin/bash"]