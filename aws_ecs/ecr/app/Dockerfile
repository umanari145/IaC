# PHP-FPMのイメージをベースにする
FROM php:7.4-fpm

# 作業ディレクトリを設定
WORKDIR /var/www/html

COPY ./src/ /var/www/html/

# 必要なPHPの拡張機能をインストール
RUN docker-php-ext-install pdo_mysql mysqli

# www-dataユーザーのUIDとGIDをホストシステムと合わせる（必要に応じて変更）
ARG UID=1000
ARG GID=1000
RUN usermod -u ${UID} www-data && groupmod -g ${GID} www-data

# ホストからコンテナ内の作業ディレクトリへファイルをコピー
# この行は、あなたのプロジェクトに応じてコメントアウトまたは修正が必要です
# COPY . /var/www/html

# PHP-FPMを起動
CMD ["php-fpm"]

# ポート9000でリッスン
EXPOSE 9000
