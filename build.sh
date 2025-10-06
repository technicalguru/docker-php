docker buildx build --progress=plain --push \
    -t technicalguru/php:v8.3.26-apache-2.4.65.0 \
    --platform linux/arm64,linux/amd64 \
    .

#docker build --progress=plain --no-cache -t technicalguru/php:latest .
