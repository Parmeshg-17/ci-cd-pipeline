# ── Stage 1: Build (optional – nothing to compile for a static site, but
#    included so you can plug in a bundler like Vite/Parcel later)
FROM node:20-alpine AS builder

WORKDIR /app

# Copy site source
COPY index.html .

# ── Stage 2: Serve with nginx (lightweight, production-ready)
FROM nginx:1.27-alpine

# Remove default nginx welcome page
RUN rm -rf /usr/share/nginx/html/*

# Copy the static site from the build stage
COPY --from=builder /app/index.html /usr/share/nginx/html/index.html

# Optional: custom nginx config for clean URLs, gzip, and caching headers
RUN printf 'server {\n\
    listen 80;\n\
    server_name _;\n\
    root /usr/share/nginx/html;\n\
    index index.html;\n\
\n\
    # Gzip compression\n\
    gzip on;\n\
    # text/html is already included by default; avoid duplicate MIME warnings\n\
    gzip_types text/css application/javascript image/svg+xml;\n\
    gzip_min_length 1024;\n\
\n\
    # Cache static assets for 1 year\n\
    location ~* \\.(css|js|svg|woff2?)$ {\n\
        add_header Cache-Control "public, max-age=31536000, immutable";\n\
    }\n\
\n\
    # HTML: no cache so deploys are instant\n\
    location / {\n\
        add_header Cache-Control "no-cache";\n\
        try_files $uri $uri/ /index.html;\n\
    }\n\
}\n' > /etc/nginx/conf.d/default.conf

# Expose HTTP port
EXPOSE 80

# nginx runs in the foreground (required for Docker)
CMD ["nginx", "-g", "daemon off;"]
