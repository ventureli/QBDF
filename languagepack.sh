#!/bin/bash
echo '==>begin create'
lipo -create ./Release-iphoneos/QBDFLanguage.framework/QBDFLanguage ./Release-iphonesimulator/QBDFLanguage.framework/QBDFLanguage -output QBDFLanguage

echo '==>begin copy'
cp -r ./Release-iphoneos/QBDFLanguage.framework ./
cp ./QBDFLanguage    ./QBDFLanguage.framework

echo '==>begin zip'

rm ./QBDFLanguage.framework.zip
zip -r QBDFLanguage.framework.zip ./QBDFLanguage.framework

echo '==>begin rmove tmp file'

rm ./QBDFLanguage
rm -rf ./QBDFLanguage.framework
