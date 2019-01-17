#!/bin/bash

BASEDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$BASEDIR"

rm -rf "$BASEDIR/PogoAssets"
git clone --depth 1 https://github.com/ZeChrales/PogoAssets.git

rm -rf "$BASEDIR/pokemon-svg"
git clone --depth 1 https://github.com/claytono/pokemon-svg
# To rebuild all pngs, run the following command
# make all OPTS="pad 256:256" OUT="$(pwd)/out"

rm -rf "$BASEDIR/pokemon-pronunciation"
git clone --depth 1 https://github.com/claytono/pokemon-pronunciation

rm -rf "$BASEDIR/assets"
mkdir "$BASEDIR/assets"

