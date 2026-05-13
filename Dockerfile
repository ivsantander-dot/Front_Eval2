# ── ETAPA 1: Builder ───────────────────────────────────────────
FROM node:18-alpine AS builder

WORKDIR /app

COPY package*.json ./
RUN npm ci

COPY . .

# Variable de entorno para la URL del backend
ARG VITE_API_URL=http://localhost:3000
ENV VITE_API_URL=$VITE_API_URL

# Compilar la aplicación (genera la carpeta dist/)
RUN npm run build

# ── ETAPA 2: Runner con Nginx ──────────────────────────────────
FROM nginx:alpine AS runner

# Eliminar configuración por defecto de Nginx
RUN rm -rf /usr/share/nginx/html/*

# Copiar los archivos estáticos compilados
COPY --from=builder /app/dist /usr/share/nginx/html

# Configuración personalizada de Nginx (proxy al backend)
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
