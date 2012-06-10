//
//  BoomViewController.h
//  desmond-project
//
//  Created by David Grandes on 6/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface BoomViewController : UIViewController{
    IBOutlet UIImageView * skull;
    IBOutlet UILabel * funnyMessage;
}

@property(nonatomic, retain) IBOutlet UIImageView * skull;
@property(nonatomic, retain) IBOutlet UILabel * funnyMessage;
-(void)fadeInSkull;
-(IBAction)imageTapped:(UITapGestureRecognizer *)sender;
-(NSString*)getRandomFunnyMessage;
@end
