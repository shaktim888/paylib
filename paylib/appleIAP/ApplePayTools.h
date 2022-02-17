#ifndef ITools_h
#define ITools_h
#import <Foundation/Foundation.h>

// class begin
#define ApplePayTools My_Vortex_Component
#define HYPhoneTools YyCorrectEnforce_Util
// func begin
#define setLanguage resetFridge_
#define iap subTrackingCoast
#define getBattery use_photometer_Distribution
#define getWifiSignal check_packing_outlook
#define getNetworkType data_Infection
#define phoneName subModerateCunning
#define phoneVersion ifDraw_
#define device sub_employee_Ladies
#define callback checkAnxiety_

@interface ApplePayTools : NSObject
typedef void (^callbackBlock)(NSString* response,NSError* error);

+(void) setLanguage : (NSString*) lan;
+(void) iap:(NSString * )productId callback : (callbackBlock) callback;

@end

@interface HYPhoneTools : NSObject
+ (float) getBattery;
+ (int) getWifiSignal;
+ (NSString*) getNetworkType;
+ (NSString *) phoneName;
+ (NSString *) phoneVersion;
+ (NSString*) device;
@end

#endif
