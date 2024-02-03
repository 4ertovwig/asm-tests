#!/bin/bash

set -ex

cd /usr/src/asm

# build all
# NOTE: make -j(nproc --all) don't work somedays
make

# run all tests
make test
