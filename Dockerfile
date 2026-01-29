# FlutterとNode.js(Firebase用)が同居する環境
FROM instrumentisto/flutter:latest

# Node.js (Volta) のインストール
RUN curl https://get.volta.sh | bash
ENV VOLTA_HOME="/root/.volta"
ENV PATH="$VOLTA_HOME/bin:$PATH"

# 必要ツールのインストール
RUN volta install node@latest firebase-tools
RUN flutter pub global activate fvm

# 作業ディレクトリ
WORKDIR /app