#import <Foundation/Foundation.h>
#import "LAPTipsDict.h"

@implementation LAPTipsDict
NSMutableDictionary * dict;
NSString * cur_lan;

- (NSString*) getString:(NSString*)key
{
    if(dict[cur_lan] && dict[cur_lan][key])
    {
        return dict[cur_lan][key];
    }
    else{
        return key;
    }
}

- (void) initLanguage: (NSString*) lang
{
    cur_lan = lang;
    [self initData];
}

- (void) initData
{
    if(!dict){
        dict = [[NSMutableDictionary alloc] init];
    }
    if(!dict[cur_lan])
    {
        NSMutableDictionary * info = [[NSMutableDictionary alloc] init];

        if([cur_lan containsString:@"zh_Hant"]){
            info[@"Tips_GetProductInfo"] = @"正在獲取信息";
            info[@"Tips_Paying"] = @"正在支付中";
            info[@"Tips_Confirm"] = @"正在確認訂單";
            info[@"Tips_Timeout"] = @"網絡超時，請耐心等待或重試";
            info[@"Tips_Ok"] = @"好的";
            info[@"Tips_Title"] = @"提示";
            info[@"Pay_Fail"] = @"支付失敗";
            info[@"Pay_NoProduct"] = @"未獲取到商品";
            info[@"Pay_AlreadyBuy"] = @"該產品已經購買";
        }
        
        else if([cur_lan containsString:@"zh"] ){
            info[@"Tips_GetProductInfo"] = @"正在获取信息";
            info[@"Tips_Paying"] = @"正在支付中";
            info[@"Tips_Confirm"] = @"正在确认订单";
            info[@"Tips_Timeout"] = @"网络超时，请耐心等待或重试";
            info[@"Tips_Ok"] = @"好的";
            info[@"Tips_Title"] = @"提示";
            info[@"Pay_Fail"] = @"支付失败";
            info[@"Pay_NoProduct"] = @"未获取到商品";
            info[@"Pay_AlreadyBuy"] = @"该产品已经购买";
        }
        
        else if([cur_lan containsString:@"en"]){
            info[@"Tips_GetProductInfo"] = @"Getting information";
            info[@"Tips_Paying"] = @"Paying";
            info[@"Tips_Confirm"] = @"Confirming";
            info[@"Tips_Timeout"] = @"Network timeout, please be patient or try again";
            info[@"Tips_Ok"] = @"Ok";
            info[@"Tips_Title"] = @"Tips";
            info[@"Pay_Fail"] = @"Payment failed";
            info[@"Pay_NoProduct"] = @"Unsuccessful item";
            info[@"Pay_AlreadyBuy"] = @"The product has been purchased";
        }
        
        else if([cur_lan containsString:@"ja"]){
            info[@"Tips_GetProductInfo"] = @"情報を取得中";
            info[@"Tips_Paying"] = @"支払い中";
            info[@"Tips_Confirm"] = @"注文の確認";
            info[@"Tips_Timeout "] = @"ネットワークがタイムアウトしました。しばらくお待ちください、またはもう一度やり直してください。";
            info[@"Tips_Ok"] = @"好";
            info[@"Tips_Title"] = @"ヒント";
            info[@"Pay_Fail"] = @"支払いに失敗しました";
            info[@"Pay_NoProduct"] = @"アイテムの失敗";
            info[@"Pay_AlreadyBuy"] = @"商品は購入されました";
        }
        
        else if([cur_lan isEqualToString:@"ko"]){
            info[@"Tips_GetProductInfo"] = @ "정보 얻기";
            info[@"Tips_Paying"] = @ "지불 중";
            info[@"Tips_Confirm"] = @ "주문 확인";
            info[@"Tips_Timeout"] = @ "네트워크 타임 아웃, 잠시 기다려주십시오.";
            info[@"Tips_Ok"] = @ "好";
            info[@"Tips_Title"] = @ "힌트";
            info[@"Pay_Fail"] = @ "지불 실패";
            info[@"Pay_NoProduct"] = @ "실패한 항목";
            info[@"Pay_AlreadyBuy"] = @ "제품을 구매했습니다";
        }
        
        dict[cur_lan] = info;
    }
}

- (id)init {
    if ((self = [super init])) {
        [self initLanguage:[NSLocale preferredLanguages][0]];
    }
    return self;
}

+ (LAPTipsDict *) sharedInstance
{
    static LAPTipsDict * _instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[LAPTipsDict alloc] init];
    });
    return _instance;
}

+ (NSString*) R:(NSString*)key
{
    return [[LAPTipsDict sharedInstance] getString:key];
}

+ (void) setLanguage:(NSString*) lang
{
    return [[LAPTipsDict sharedInstance] initLanguage:lang];
}

@end
