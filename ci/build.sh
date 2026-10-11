#!/bin/bash -ex

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
cd ${DIR}/..

TARGET=$1
ARCH=$2

if [[ -z "${ARCH}" ]]; then
    echo "usage $0 target arch"
    exit 1
fi

cargo build --release --target ${TARGET}

mkdir -p artifact/${ARCH}
cp target/${TARGET}/release/hbbs target/${TARGET}/release/hbbr target/${TARGET}/release/rustdesk-utils artifact/${ARCH}
chmod +x artifact/${ARCH}/*
