#!/bin/bash -eu

BASEDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$BASEDIR"

$BASEDIR/setup.sh
ruby bin/pokemon2anki.rb
shasum assets/* >assets.sha1

git diff
