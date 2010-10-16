#!/bin/bash
cp Changelog src
cd src

OUTPUT=${1:-../unject.zip}
rm -f $OUTPUT
zip -r $OUTPUT *
rm -f Changelog

haxelib test $OUTPUT
