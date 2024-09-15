FROM nginx:1.23
COPY public /usr/share/nginx/html
EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]