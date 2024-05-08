#!/bin/sh
# Tofu init is going to drop a .terraform folder inside the directory that we're in.
# /sources is a volume that is read-only.
# So, we need to copy files out of sources.
mkdir /home/tofu/sources
cd /home/tofu/sources
cp -r /sources/* ./
tofu init && tofu apply -auto-approve
