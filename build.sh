docker buildx build --progress=plain --push \
    -t technicalguru/php:8.3.36-apache-2.4.68.0 \
    -t technicalguru/php:8.3-apache-2.4.68.0 \
    -t technicalguru/php:8-apache-2.4.68.0 \
    -t technicalguru/php:8.3.36 \
    -t technicalguru/php:8.3 \
    -t technicalguru/php:8 \
    --platform linux/arm64,linux/amd64 \
    .

#docker build --progress=plain --no-cache -t technicalguru/php:latest .
