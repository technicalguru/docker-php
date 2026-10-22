docker buildx build \
     --progress=plain \
     -t technicalguru/php:latest \
     -t technicalguru/php:v8.4.27-apache-2.4.68.0 \
     -t technicalguru/php:v8.4-apache-2.4.68.0 \
     -t technicalguru/php:v8-apache-2.4.68.0 \
     -t technicalguru/php:v8.4.27 \
     -t technicalguru/php:v8.4 \
     -t technicalguru/php:v8 \
     --push \
     --platform linux/amd64,linux/arm64 \
     .
#docker build --progress=plain --no-cache -t technicalguru/php:latest .
