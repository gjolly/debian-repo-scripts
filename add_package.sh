#!/bin/bash -eu

archive_root=${1}
pkg_path=${2}
release=${3}
component=${4:-main}

tmp_info='/tmp/pkg-info'
tmp_pkg_index='/tmp/pkg-index'

function clean {
  rm -f "$tmp_info" "$tmp_pkg_index"
}

trap clean EXIT

dpkg-deb -I "$pkg_path" control > "$tmp_info"

# Update info

md5=$(md5sum "$pkg_path" | cut -d' ' -f1)
sha256=$(sha256sum "$pkg_path" | cut -d' ' -f1)
sha1=$(sha1sum "$pkg_path" | cut -d' ' -f1)
sha512=$(sha512sum "$pkg_path" | cut -d' ' -f1)
descriptionMd5=$(dpkg-deb -f "$pkg_path" description | md5sum | cut -d' ' -f1)
size=$(stat --printf=%s "$pkg_path")

pkg_name="$(basename $pkg_path)"

echo "MD5sum: $md5" >> "$tmp_info"
echo "SHA1: $sha1" >> "$tmp_info"
echo "SHA256: $sha256" >> "$tmp_info"
echo "SHA512: $sha512" >> "$tmp_info"
echo "SHA512: $sha512" >> "$tmp_info"
echo "Description-md5: $descriptionMd5" >> "$tmp_info"
echo "Size: $size" >> "$tmp_info"
echo "Filename: pool/$component/$pkg_name" >> "$tmp_info"

mkdir -p "$archive_root/pool/$component"
mv "$pkg_path" "$archive_root/pool/$component"

# update package index

arch=$(awk -F ': ' '{ if ($1 == "Architecture") { print $2 } }' $tmp_info)

mkdir -p "$archive_root/dists/$release/$component/binary-$arch"
packages_index="$archive_root/dists/$release/$component/binary-$arch/Packages.gz"
if [ -e "$packages_index" ]; then
  gzip -cd "$packages_index" > "$tmp_pkg_index"
  echo ""  >> "$tmp_pkg_index"
fi

cat "$tmp_info" >> "$tmp_pkg_index"
gzip -c "$tmp_pkg_index" > "$packages_index"

# update release index
./update_pocket_index.sh "$archive_root/dists/$release/"
