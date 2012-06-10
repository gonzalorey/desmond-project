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

@interface IAPHelper : NSObject <SKProductsRequestDelegate> {
    NSSet * _productIdentifiers;
    SKProductsRequest * _request;
    NSArray * _products;
    NSMutableSet * _purchasedProducts;
}

@property (retain) SKProductsRequest *request;
@property (retain) NSSet *productIdentifiers;
@property (retain) NSArray * products;
@property (retain) NSMutableSet *purchasedProducts;

- (void)requestProducts;
- (id)initWithProductIdentifiers:(NSSet *)productIdentifiers;

@end
