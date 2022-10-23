#!/bin/bash -eu

sumbin=${1}
file=${2}

sum=$($sumbin "$file" | cut -d' ' -f1)
size=$(stat --printf "%s" "$file")

printf "  %s %+10s %s\n" $sum $size $file
