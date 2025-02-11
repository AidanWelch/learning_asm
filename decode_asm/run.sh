#!/bin/bash

nasm -felf64 -o decode.o decode.asm
ld -o decode decode.o
rm decode.o
./decode
