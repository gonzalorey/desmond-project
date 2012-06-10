//
//  IAPHelper.h
//  InAppPurchase Test
//
//  Created by Gonzalo Rey on 6/10/12.
//  Copyright (c) 2012 OLX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "StoreKit/StoreKit.h"

#define kProductsLoadedNotification         @"ProductsLoaded"
#define kProductPurchasedNotification       @"ProductPurchased"
#define kProductPurchaseFailedNotification  @"ProductPurchaseFailed"

@interface IAPHelper : NSObject <SKProductsRequestDelegate, SKPaymentTransactionObserver> {
    NSSet * _productIdentifiers;
    SKProductsRequest * _request;
    NSArray * _products;
    NSMutableSet * _purchasedProducts;
    
    UIView * _waitView;
}

@property (retain) SKProductsRequest *request;
@property (retain) NSSet *productIdentifiers;
@property (retain) NSArray * products;
@property (retain) NSMutableSet *purchasedProducts;
@property(nonatomic,retain) UIView * waitView;

+ (IAPHelper *) sharedHelper;

- (void)requestProducts:(UIView *)waitView;
- (id)initWithProductIdentifiers:(NSSet *)productIdentifiers;
- (void)buyProductIdentifier:(NSString *)productIdentifier;

@end
