# debian archive tools

Set of script to manage a debian archive.

## usage

Initialize the repo:
```
mkdir -p $ROOT_PATH/dists/jammy

cat << EOF > /tmp/jammy-header
Origin: Ubuntu
Label: Ubuntu
Suite: jammy
Version: 22.04
Codename: jammy
Date:
Architectures: amd64 arm64 armhf i386 ppc64el riscv64 s390x
Components: main restricted universe multiverse
Description: Ubuntu Jammy 22.04
EOF

gpg --sign --clear -a --output $ROOT_PATH/dists/jammy/InRelease /tmp/jammy-header
```

Then to add a new package to your archive:

```
./add_package.sh $ROOT_PATH $PACKAGE.deb jammy
```

To serve it for testing, you can use python:

```
python3 -m http.server
```
