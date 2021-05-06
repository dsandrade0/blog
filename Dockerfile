FROM node:16

COPY ./ site/

WORKDIR site/

CMD npm install hexo

ENTRYPOINT ["npx", "hexo", "server -p 80"]