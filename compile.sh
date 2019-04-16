#!/bin/bash

git submodule sync
git submodule init
git submodule update

pushd external/ntripcaster/ntripcaster0.1.5/

./configure &&
make &&
make install

popd

pushd external/RTKLIB-demo5/app
make all

mkdir -p /usr/local/bin
cp str2str/gcc/str2str /usr/local/bin
popd

