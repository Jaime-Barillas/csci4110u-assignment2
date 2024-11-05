#!/usr/bin/env bash

if [ ! -f ./build/assignment2 ]; then
  meson setup build
  meson compile -C build
fi

mkdir -p out
./handin/assignment2 "$@"
