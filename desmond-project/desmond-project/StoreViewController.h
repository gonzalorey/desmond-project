//
//  StoreViewController.h
//  desmond-project
//
//  Created by Gonzalo Rey on 6/10/12.
//  Copyright (c) 2012 OLX. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IAPHelper.h"
#import "ViewController.h"

@interface StoreViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
{
    UITableView * _inAppPurchasesTableView;
    IAPHelper * _iapHelper;
    IBOutlet UITableView *uiTableView;
    ViewController *delegate;
}

@property (nonatomic, retain) IBOutlet UITableView *inAppPurchasesTableView;
@property (nonatomic, retain) IAPHelper *iapHelper;
@property (nonatomic, retain) ViewController *delegate;


@end
