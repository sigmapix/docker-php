#!/bin/bash -e

# extract all versions of PHP from local files named Dockerfile.VERSION-*
# example: Dockerfile.7.1.30-apache-stretch -> 7.1.30 / Dockerfile.8.3.12-frankenphp.1.2.5-bookworm -> 8.3.12
versions=$(ls Dockerfile.* | grep -oP 'Dockerfile.\K[0-9]+\.[0-9]+\.[0-9]+')
# sort the versions in descending order
IFS=$'\n' versions=($(sort -rV <<<"${versions[*]}"))

read -p "❓ Enter the version of PHP (e.g. 7.4.0 or empty to list available versions): " VERSION

# if the version is empty, set the default version to latest
if [ -z "$VERSION" ]; then
    # list all versions of PHP, and let the user choose one with a select, default is the latest version
    PS3="❓ Select a version of PHP (or 'd': default ${versions[0]} / 'h': help / 'l': list / 'q': quit): "
    select VERSION in "${versions[@]}"; do
        if [ "$REPLY" == "q" ]; then
            echo "👋 Exiting"
            exit 0
        elif [ "$REPLY" == "l" ]; then
            echo "📜 Available versions:"
            for version in "${versions[@]}"; do
                echo "  - $version"
            done
        elif [ "$REPLY" == "h" ]; then
            echo "ℹ️  Help:"
            echo "  - q: quit"
            echo "  - l: list available versions"
            echo "  - h: help"
            echo "  - d: default version"
        elif [ "$REPLY" == "d" ]; then
            VERSION=${versions[0]}
            break
        elif [ -n "$REPLY" ] && [ "$REPLY" -ge 1 ] && [ "$REPLY" -le "${#versions[@]}" ]; then
            # if the user input is not empty, but user input is not between 1 and the number of elements in the array, exit the script
            break
        # else if user just typed enter, set the version to the first element in the array
        elif [ -z "$REPLY" ]; then
            VERSION=${versions[0]}
            break
        else
            echo "❌ Invalid option: $REPLY"
        fi
    done
else
    # check if the version is in the list of available versions
    if [[ ! " ${versions[@]} " =~ " ${VERSION} " ]]; then
        echo "❌ Invalid version of PHP: ${VERSION}"
        exit 1
    fi
fi

echo "🔨 Building PHP version: ${VERSION}"

# ask for confirmation [Y/n]
read -p "❓ Do you want to continue? [Y/n]: " confirm
# if user input (case insensitive) is not 'y', empty, or 'yes' exit the script
if [[ ! $confirm =~ ^[Yy]$|^$|^yes$ ]]; then
    echo "👋 Exiting"
    exit 0
fi

# build the image with the specified version of PHP
docker buildx build -f Dockerfile.${VERSION}-apache-bookworm . --progress plain --platform=linux/amd64 -t sigmapix/php:${VERSION}-apache-bookworm-amd64 --push
docker buildx build -f Dockerfile.${VERSION}-apache-bookworm . --progress plain --platform=linux/arm64 -t sigmapix/php:${VERSION}-apache-bookworm-arm64 --push
docker manifest create sigmapix/php:${VERSION}-apache-bookworm sigmapix/php:${VERSION}-apache-bookworm-arm64 sigmapix/php:${VERSION}-apache-bookworm-amd64
docker manifest push sigmapix/php:${VERSION}-apache-bookworm

echo "🎉 Build completed successfully! 🎉"
exit 0