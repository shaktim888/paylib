#!/bin/
set -x
work_path=$(cd `dirname $0`; pwd)
rm -rf $work_path/../../appleIAP_temp
cp -r -f $work_path/../../appleIAP $work_path/../../appleIAP_temp
# echo $work_path
lc_work_path=$work_path/../../appleIAP_temp
lib_work_path=$work_path/../../paylib

$work_path/HYCodeScan.app/Contents/MacOS/HYCodeScan --redefine -i $lc_work_path/appleIAP/Classes/YAP/ApplePayTools.h -i $lc_work_path/appleIAP/Classes/LAPHelper/realprefix.pch -i $lib_work_path/prefix.pch
$work_path/HYCodeScan.app/Contents/MacOS/HYCodeScan --xcode --config $work_path/appConfig.json -p $lc_work_path/Example/Pods/Pods.xcodeproj

cp $lc_work_path/appleIAP/Classes/YAP/ApplePayTools.h $lc_work_path/Example/Pods/Headers/Public/appleIAP/

xcodebuild -workspace $lc_work_path/Example/appleIAP.xcworkspace -scheme hyInYAP-Example -sdk iphonesimulator11.4 -configuration Release clean build -jobs 8
xcodebuild -workspace $lc_work_path/Example/appleIAP.xcworkspace -scheme hyInYAP-Example -sdk iphoneos12.1 -configuration Release clean build -jobs 8

sh $lib_work_path/updateVersion.sh

productFolder="Example/Pods/Products/appleIAP"
for i in `ls $lc_work_path/$productFolder`; do
cp -r $lc_work_path/$productFolder/$i $lib_work_path/appleIAP/
done

function comit()
{
	cd $lib_work_path
	git add -u && git commit -m 'autobuild' && git push origin master
}

comit