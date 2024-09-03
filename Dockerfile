FROM nginx
COPY builder/public /usr/share/nginx/html
EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]