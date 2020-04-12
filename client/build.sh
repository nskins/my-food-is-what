#!/bin/bash

elm make src/Main.elm --output=main.js

rm -rf build
mkdir build

cp -r static/* build
mv main.js build/main.js