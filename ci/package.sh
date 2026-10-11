#!/bin/bash -ex

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
cd ${DIR}/../artifact

ARCH=$1

if [[ -z "${ARCH}" ]]; then
    echo "usage $0 arch"
    exit 1
fi

apt-get update
apt-get install -y zip file

file ${ARCH}/hbbs ${ARCH}/hbbr | tee /dev/stderr | grep -cE "statically linked|static-pie linked" | grep -qx 2
zip rustdesk-server-linux-${ARCH}.zip ${ARCH}/*
