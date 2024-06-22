#!/bin/sh
set -e

: "${PACKAGER_PRIVKEY:=$PWD/../.abuild/privkey.rsa}"

: "${APORTS_DIR:=$PWD}"
: "${PACKAGES_DIR:=$PWD/../packages}"

die() {
    echo >&2 "Error: $1"
    exit 1
}

echo "ALPINE_VERSION=$ALPINE_VERSION"
echo "PACKAGER_PRIVKEY=$PACKAGER_PRIVKEY"
echo "APORTS_DIR=$APORTS_DIR"
echo "PACKAGES_DIR=$PACKAGES_DIR"

[ -n "$ALPINE_VERSION" ] || die "ALPINE_VERSION not set"

[ -f "$PACKAGER_PRIVKEY" ] || die "PACKAGER_PRIVKEY not found"
[ -f "$PACKAGER_PRIVKEY.pub" ] || die "PACKAGER_PRIVKEY.pub not found"

[ -d "$APORTS_DIR" ] || die "APORTS_DIR not found"
[ -d "$PACKAGES_DIR" ] || die "PACKAGES_DIR not found"

[ ! -d "$PACKAGES_DIR/$ALPINE_VERSION" ] && mkdir "$PACKAGES_DIR/$ALPINE_VERSION"

packager_privkey_basename=$(basename "$PACKAGER_PRIVKEY")

script_dir=$(dirname "$0")

docker build \
    -t aports-builder \
    --build-arg="ALPINE_VERSION=$ALPINE_VERSION" \
    --build-arg="ABUILD_UID=$(id -u)" \
    --build-arg="PACKAGER_PRIVKEY_BASENAME=$packager_privkey_basename" \
    -f "$script_dir/github-build.Dockerfile" \
    "$script_dir"

for repo in $*; do
    echo "Building packages in: $repo"

    docker run \
        --rm \
        --privileged \
        --volume "$PACKAGER_PRIVKEY:/abuild/.abuild/$packager_privkey_basename" \
        --volume "$PACKAGER_PRIVKEY.pub:/abuild/.abuild/$packager_privkey_basename.pub" \
        --volume "$PACKAGER_PRIVKEY.pub:/etc/apk/keys/$packager_privkey_basename.pub" \
        --volume "$APORTS_DIR:/abuild/aports" \
        --volume "$PACKAGES_DIR/$ALPINE_VERSION:/abuild/packages" \
        aports-builder buildrepo \
            -a /abuild/aports \
            -d /abuild/packages \
            -p -R $repo
done
