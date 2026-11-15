ARG ALPINE_VERSION

FROM alpine:$ALPINE_VERSION

ARG ABUILD_GID
ARG ABUILD_UID
ARG ALPINE_VERSION
ARG SIGNING_KEY_NAME

RUN apk add abuild-rootbld alpine-sdk lua-aports \
	&& addgroup -g $ABUILD_GID abuild-user \
	&& adduser -u $ABUILD_UID -G abuild-user -D -h /abuild abuild-user \
	&& adduser abuild-user abuild \
	&& ln -s /run/secrets/signing_key.rsa.pub /etc/apk/keys/$SIGNING_KEY_NAME.rsa.pub \
	&& { [ "$ALPINE_VERSION" = edge ] || ALPINE_VERSION="v$ALPINE_VERSION"; } \
	&& cat > /docker-entrypoint.sh <<-EOF \
	&& chmod +x /docker-entrypoint.sh
		#!/bin/sh
		export version=$ALPINE_VERSION
		exec buildrepo -a /abuild/aports -d /abuild/packages/\$version -p -R "\$@"
	EOF

USER abuild-user

RUN mkdir -m 0700 /abuild/.abuild \
	&& ln -s /run/secrets/signing_key.rsa /abuild/.abuild/$SIGNING_KEY_NAME.rsa \
	&& ln -s /run/secrets/signing_key.rsa.pub /abuild/.abuild/$SIGNING_KEY_NAME.rsa.pub \
	&& echo "PACKAGER_PRIVKEY=/abuild/.abuild/$SIGNING_KEY_NAME.rsa" > /abuild/.abuild/abuild.conf

ENTRYPOINT [ "/docker-entrypoint.sh" ]
