#!/bin/bash -eu

release_root=${1}

release_index="$release_root/InRelease"
temp_release="/tmp/tmp-release"
new_release="/tmp/tmp-new-release"

generate_index_line="$(readlink -f ./tools/generate_index_line.sh)"

function clean {
  rm -f "$temp_release" "$new_release"
}

trap clean EXIT

gpg --output "$temp_release" "$release_index" 2> /dev/null

now="$(date -u +'%a, %d %b %Y %H:%M:%S %Z')"
head -n9 "$temp_release" | sed "s/^Date:.*$/Date: $now/g" > "$new_release"

echo "SHA256:" >> "$new_release"
pushd "$release_root"
find * -type f -not -path InRelease -exec $generate_index_line sha256sum {} \; >> "$new_release"
popd

gpg --sign --clear -a --yes --output "$release_index" "$new_release"
