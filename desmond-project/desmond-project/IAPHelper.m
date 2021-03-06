//
//  IAPHelper.m
//  InAppPurchase Test
//
//  Created by Gonzalo Rey on 6/10/12.
//  Copyright (c) 2012 OLX. All rights reserved.
//

#import "IAPHelper.h"
#import "MBProgressHUD.h"

@implementation IAPHelper

@synthesize request = _request;
@synthesize productIdentifiers = _productIdentifiers;
@synthesize products = _products;
@synthesize purchasedProducts = _purchasedProducts;
@synthesize waitView = _waitView;

static IAPHelper * _sharedHelper;

// singleton instance
+ (IAPHelper *) sharedHelper {
    
    if (_sharedHelper != nil) {
        return _sharedHelper;
    }
    _sharedHelper = [[IAPHelper alloc] init];
    return _sharedHelper;
}

- (id)init {
    
    NSSet *productIdentifiers = [NSSet setWithObjects:
                                 @"com.igvsoft.desmondproject.5",
                                 @"com.igvsoft.desmondproject.10",
                                 @"com.igvsoft.desmondproject.20",
                                 @"com.igvsoft.desmondproject.50",
                                 @"com.igvsoft.desmondproject.100",                                 
                                 nil];
    
    if ((self = [self initWithProductIdentifiers:productIdentifiers])) {                
        // do nothing
    }
    return self;
}

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

- (void)requestProducts:(UIView *)waitView {
    
    self.waitView = waitView;
    
    [MBProgressHUD showWaitAlert:@"Loading products..." inView:waitView];
    
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
    
    self.products = [response.products sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        SKProduct * prod1 = obj1;
        SKProduct * prod2 = obj2;
        
        // Parse the purchased remainders from the response
        NSArray *tokens = [prod1.productIdentifier componentsSeparatedByString: @"."];
        int num1 = [[tokens objectAtIndex:[tokens count] - 1] intValue];
        
        tokens = [prod2.productIdentifier componentsSeparatedByString: @"."];
        int num2 = [[tokens objectAtIndex:[tokens count] - 1] intValue];
        
        if (num1 < num2) {
            return NSOrderedAscending;
        }else {
            return NSOrderedDescending;
        }
        
        return [prod1.productIdentifier compare:prod2.productIdentifier];
        
    }];
    
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

    self.request = nil;
    
    [MBProgressHUD hideWaitAlertInView:self.waitView];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kProductsLoadedNotification object:nil];    
}

- (void)productsRequest:(SKProductsRequest *)request didFailWithError:(SKProductsResponse *) 
    response {
    
    NSLog(@"Hubo un error...");
    
}

- (void)provideContent:(NSString *)productIdentifier {
    
    NSLog(@"Toggling flag for: %@", productIdentifier);
    
    [[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:productIdentifier];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [_purchasedProducts addObject:productIdentifier];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kProductPurchasedNotification object:productIdentifier];
    
}

- (void)completeTransaction:(SKPaymentTransaction *)transaction {
    
    NSLog(@"completeTransaction...");
    
    [self provideContent: transaction.payment.productIdentifier];
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
    
}

- (void)restoreTransaction:(SKPaymentTransaction *)transaction {
    
    NSLog(@"restoreTransaction...");
    
    [self provideContent: transaction.originalTransaction.payment.productIdentifier];
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
    
}

- (void)failedTransaction:(SKPaymentTransaction *)transaction {
    
    if (transaction.error.code != SKErrorPaymentCancelled)
    {
        NSLog(@"Transaction error: %@", transaction.error.localizedDescription);
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kProductPurchaseFailedNotification object:transaction];
    
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
    
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    for (SKPaymentTransaction *transaction in transactions)
    {
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchased:
                [self completeTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                [self failedTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:
                [self restoreTransaction:transaction];
            default:
                break;
        }
    }
}

- (void)buyProductIdentifier:(NSString *)productIdentifier {
    
    NSLog(@"Buying %@...", productIdentifier);
    
    SKPayment *payment = [SKPayment paymentWithProductIdentifier:productIdentifier];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
    
}

- (void)dealloc
{;
    _productIdentifiers = nil;
    _products = nil;
    _purchasedProducts = nil;
    _request = nil;
}

@end
