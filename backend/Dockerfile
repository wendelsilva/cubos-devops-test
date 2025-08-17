FROM node:lts-bookworm

WORKDIR /server

COPY index.js package.json .env  /server/

RUN npm install

EXPOSE 5000

ENTRYPOINT [ "node", "--env-file=.env", "index.js"  ]