#import <Foundation/Foundation.h>
#import<objc/runtime.h>
#import "ApplePayTools.h"
#import "sys/utsname.h"

@implementation HYPhoneTools

+(int) getWifiSignal
{
    UIApplication *app = [UIApplication sharedApplication];
    NSArray *subviews = [[[app valueForKey:@"statusBar"] valueForKey:@"foregroundView"] subviews];
    NSString *dataNetworkItemView = nil;
    
    for (id subview in subviews) {
        if([subview isKindOfClass:[NSClassFromString(@"UIStatusBarDataNetworkItemView") class]]) {
            dataNetworkItemView = subview;
            break;
        }
    }
    
    return [[dataNetworkItemView valueForKey:@"_wifiStrengthBars"] intValue];
}

+(NSString*) getNetworkType
{
    UIApplication *app = [UIApplication sharedApplication];
    NSArray *subviews = [[[app valueForKeyPath:@"statusBar"] valueForKeyPath:@"foregroundView"] subviews];
    for (id subview in subviews) {
        if ([subview isKindOfClass:NSClassFromString(@"UIStatusBarDataNetworkItemView")]) {
            int networkType = [[subview valueForKeyPath:@"dataNetworkType"] intValue];
            switch (networkType) {
                case 0:
                    return @"NONE";
                    break;
                case 1:
                    return @"2G";
                    break;
                case 2:
                    return @"3G";
                    break;
                case 3:
                    return @"4G";
                    break;
                case 5:
                    return @"WIFI";
                    break;
                default:
                    break;
            }
        }
    }
    return @"NONE";
}

+ (float) getBattery
{
    [UIDevice currentDevice].batteryMonitoringEnabled = YES;
    return [UIDevice currentDevice].batteryLevel;
}

+ (NSString *) phoneName
{
    return [[UIDevice currentDevice] name];
}

+ (NSString *) phoneVersion
{
    return [[UIDevice currentDevice] systemVersion];
}

+ (NSString*) device
{
    struct utsname systemInfo;
    uname(&systemInfo);
    return [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
}

@end
