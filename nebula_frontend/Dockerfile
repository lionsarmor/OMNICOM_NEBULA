FROM ghcr.io/cirruslabs/flutter:stable AS build

WORKDIR /app

COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get

COPY . .

ARG BACKEND_URL=http://localhost:4400
ARG API_BASE_URL=http://localhost:4400/api
ARG BACKEND_WS_BASE=http://localhost:4400

RUN flutter build web --release \
  --dart-define=BACKEND_URL=${BACKEND_URL} \
  --dart-define=API_BASE_URL=${API_BASE_URL} \
  --dart-define=BACKEND_WS_BASE=${BACKEND_WS_BASE}

FROM nginx:1.27-alpine

COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=build /app/build/web /usr/share/nginx/html

EXPOSE 80
