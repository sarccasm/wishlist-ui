FROM node:22-alpine AS build

WORKDIR /app

COPY package.json package-lock.json ./
RUN npm ci

COPY . .
RUN npm run build

FROM nginx:1.27-alpine AS runtime

ENV PORT=10000 \
    NGINX_ENVSUBST_FILTER=^PORT$

COPY nginx.conf /etc/nginx/templates/default.conf.template
COPY --from=build /app/dist/ /usr/share/nginx/html/
COPY runtime-config.js.template /usr/share/nginx/html/runtime-config.js.template

EXPOSE 10000
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD sh -c 'wget --quiet --tries=1 --spider "http://127.0.0.1:${PORT}/health" || exit 1'

CMD ["sh", "-c", "envsubst '${VITE_API_BASE}' < /usr/share/nginx/html/runtime-config.js.template > /usr/share/nginx/html/runtime-config.js && exec /docker-entrypoint.sh nginx -g 'daemon off;'"]
