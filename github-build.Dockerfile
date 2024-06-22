ARG ALPINE_VERSION

FROM alpine:$ALPINE_VERSION

ARG ALPINE_VERSION
ARG ABUILD_UID
ARG PACKAGER_PRIVKEY_BASENAME

RUN env && apk add \
        alpine-sdk \
        abuild-rootbld \
        lua-aports \
    && adduser -u $ABUILD_UID -G abuild -D -h /abuild abuild

USER $ABUILD_UID

RUN mkdir -m 0700 /abuild/.abuild \
    && echo "PACKAGER_PRIVKEY=\"/abuild/.abuild/$PACKAGER_PRIVKEY_BASENAME\"" > /abuild/.abuild/abuild.conf
