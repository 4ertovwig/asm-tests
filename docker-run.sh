#!/bin/bash

PROJECT_NAME=asm

docker run -it --rm $PROJECT_NAME 2>&1 | tee asm-tests-log
