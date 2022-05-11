# Setup

Initial setup:
```
# apk add abuild git
# adduser -D -h /var/abuild abuilduser
# addgroup abuilduser abuild
# su abuilduser -c 'abuild-keygen -a -n'
```

Init repo:
```
# su abuilduser -c 'git clone https://github.com/arisudesu/aports.git ~/aports'
```

Update repo:
```
# su abuilduser -c 'cd ~/aports && git fetch --all && git checkout -f origin/master'
```

Building a package:
```
# su abuilduser -c 'cd ~/aports/custom/<package> && abuild -r && abuild cleanoldpkg'
```

Then copy key from `/var/abuild/abuild` to `/etc/apk/keys`.  
Next add `/var/abuild/packages/custom` to `/etc/apk/repositories`.
