FROM node:lts-bookworm

WORKDIR /server

COPY index.js package.json .env  /server/

RUN npm install

EXPOSE 5000

CMD ["sh", "-c", "mkdir -p /server/logs && node --env-file=.env index.js > /server/logs/backend.log 2>&1"]