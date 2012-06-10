//
//  StoreCell.h
//  desmond-project
//
//  Created by ign on 6/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StoreCell : UITableViewCell{
    IBOutlet UILabel * reminderNumberLabel;
    IBOutlet UIButton * buyButton;
}

@property(nonatomic,retain) IBOutlet UILabel * reminderNumberLabel;
@property(nonatomic,retain) IBOutlet UIButton * buyButton;

@end
