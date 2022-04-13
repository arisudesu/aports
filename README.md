# Setup

```
# apk add abuild git
# adduser -D -h /var/abuild abuilduser
# addgroup abuilduser abuild
# su abuilduser -c 'abuild-keygen -a -n'
# su abuilduser -c 'cd ~ && git clone https://github.com/arisudesu/apkbuilds.git apkbuilds'
```

Building a package:
```
# su abuilduser -c 'cd ~/apkbuilds/custom/linux-lts && abuild -r'
```

Then copy key from `/var/abuild/abuild` to `/etc/apk/keys`.  
Next add `/var/abuild/packages/custom` to `/etc/apk/repositories`.
