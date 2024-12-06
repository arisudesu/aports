aports
======

My aports for Alpine Linux.

Usage
-----

Add to /etc/apk/world:

	https://github.com/arisudesu/aports/raw/packages/3.20/arisu

Add signing key:

	doas tee >/dev/null <<-EOF /etc/apk/keys/arisudesu@users.noreply.github.com-66758c7b.rsa.pub
		-----BEGIN PUBLIC KEY-----
		MIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEA10YXPjiiKQbY7smkeNNA
		Qrw8C+4WCHlZvmXdEQO7DQGGYDl1JREf991UAID+T/Fpkc8wrre3x2WdjnEcJbnw
		v4U1wpWqrLlSrvZVWI7aX8S3cmHmgjHcLd5dS7TX6yEqn+vCHS48zXGL0gqvkY4T
		fRWjASmG9Dj7pu7XNKHOlqSzIWZnDagv2UHDExRq5GwoZESlaakA6ry14hHN05Wn
		6jexGsONvFwOpHMniGvXlQHPMP2IJWvRNBwf3DCGw0uXq6Hwy2wsHE7Gtl6cPxOY
		ye3znl33v3x6sEMouu+fanUh6Z9wFrLxaNGjSMBZCGDoHg5u1+fE2ThyZVA0Gz6q
		VpmYVzaW9yg+O0KQNiR2cHP0FRrOnqDWUB8Q3f5VCoQs4hbZF8ecDWgMmfFxl9Fd
		TqosXPSh6jP5gx7aA2TGsYqo2zgD99qw7RgMx07psGOuKrrCEIjKKUXVjvWfCho8
		rL3GKxE/1D9t+Xx9IKhE/h1lXjb6We99kfRz/5gKqu4lrQ8kqErWEJ1dGX+qYPLM
		aCYSqS6n3gJmYtuznnjfGhSjbsvGsueZ6MFBVwLqPcy+Q4iCpsNjM+AnYmww0A2H
		6qqKSsL30QGNDftP3ldjhWr3IlZKhMmNrrshJ5N/J+7M2H9ronTH1Zd/ECBRG/4e
		BBdD83IBzOXL/SeX+rwh6HkCAwEAAQ==
		-----END PUBLIC KEY-----
	EOF

Run `apk update` afterwards.

Building repo locally
---------------------

	mkdir ../packages
	ALPINE_VERSION=3.20 PACKAGER_PRIVKEY=~/.abuild/arisudesu@users.noreply.github.com-66758c7b.rsa ./github-build.sh arisu

Note on derivatives from official packages
------------------------------------------

In this repo, some packages have the same names as the official ones, but they are built differently. These are the packages
for which I prefer those changes to be packaged, rather than applied manually or somehow else on the system. Examples of such
changes are [additional args for lxcfs process](./arisu/lxcfs/lxcfs.initd#L119), [ability to shutdown guests via guest-agent
in qemu-openrc](./arisu/qemu-openrc/add-guest-agent-socket.patch) &dash; I really don't want to edit init scripts and fix them
every time these official packages are updated; I rather copy the package and maintain my own modified variants, applying
upstream changes to them periodically.

For this derived packages to replace official ones, I set their `$pkgrel` higher than official. Also, starting with Alpine 3.21,
I will add 10 to `$pkgrel` in my packages initially, as a safety margin, to have some time to borrow upstream changes, before
official packages catch up with `$pkgrel` and replace my modified versions.
