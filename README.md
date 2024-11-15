# Multi-arch
```
docker buildx build -f Dockerfile.8.3.8-apache-bookworm . --progress plain --platform=linux/arm64 -t sigmapix/php:8.3.8-apache-bookworm-arm64 --push
docker buildx build -f Dockerfile.8.3.8-apache-bookworm . --progress plain --platform=linux/amd64 -t sigmapix/php:8.3.8-apache-bookworm-amd64 --push
docker manifest create sigmapix/php:8.3.8-apache-bookworm sigmapix/php:8.3.8-apache-bookworm-arm64 sigmapix/php:8.3.8-apache-bookworm-amd64
docker manifest push sigmapix/php:8.3.8-apache-bookworm
```