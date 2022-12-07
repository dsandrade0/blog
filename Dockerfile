FROM nginx:1.23.2
COPY public /usr/share/nginx/html
EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]