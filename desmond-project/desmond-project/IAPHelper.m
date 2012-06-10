//
//  IAPHelper.m
//  InAppPurchase Test
//
//  Created by Gonzalo Rey on 6/10/12.
//  Copyright (c) 2012 OLX. All rights reserved.
//

#import "IAPHelper.h"

@implementation IAPHelper

@synthesize request = _request;
@synthesize productIdentifiers = _productIdentifiers;
@synthesize products = _products;
@synthesize purchasedProducts = _purchasedProducts;

- (id)initWithProductIdentifiers:(NSSet *)productIdentifiers {
    if ((self = [super init])) {
        
        // Store product identifiers
        _productIdentifiers = productIdentifiers;
        
        // Check for previously purchased products
        NSMutableSet * purchasedProducts = [NSMutableSet set];
        for (NSString * productIdentifier in _productIdentifiers) {
            BOOL productPurchased = [[NSUserDefaults standardUserDefaults] boolForKey:productIdentifier];
            if (productPurchased) {
                [purchasedProducts addObject:productIdentifier];
                NSLog(@"Previously purchased: %@", productIdentifier);
            }
            NSLog(@"Not purchased: %@", productIdentifier);
        }
        self.purchasedProducts = purchasedProducts;
        
    }
    return self;
}

- (void)requestProducts {
    
    self.request = [[SKProductsRequest alloc] initWithProductIdentifiers:_productIdentifiers];
    _request.delegate = self;
    [_request start];
    
}

- (NSString *)localizedPrice:(NSDecimalNumber *)price inLocale:(NSLocale *)locale{
    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [numberFormatter setLocale:locale];
    NSString *formattedString = [numberFormatter stringFromNumber:price];
    return formattedString;
}

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    
//    NSLog(@"Received products results...");   
    self.products = response.products;
    
//    NSLog(@"Products fetch: %d", [response.products count]);
    
    for (NSString *invalidProductId in response.invalidProductIdentifiers)
    {
//        NSLog(@"Invalid product id: %@" , invalidProductId);
    }
    
    for (SKProduct * p in response.products) {
//        NSLog(@"Product title: %@" , p.localizedTitle);
//        NSLog(@"Product description: %@" , p.localizedDescription);
//        NSLog(@"Product price: %@" , [self localizedPrice:p.price inLocale:p.priceLocale]);
//        NSLog(@"Product id: %@" , p.productIdentifier);
    }
    
//    NSLog(@"They should have been printed so far...");

    self.request = nil;    
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kProductsLoadedNotification object:nil];    
}

- (void)productsRequest:(SKProductsRequest *)request didFailWithError:(SKProductsResponse *) 
    response {
    
    NSLog(@"Hubo un error...");
    
}

- (void)dealloc
{;
    _productIdentifiers = nil;
    _products = nil;
    _purchasedProducts = nil;
    _request = nil;
}

@end
