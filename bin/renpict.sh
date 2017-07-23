#!/usr/bin/env bash
# Rename pictures nicely, ordered chronologically

# Check for the number of arguments
me=`basename "$0"`
if [ $# -lt 1 ]; then
  echo "Usage: $me <prefix>"
  echo "Example: $me Pict"
  exit
fi

# Take out the first name, we use it as a prefix
count=1
prefix1=$1
prefix2="$1_"
suffixlen=3
negsuffix=$((-$suffixlen))
shift 1

# Set 644 permissions
chmod 644 *

# Set the file name to the file create date timestamp
exiftool -q -d %Y%m%d-%H%M%S%%+c.%%e "-FileName<CreateDate" *

# Rename each file
for filename in *; do
  # Get suitable number of zeroes into the filename
  csize=${#count}
  cdiff=$((4-$csize))
  prefix3=$prefix2
  while [ $cdiff -gt 0 ]; do
    prefix3="$prefix3"0
    cdiff=$(($cdiff-1))
  done

  nsuffix=${filename:$negsuffix:$suffixlen}
  nsuffix2=`expr "xxx$nsuffix" : 'xxx\(.*\)' | tr '[A-Z]' '[a-z]'`
  newname=${prefix3}${count}.${nsuffix2}

  # Use mv to rename the file
  if [ "$filename" != "$newname" ]; then
    mv "$filename" "$newname"
  fi

  count=$(($count+1))
done
