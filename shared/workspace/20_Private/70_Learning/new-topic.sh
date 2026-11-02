#!/bin/sh
# Usage: ./new-topic.sh <topic-slug>  - creates a teach workspace (skills come from the mattpocock-skills plugin).
set -e
[ -n "$1" ] || { echo "usage: $0 <topic-slug>"; exit 1; }
dir="$(cd "$(dirname "$0")" && pwd)/$1"
mkdir -p "$dir"
[ -d "$dir/.git" ] || git -C "$dir" init -q
echo "Ready: cd $dir && claude   then /teach <what you want to learn>"
