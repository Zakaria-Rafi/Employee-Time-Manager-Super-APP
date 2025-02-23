FROM node:lts-alpine AS dist

WORKDIR /usr/share/app

RUN apk add --no-cache bash git curl ca-certificates g++ make gcc

COPY package*.json .

RUN npm install --loglevel silly

COPY . .

RUN npm run build

FROM nginx:alpine AS prod

COPY --from=dist /usr/share/app/dist /usr/share/nginx/html
COPY --from=dist /usr/share/app/nginx.conf /etc/nginx/conf.d/default.conf