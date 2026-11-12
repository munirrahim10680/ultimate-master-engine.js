# syntax = docker/dockerfile:1

ARG NODE_VERSION=22.21.1
FROM node:${NODE_VERSION}-slim AS base

LABEL fly_launch_runtime="Node.js"

# Install Playwright system dependencies
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
    build-essential node-gyp pkg-config python3 \
    libnss3 libatk1.0-0 libatk-bridge2.0-0 libcups2 libdrm2 \
    libxkbcommon0 libxcomposite1 libxdamage1 libxfixes3 libxrandr2 \
    libgbm1 libasound2 libpango-1.0-0 libcairo2 libcups2 \
    libx11-xcb1 libxcb-dri3-0 libxshmfence1 libglib2.0-0 libnspr4 \
    libdbus-1-3 libexpat1 libfontconfig1 libgcc1 libstdc++6

WORKDIR /app
ENV NODE_ENV="production"

FROM base AS build

RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y build-essential node-gyp pkg-config python3

COPY package.json ./
RUN npm install

# Explicitly install Playwright chromium browser during build
RUN npx playwright install chromium

COPY . .

FROM base

COPY --from=build /app /app

EXPOSE 8080

CMD [ "npm", "start" ]
