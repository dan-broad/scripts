#!/bin/bash

mkdir /home/jupyter/notebooks/tmp
gsutil cp $1 /home/jupyter/notebooks/tmp/compressed
for filename in /home/jupyter/notebooks/tmp/compressed/*.tar.gz; do
  tar -zxf $filename -C home/jupyter/notebooks/tmp/decompressed     
done
gsutil cp -rm /home/jupyter/notebooks/tmp/decompressed $2
rm -rf /home/jupyter/notebooks/tmp
