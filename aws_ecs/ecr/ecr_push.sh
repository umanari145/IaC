#!/bin/bash

# ECRリポジトリ名の設定
NGINX_REPO_NAME="nginx-repository"
PHP_FPM_REPO_NAME="php-fpm-repository"

# AWSアカウントIDとデフォルトリージョンの取得
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query "Account" --output text)
AWS_DEFAULT_REGION=$(aws configure get region)

# Dockerイメージのタグ名
NGINX_IMAGE_TAG="latest"
PHP_FPM_IMAGE_TAG="latest"

# DockerイメージのビルドとECRへのプッシュ
build_and_push_image() {
    local repo_name=$1
    local image_tag=$2

    # ECRリポジトリURIの設定
    local ecr_uri="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/${repo_name}"

    # nginx側　Dockerイメージのビルド docker-compose や　docker compose build --no-cacheで代替
    # なぜかスクリプトで動かないので手動で
    # docker build -t "${repo_name}:latest"　-f "${docker_file_dir}" .
    # ECRへのログイン
    aws ecr get-login-password | docker login --username AWS --password-stdin "${ecr_uri}"

    # Dockerイメージのタグ付け
    docker tag "${repo_name}:${image_tag}" "${ecr_uri}:${image_tag}"

    # ECRへのプッシュ
    docker push "${ecr_uri}:${image_tag}"
}

# NGINX DockerイメージのビルドとECRへのプッシュ
# 第3引数にはNginxのDockerfileがあるディレクトリへのパスを指定してください
build_and_push_image "${NGINX_REPO_NAME}" "${NGINX_IMAGE_TAG}"

# PHP-FPM DockerイメージのビルドとECRへのプッシュ
# 第3引数にはPHP-FPMのDockerfileがあるディレクトリへのパスを指定してください
#build_and_push_image "${PHP_FPM_REPO_NAME}" "${PHP_FPM_IMAGE_TAG}"