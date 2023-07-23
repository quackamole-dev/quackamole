# STAGE 1: Build frontend
FROM node:20.4.0-slim as build
WORKDIR /usr/src/app
COPY ./quackamole-rtc-gui/package*.json ./
COPY ./quackamole-rtc-gui ./

# Workaround to be able to set vite env vars via args in the compose file for now...
ARG VITE_BACKEND_API_URL
ARG VITE_BACKEND_WS_URL
ARG VITE_BACKEND_SECURE

ENV VITE_BACKEND_API_URL=$VITE_BACKEND_API_URL \
    VITE_BACKEND_WS_URL=$VITE_BACKEND_WS_URL \
    VITE_BACKEND_SECURE=$VITE_BACKEND_SECURE
    
RUN echo "VITE_BACKEND_API_URL is set to $VITE_BACKEND_API_URL"
RUN echo "VITE_BACKEND_API_URL is set to $VITE_BACKEND_WS_URL"
RUN echo "VITE_BACKEND_SECURE is set to $VITE_BACKEND_SECURE"

RUN npm install && npm run build

# STAGE 2: Setup nginx and copy frontend build files
FROM nginx:1.25.1-alpine
RUN apk add --no-cache openssl nano && \
    openssl dhparam -out /etc/nginx/dhparam.pem 1024 && \
    apk del openssl && \
    rm -rf /usr/share/nginx/html/*
# COPY ./nginx/default.conf /etc/nginx/conf.d/default.conf
COPY --from=build /usr/src/app/dist /usr/share/nginx/html
# Regarding usage of ENTRYPOINT with nginx dockerhub image: https://github.com/nginxinc/docker-nginx/issues/422
CMD ["nginx", "-g", "daemon off;"]
