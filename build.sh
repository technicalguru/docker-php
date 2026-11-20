docker buildx build \
     --progress=plain \
     -t technicalguru/php:latest \
     -t technicalguru/php:v8.5.13-apache-2.4.71.0 \
     -t technicalguru/php:v8.5-apache-2.4.71.0 \
     -t technicalguru/php:v8-apache-2.4.71.0 \
     -t technicalguru/php:v8.5.13 \
     -t technicalguru/php:v8.5 \
     -t technicalguru/php:v8 \
     --push \
     --platform linux/amd64,linux/arm64 \
     .
#docker build --progress=plain --no-cache -t technicalguru/php:latest .
