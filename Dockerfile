# Build stage
FROM node:lts-alpine as build

RUN apk update; \
  apk add git;apk add vim;apk add curl;
WORKDIR /tmp
RUN apk add python make g++ --no-cache
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build



# Release stage
FROM node:lts-alpine as release

RUN apk update; \
  apk add git;apk add vim;apk add curl;

WORKDIR /parse-server

COPY package*.json ./
RUN npm ci --production

COPY bin bin
COPY public_html public_html
COPY views views
COPY --from=build /tmp/lib lib
RUN mkdir -p logs && chown -R node: logs

ENV PORT=1337
USER node
EXPOSE $PORT


ENTRYPOINT ["node", "./bin/parse-server", "conf/parse-config.json"]
