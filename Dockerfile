FROM nginx:1.21.6
COPY public /usr/share/nginx/html
EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]