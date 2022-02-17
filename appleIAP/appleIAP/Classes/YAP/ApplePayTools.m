#import "ApplePayTools.h"
#import "LAPHelper.h"
#import "SFHFKeychainUtils.h"
#import "ApplePayTools.h"
#import "LAPTipsDict.h"

@implementation ApplePayTools

+(void) setLanguage : (NSString*) lan
{
    [LAPTipsDict setLanguage:lan];
}

+(void)iap:(NSString * )productId callback : (callbackBlock) callback
{
    [ApplePayTools class];
    if ([SKPaymentQueue canMakePayments]) {
        [LAPHelper sharedHelper].tipsEnabled = true;
        NSSet* dataSet = [[NSSet alloc] initWithObjects:productId, nil];
        // 请求商品信息
        [[LAPHelper sharedHelper] requestProductsWithCompletion:dataSet completion:^(SKProductsRequest* request,SKProductsResponse* response)
         {
             if(response.products.count > 0 ) {
                 SKProduct *product = response.products[0];
                 [[LAPHelper sharedHelper] yapProduct:product
                                            onCompletion:^(SKPaymentTransaction* trans){
                                                if(trans.error)
                                                {
                                                    if(callback) {
                                                        NSError* error = nil;
                                                        NSMutableDictionary* errorDetail = [[NSMutableDictionary alloc] init];
                                                        [errorDetail setValue:[LAPTipsDict R:@"Pay_Fail"] forKey:NSLocalizedDescriptionKey];
                                                        error = [NSError errorWithDomain:@"IAPHelperError" code:100 userInfo:errorDetail];
                                                        callback(nil,error);
                                                    }
                                                }
                                                else if(trans.transactionState == SKPaymentTransactionStatePurchased) {
                                                    NSData *receipt = [NSData dataWithContentsOfURL:[[NSBundle mainBundle] appStoreReceiptURL]];
                                                    [[LAPHelper sharedHelper] checkReceipt:receipt onCompletion:callback];
                                                }
                                                else if(trans.transactionState == SKPaymentTransactionStateFailed) {
                                                    if(callback) {
                                                        NSError* error = nil;
                                                        NSMutableDictionary* errorDetail = [[NSMutableDictionary alloc] init];
                                                        [errorDetail setValue:[LAPTipsDict R:@"Pay_Fail"] forKey:NSLocalizedDescriptionKey];
                                                        error = [NSError errorWithDomain:@"IAPHelperError" code:100 userInfo:errorDetail];
                                                        callback(nil,error);
                                                    }
                                                }
                                                else if(trans.transactionState == SKPaymentTransactionStateRestored) {
                                                    if(callback) {
                                                        NSError* error = nil;
                                                        NSMutableDictionary* errorDetail = [[NSMutableDictionary alloc] init];
                                                        [errorDetail setValue:[LAPTipsDict R:@"Pay_AlreadyBuy"] forKey:NSLocalizedDescriptionKey];
                                                        error = [NSError errorWithDomain:@"IAPHelperError" code:100 userInfo:errorDetail];
                                                        callback(nil,error);
                                                    }
                                                }
                                            }];
             }else{
                 //  ..未获取到商品
                 if(callback) {
                     NSError* error = nil;
                     NSMutableDictionary* errorDetail = [[NSMutableDictionary alloc] init];
                     [errorDetail setValue:[LAPTipsDict R:@"Pay_NoProduct"] forKey:NSLocalizedDescriptionKey];
                     error = [NSError errorWithDomain:@"IAPHelperError" code:100 userInfo:errorDetail];
                     callback(nil,error);
                 }
             }
         }];
    }
    else
    {
        if(callback) {
            NSError* error = nil;
            NSMutableDictionary* errorDetail = [[NSMutableDictionary alloc] init];
            [errorDetail setValue:@"您的手机没有打开程序内付费购买" forKey:NSLocalizedDescriptionKey];
            error = [NSError errorWithDomain:@"IAPHelperError" code:100 userInfo:errorDetail];
            callback(nil,error);
        }
    }
}

@end
