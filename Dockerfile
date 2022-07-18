FROM nginx:1.22
COPY public /usr/share/nginx/html
EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]