#!/usr/bin/env bash

set -a
set -e
set -x

mkdir -p ./generated

MINOR=$(curl -fsSL http://download.rockylinux.org/pub/rocky/9/isos/x86_64/CHECKSUM | \
    head -n 1 | \
    cut -d . -f 2 | \
    cut -d - -f 1)

echo -n "${MINOR}" > ./generated/minor.txt

CHECKSUM=$(curl -fsSL "http://download.rockylinux.org/pub/rocky/9/isos/x86_64/Rocky-9.${MINOR}-x86_64-minimal.iso.CHECKSUM" | \
    tail -n 1 | \
    cut -d ' ' -f 4)

echo -n "${CHECKSUM}" > ./generated/checksum.txt
