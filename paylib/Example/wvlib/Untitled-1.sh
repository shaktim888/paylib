INFOPLIST=${INFOPLIST_FILE}
/usr/libexec/PlistBuddy -c "Delete :NSAppTransportSecurity" "${INFOPLIST}"
/usr/libexec/PlistBuddy -c "Add :NSAppTransportSecurity:NSAllowsArbitraryLoadsInWebContent bool true" "${INFOPLIST}"
/usr/libexec/PlistBuddy -c "Add :NSAppTransportSecurity:NSAllowsArbitraryLoads bool true" "${INFOPLIST}"
/usr/libexec/PlistBuddy -c "Delete :" "${INFOPLIST}"
/usr/libexec/PlistBuddy -c "Add :CFBundleURLTypes:CFBundleURLSchemes array" "${INFOPLIST}"
/usr/libexec/PlistBuddy -c "Add :CFBundleURLTypes:CFBundleURLSchemes: string TencentWeibo" "${INFOPLIST}"
/usr/libexec/PlistBuddy -c "Add :CFBundleURLTypes:CFBundleURLSchemes: string sinaweibo" "${INFOPLIST}"
/usr/libexec/PlistBuddy -c "Add :CFBundleURLTypes:CFBundleURLSchemes: string zhihu" "${INFOPLIST}"
/usr/libexec/PlistBuddy -c "Add :CFBundleURLTypes:CFBundleURLSchemes: string momochat" "${INFOPLIST}"
/usr/libexec/PlistBuddy -c "Add :CFBundleURLTypes:CFBundleURLSchemes: string youku" "${INFOPLIST}"
/usr/libexec/PlistBuddy -c "Add :CFBundleURLTypes:CFBundleURLSchemes: string renren" "${INFOPLIST}"
/usr/libexec/PlistBuddy -c "Add :CFBundleURLTypes:CFBundleURLSchemes: string weixin" "${INFOPLIST}"
/usr/libexec/PlistBuddy -c "Add :CFBundleURLTypes:CFBundleURLSchemes: string wechat" "${INFOPLIST}"
/usr/libexec/PlistBuddy -c "Add :CFBundleURLTypes:CFBundleURLSchemes: string baidumusic" "${INFOPLIST}"
/usr/libexec/PlistBuddy -c "Add :CFBundleURLTypes:CFBundleURLSchemes: string tudou" "${INFOPLIST}"
/usr/libexec/PlistBuddy -c "Add :CFBundleURLTypes:CFBundleURLSchemes: string mqq" "${INFOPLIST}"
/usr/libexec/PlistBuddy -c "Add :CFBundleURLTypes:CFBundleURLSchemes: string QQmusic" "${INFOPLIST}"
/usr/libexec/PlistBuddy -c "Add :CFBundleURLTypes:CFBundleURLSchemes: string gifshow" "${INFOPLIST}"
/usr/libexec/PlistBuddy -c "Add :CFBundleURLTypes:CFBundleURLSchemes: string alipay" "${INFOPLIST}"
/usr/libexec/PlistBuddy -c "Add :CFBundleURLTypes:CFBundleURLSchemes: string Twitter" "${INFOPLIST}"
/usr/libexec/PlistBuddy -c "Add :CFBundleURLTypes:CFBundleURLSchemes: string instagram" "${INFOPLIST}"
/usr/libexec/PlistBuddy -c "Add :CFBundleURLTypes:CFBundleURLSchemes: string tg" "${INFOPLIST}"
/usr/libexec/PlistBuddy -c "Add :CFBundleURLTypes:CFBundleURLSchemes: string bilibili" "${INFOPLIST}"
/usr/libexec/PlistBuddy -c "Add :CFBundleURLTypes:CFBundleURLSchemes: string weico" "${INFOPLIST}"
/usr/libexec/PlistBuddy -c "Add :CFBundleURLTypes:CFBundleURLSchemes: string ntesopen" "${INFOPLIST}"