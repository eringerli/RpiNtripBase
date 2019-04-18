#!/bin/bash

git submodule sync
git submodule init
git submodule update

pushd external/ntripcaster/ntripcaster0.1.5/

./configure &&
make &&
make install

popd

pushd external/rtklib-demo5/app/str2str/gcc/
make

mkdir -p /usr/local/bin
cp str2str /usr/local/bin
popd

