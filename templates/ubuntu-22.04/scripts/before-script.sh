#!/usr/bin/env bash

set -a
set -e
set -x

mkdir -p ./generated

MINOR=$(curl -fsSL https://releases.ubuntu.com/22.04/SHA256SUMS | \
     tail -n 1 | \
     cut -d ' ' -f 2 | \
     cut -d . -f 3 | \
     cut -d - -f 1)

echo -n "${MINOR}" > ./generated/minor.txt

CHECKSUM=$(curl -fsSL "https://releases.ubuntu.com/22.04/SHA256SUMS" | \
    tail -n 1 | \
    cut -d ' ' -f 1)

echo -n "${CHECKSUM}" > ./generated/checksum.txt
