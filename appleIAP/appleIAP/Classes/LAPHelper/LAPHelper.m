//
//  IAPHelper.m
//
//  Original Created by Ray Wenderlich on 2/28/11.
//  Created by saturngod on 7/9/12.
//  Copyright 2011 Ray Wenderlich. All rights reserved.
//

#import "LAPHelper.h"
#import "SFHFKeychainUtils.h"
#import "LAPTipsDict.h"

static char base64EncodingTable[64] = {
    'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P',
    'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', 'a', 'b', 'c', 'd', 'e', 'f',
    'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v',
    'w', 'x', 'y', 'z', '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '+', '/'
};
static dispatch_source_t _timer;

@interface LAPHelper()

@property (nonatomic,copy) LAPProductsResponseBlock requestProductsBlock;
@property (nonatomic,copy) LAPbuyProductCompleteResponseBlock buyProductCompleteBlock;
@property (nonatomic,copy) resoreProductsCompleteResponseBlock restoreCompletedBlock;
@property (nonatomic,copy) checkReceiptCompleteResponseBlock checkReceiptCompleteBlock;

@property (nonatomic,strong) NSMutableData* receiptRequestData;
@end

@implementation LAPHelper

-(void) startNetTimerCheck
{
    [self stopTimerCheck];
    __block float waitTime = 16.f;
    //设置时间间隔
    NSTimeInterval period = 1.f;
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    dispatch_source_set_timer(_timer, dispatch_walltime(NULL, 0), period * NSEC_PER_SEC, 0);
    // 事件回调
    dispatch_source_set_event_handler(_timer, ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            waitTime = waitTime - period;
            if(waitTime <= 0)
            {
                [self hideWait];
                self.tipsEnabled = false;
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:[LAPTipsDict R:@"Tips_Title"] message:[LAPTipsDict R:@"Tips_Timeout"]
                                                              delegate:nil cancelButtonTitle:[LAPTipsDict R:@"Tips_Ok"] otherButtonTitles: nil];
                [alert show];
            }
        });
    });
    // 开启定时器
    dispatch_resume(_timer);
}

-(void) stopTimerCheck
{
    if(_timer)
    {
        // 关闭定时器
        dispatch_source_cancel(_timer);
        _timer = nil;
    }
}

+ (LAPHelper *) sharedHelper {
    static LAPHelper * _sharedHelper = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedHelper = [[LAPHelper alloc] init];
    });
    return _sharedHelper;
}

+ (NSString *) base64StringFromData:(NSData *)data length:(long)length {
    unsigned long ixtext, lentext;
    long ctremaining;
    unsigned char input[3], output[4];
    short i, charsonline = 0, ctcopy;
    const unsigned char *raw;
    NSMutableString *result;
    
    lentext = [data length];
    if (lentext < 1)
        return @"";
    result = [NSMutableString stringWithCapacity: lentext];
    raw = [data bytes];
    ixtext = 0;
    
    while (true) {
        ctremaining = lentext - ixtext;
        if (ctremaining <= 0)
            break;
        for (i = 0; i < 3; i++) {
            unsigned long ix = ixtext + i;
            if (ix < lentext)
                input[i] = raw[ix];
            else
                input[i] = 0;
        }
        output[0] = (input[0] & 0xFC) >> 2;
        output[1] = ((input[0] & 0x03) << 4) | ((input[1] & 0xF0) >> 4);
        output[2] = ((input[1] & 0x0F) << 2) | ((input[2] & 0xC0) >> 6);
        output[3] = input[2] & 0x3F;
        ctcopy = 4;
        switch (ctremaining) {
            case 1:
                ctcopy = 2;
                break;
            case 2:
                ctcopy = 3;
                break;
        }
        
        for (i = 0; i < ctcopy; i++)
            [result appendString: [NSString stringWithFormat: @"%c", base64EncodingTable[output[i]]]];
        
        for (i = ctcopy; i < 4; i++)
            [result appendString: @"="];
        
        ixtext += 3;
        charsonline += 4;
        
        if ((length > 0) && (charsonline >= length))
            charsonline = 0;
    }
    return result;
}

- (id)init {
    if ((self = [super init])) {
        if ([SKPaymentQueue defaultQueue]) {
            [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
        }
        self.production = true;
        self.tipsEnabled = false;
        self.purchasedProducts = [NSMutableSet set];
        self.productIdentifiers = [NSMutableSet set];
    }
    return self;
}

-(void) showWait : (NSString * )msg
{
    if(!self.tipsEnabled)
    {
        return;
    }
    [self hideWait];
    [self startNetTimerCheck];
    self.baseAlert = [[[UIAlertView alloc] initWithTitle:msg message:nil delegate:self cancelButtonTitle:nil otherButtonTitles: nil] autorelease];
    [self.baseAlert show];
    
    // Create and add the activity indicator
    UIActivityIndicatorView *aiv = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    aiv.center = CGPointMake(self.baseAlert.bounds.size.width / 2.0f, self.baseAlert.bounds.size.height - 40.0f);
    [aiv startAnimating];
    [self.baseAlert addSubview:aiv];
    [aiv release];
}

-(void) hideWait
{
    [self stopTimerCheck];
    if(self.baseAlert)
    {
        [self.baseAlert dismissWithClickedButtonIndex:0 animated:NO];
        [self.baseAlert removeFromSuperview];
        self.baseAlert = nil;
    }
}

- (void) addProductIdentifiers:(NSSet *)productIdentifiers
{
    for (NSString * productIdentifier in productIdentifiers) {
        if(![self.productIdentifiers containsObject:productIdentifier])
        {
            [self.productIdentifiers addObject:productIdentifier];
        }
    }
    
    // Check for previously purchased products
    NSMutableSet * purchasedProducts = self.purchasedProducts;
    for (NSString * productIdentifier in self.productIdentifiers) {
        
        BOOL productPurchased = NO;
        
        NSString* password = [SFHFKeychainUtils getPasswordForUsername:productIdentifier andServiceName:@"IAPHelper" error:nil];
        if([password isEqualToString:@"YES"])
        {
            productPurchased = YES;
        }
        
        if (productPurchased) {
            if(![self.purchasedProducts containsObject:productIdentifier])
            {
                [self.purchasedProducts addObject:productIdentifier];
            }
        }
    }
}

- (void)dealloc
{
    if ([SKPaymentQueue defaultQueue]) {
        [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
    }
    [self hideWait];
}

-(BOOL)isPurchasedProductsIdentifier:(NSString*)productID
{

    BOOL productPurchased = NO;
    
    NSString* password = [SFHFKeychainUtils getPasswordForUsername:productID andServiceName:@"IAPHelper" error:nil];
    if([password isEqualToString:@"YES"])
    {
        productPurchased = YES;
    }

    return productPurchased;
}

- (void)requestProductsWithCompletion:(NSSet *)productIdentifiers completion : (LAPProductsResponseBlock)completion {
    [self showWait:[LAPTipsDict R:@"Tips_GetProductInfo"]];
    [self addProductIdentifiers:productIdentifiers];
    self.request = [[SKProductsRequest alloc] initWithProductIdentifiers:productIdentifiers];
    _request.delegate = self;
    self.requestProductsBlock = completion;
    [_request start];
}

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    [self hideWait];
    self.products = response.products;
    self.request = nil;

    if(_requestProductsBlock) {
        _requestProductsBlock (request,response);
    }

}

- (void)recordTransaction:(SKPaymentTransaction *)transaction {    
    // TODO: Record the transaction on the server side...    
}


- (void)provideContentWithTransaction:(SKPaymentTransaction *)transaction {
    
    NSString* productIdentifier = @"";
    
    if (transaction.originalTransaction) {
        productIdentifier = transaction.originalTransaction.payment.productIdentifier;
    }
    else {
        productIdentifier = transaction.payment.productIdentifier;
    }
    
    //check productIdentifier exist or not
    //it can be possible nil
    if (productIdentifier) {
        [SFHFKeychainUtils storeUsername:productIdentifier andPassword:@"YES" forServiceName:@"IAPHelper" updateExisting:YES error:nil];
        if(![self.productIdentifiers containsObject:productIdentifier])
        {
            [self.productIdentifiers addObject:productIdentifier];
        }
    }
}

- (void)provideContent:(NSString *)productIdentifier {
    
    [SFHFKeychainUtils storeUsername:productIdentifier andPassword:@"YES" forServiceName:@"IAPHelper" updateExisting:YES error:nil];
    if(![self.purchasedProducts containsObject:productIdentifier])
    {
        [self.purchasedProducts addObject:productIdentifier];
    }
}

- (void)clearSavedPurchasedProducts {
    
    for (NSString * productIdentifier in _productIdentifiers) {
        [self clearSavedPurchasedProductByID:productIdentifier];
    }
    
}
- (void)clearSavedPurchasedProductByID:(NSString*)productIdentifier {
    
    [SFHFKeychainUtils deleteItemForUsername:productIdentifier andServiceName:@"IAPHelper" error:nil];
    [_purchasedProducts removeObject:productIdentifier];
    
}


- (void)completeTransaction:(SKPaymentTransaction *)transaction {
    [self recordTransaction: transaction];

    if ([SKPaymentQueue defaultQueue]) {
        [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
    }

    if(_buyProductCompleteBlock)
    {
        _buyProductCompleteBlock(transaction);
    }

}

- (void)restoreTransaction:(SKPaymentTransaction *)transaction {
    [self recordTransaction: transaction];
    [self provideContentWithTransaction:transaction];
    
    if ([SKPaymentQueue defaultQueue]) {
        [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
            

        if(_buyProductCompleteBlock!=nil)
        {
            _buyProductCompleteBlock(transaction);
        }
    }
    
}

- (void)failedTransaction:(SKPaymentTransaction *)transaction {
    if (transaction.error.code != SKErrorPaymentCancelled)
    {
        NSLog(@"Transaction error: %@ %ld", transaction.error.localizedDescription,(long)transaction.error.code);
    }
    if ([SKPaymentQueue defaultQueue]) {
        [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
        if(_buyProductCompleteBlock) {
            _buyProductCompleteBlock(transaction);
        }
    }
    
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    for (SKPaymentTransaction *transaction in transactions)
    {
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchased:
                [self hideWait];
                [self completeTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                [self hideWait];
                [self failedTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:
                [self hideWait];
                [self restoreTransaction:transaction];
            case SKPaymentTransactionStatePurchasing:
                [self stopTimerCheck];
            default:
                break;
        }
    }
}

- (void)yapProduct:(SKProduct *)productIdentifier onCompletion:(LAPbuyProductCompleteResponseBlock)completion {
    [self showWait:[LAPTipsDict R:@"Tips_Paying"]];
    self.buyProductCompleteBlock = completion;
    
    self.restoreCompletedBlock = nil;
    SKPayment *payment = [SKPayment paymentWithProduct:productIdentifier];

    if ([SKPaymentQueue defaultQueue]) {
        [[SKPaymentQueue defaultQueue] addPayment:payment];
    }

}

-(void)restoreProductsWithCompletion:(resoreProductsCompleteResponseBlock)completion {

    //clear it
    self.buyProductCompleteBlock = nil;
    
    self.restoreCompletedBlock = completion;
    if ([SKPaymentQueue defaultQueue]) {
        [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
    }
    else {
        NSLog(@"Cannot get the default Queue");
    }
    
    
}

- (void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error {
    
    NSLog(@"Transaction error: %@ %ld", error.localizedDescription,(long)error.code);
    if(_restoreCompletedBlock) {
        _restoreCompletedBlock(queue,error);
    }
}

- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue {
    
    for (SKPaymentTransaction *transaction in queue.transactions)
    {
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStateRestored:
            {
                [self recordTransaction: transaction];
                [self provideContentWithTransaction:transaction];
                
            }
            default:
                break;
        }
    }
    
    if(_restoreCompletedBlock) {
        _restoreCompletedBlock(queue,nil);
    }

}

- (void)checkReceipt:(NSData*)receiptData onCompletion:(checkReceiptCompleteResponseBlock)completion
{
    [self checkReceipt:receiptData AndSharedSecret:nil onCompletion:completion];
}

- (void)checkReceipt:(NSData*)receiptData AndSharedSecret:(NSString*)secretKey onCompletion:(checkReceiptCompleteResponseBlock)completion
{
    [self showWait:[LAPTipsDict R:@"Tips_Confirm"]];
    self.checkReceiptCompleteBlock = completion;

    NSError *jsonError = nil;
    NSString *receiptBase64 = [LAPHelper base64StringFromData:receiptData length:[receiptData length]];


    NSData *jsonData = nil;

    if(secretKey !=nil && ![secretKey isEqualToString:@""]) {
        
        jsonData = [NSJSONSerialization dataWithJSONObject:[NSDictionary dictionaryWithObjectsAndKeys:receiptBase64,@"receipt-data",
                                                            secretKey,@"password",
                                                            nil]
                                                   options:NSJSONWritingPrettyPrinted
                                                     error:&jsonError];
        
    }
    else {
        jsonData = [NSJSONSerialization dataWithJSONObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                receiptBase64,@"receipt-data",
                                                                nil]
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&jsonError
                        ];
    }


//    NSString* jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];

    NSURL *requestURL = nil;
    if(_production)
    {
        requestURL = [NSURL URLWithString:@"https://buy.itunes.apple.com/verifyReceipt"];
    }
    else {
        requestURL = [NSURL URLWithString:@"https://sandbox.itunes.apple.com/verifyReceipt"];
    }

    NSMutableURLRequest *req = [[NSMutableURLRequest alloc] initWithURL:requestURL];
    [req setHTTPMethod:@"POST"];
    [req setHTTPBody:jsonData];

    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:req delegate:self];
    if(conn) {
        self.receiptRequestData = [[NSMutableData alloc] init];
    } else {
        [self hideWait];
        NSError* error = nil;
        NSMutableDictionary* errorDetail = [[NSMutableDictionary alloc] init];
        [errorDetail setValue:@"支付验证失败" forKey:NSLocalizedDescriptionKey];
        error = [NSError errorWithDomain:@"IAPHelperError" code:100 userInfo:errorDetail];
        if(_checkReceiptCompleteBlock) {
            _checkReceiptCompleteBlock(nil,error);
        }
    }
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"Cannot transmit receipt data. %@",[error localizedDescription]);
    [self hideWait];
    if(_checkReceiptCompleteBlock) {
        _checkReceiptCompleteBlock(nil,error);
    }
    
}

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    [self.receiptRequestData setLength:0];
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.receiptRequestData appendData:data];
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [self hideWait];
    NSString *response = [[NSString alloc] initWithData:self.receiptRequestData encoding:NSUTF8StringEncoding];
    if(_checkReceiptCompleteBlock) {
        _checkReceiptCompleteBlock(response,nil);
    }
}

- (NSString *)getLocalePrice:(SKProduct *)product {
    if (product) {
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        [formatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
        [formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
        [formatter setLocale:product.priceLocale];
        
        return [formatter stringFromNumber:product.price];
    }
    return @"";
    
    
}
@end
