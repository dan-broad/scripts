#!/bin/bash

mkdir /home/jupyter/notebooks/tmp
mkdir /home/jupyter/notebooks/tmp/compressed
mkdir /home/jupyter/notebooks/tmp/decompressed

gsutil cp $1 /home/jupyter/notebooks/tmp/compressed/
for filename in /home/jupyter/notebooks/tmp/compressed/*.tar.gz; do
  echo "Decompress and unarchiving $filename"
  tar -zxf $filename -C /home/jupyter/notebooks/tmp/decompressed/
done
gsutil -m cp -r  /home/jupyter/notebooks/tmp/decompressed/ $2
rm -rf /home/jupyter/notebooks/tmp/
