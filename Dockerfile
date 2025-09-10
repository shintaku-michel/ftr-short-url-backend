FROM node:22.16 AS base

FROM base AS dependencies

WORKDIR /usr/src/app

COPY package.json ./

RUN npm install

FROM base AS build

WORKDIR /usr/src/app

COPY . .
COPY --from=dependencies /usr/src/app/node_modules ./node_modules

RUN npm run build
RUN npm prune --production

#IMAGE HUB DOCKER - https://hub.docker.com/
#FROM node:22.16-alpine3.21 AS deploy

#IMAGE CHAINGUARD
# https://images.chainguard.dev/directory/image/node/versions
# FROM cgr.dev/chainguard/node AS deploy

#IMAGE GOOGLE CONTAINER TOOLS
#https://github.com/GoogleContainerTools/distroless/tree/main/nodejs
FROM gcr.io/distroless/nodejs22-debian12 AS deploy

#USUÁRIO NÃO ROOT (RECOMENDADO)
USER 1000

WORKDIR /usr/src/app

COPY --from=build /usr/src/app/dist ./dist
COPY --from=build /usr/src/app/node_modules ./node_modules
COPY --from=build /usr/src/app/package.json ./package.json

EXPOSE 3000

CMD ["dist/server.mjs"]