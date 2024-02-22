FROM nginx:alpine
COPY nginx.conf    /etc/nginx/
COPY build         /usr/share/nginx/html/

EXPOSE 7010
