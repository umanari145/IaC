FROM nginx:alpine
RUN mkdir -p /var/www/html
COPY ./src/ /var/www/html/
COPY ./nginx/prod/default.conf /etc/nginx/conf.d/default.conf
# ポート80を公開
EXPOSE 80