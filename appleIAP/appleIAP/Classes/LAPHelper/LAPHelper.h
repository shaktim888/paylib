//
//  IAPHelper.h
//
//  Original Created by Ray Wenderlich on 2/28/11.
//  Created by saturngod on 7/9/12.
//  Copyright 2011 Ray Wenderlich. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "StoreKit/StoreKit.h"


typedef void (^LAPProductsResponseBlock)(SKProductsRequest* request , SKProductsResponse* response);

typedef void (^LAPbuyProductCompleteResponseBlock)(SKPaymentTransaction* transcation);

typedef void (^checkReceiptCompleteResponseBlock)(NSString* response,NSError* error);

typedef void (^resoreProductsCompleteResponseBlock) (SKPaymentQueue* payment,NSError* error);

@interface LAPHelper : NSObject <SKProductsRequestDelegate, SKPaymentTransactionObserver>

@property (nonatomic,strong) NSMutableSet *productIdentifiers;

@property (nonatomic,strong) NSArray * products;
@property (nonatomic,strong) NSMutableSet *purchasedProducts;
@property (nonatomic,strong) SKProductsRequest *request;
@property (nonatomic) BOOL production;

@property (nonatomic) BOOL tipsEnabled;

+ (LAPHelper *) sharedHelper;
-(void) showWait : (NSString * )msg;
-(void) hideWait;

@property (nonatomic,strong) UIAlertView *baseAlert;

- (void) addProductIdentifiers:(NSSet *)productIdentifiers;
//get Products List
- (void)requestProductsWithCompletion:(NSSet *)productIdentifiers completion : (LAPProductsResponseBlock)completion;


//Buy Product
- (void)yapProduct:(SKProduct *)productIdentifier onCompletion:(LAPbuyProductCompleteResponseBlock)completion;

//restore Products
- (void)restoreProductsWithCompletion:(resoreProductsCompleteResponseBlock)completion;

//check isPurchased or not
- (BOOL)isPurchasedProductsIdentifier:(NSString*)productID;

//check receipt but recommend to use in server side instead of using this function
- (void)checkReceipt:(NSData*)receiptData onCompletion:(checkReceiptCompleteResponseBlock)completion;

- (void)checkReceipt:(NSData*)receiptData AndSharedSecret:(NSString*)secretKey onCompletion:(checkReceiptCompleteResponseBlock)completion;


//saved purchased product
- (void)provideContentWithTransaction:(SKPaymentTransaction *)transaction;

- (void)provideContent:(NSString *)productIdentifier __deprecated_msg("use provideContentWithTransaction: instead.");

//clear the saved products
- (void)clearSavedPurchasedProducts;
- (void)clearSavedPurchasedProductByID:(NSString*)productIdentifier;


//Get The Price with local currency
- (NSString *)getLocalePrice:(SKProduct *)product;

@end
