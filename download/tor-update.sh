#!/bin/bash

base_url="https://archive.torproject.org/tor-package-archive/torbrowser/"
# Get all version directories, sort, and pick the latest
latest=$(curl -s "$base_url" | grep -oP '(?<=href=")[0-9][^/]*/' | sed 's:/$::' | sort -V | tail -n 1)

win_name="tor-expert-bundle-windows-x86_64-$latest.tar.gz"
linux_name="tor-expert-bundle-linux-x86_64-$latest.tar.gz"

win_url="${base_url}${latest}/${win_name}"
linux_url="${base_url}${latest}/${linux_name}"

echo "Downloading $win_url"
curl -fLO "$win_url"
echo "Downloading $linux_url"
curl -fLO "$linux_url"
