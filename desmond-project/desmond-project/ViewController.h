//
//  ViewController.h
//  desmond-project
//
//  Created by David Grandes on 6/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController<UIAlertViewDelegate>{

    IBOutlet UILabel * countdownLabel;
    IBOutlet UITextField * codeTextField;
    NSDate * countdownDate;
    int levelsPassed;
    NSTimer * timer;
    Boolean resetViewShown;
}

@property(nonatomic, retain) UILabel * countdownLabel;
@property(nonatomic, retain) UITextField * codeTextField;
@property(nonatomic, retain) NSDate * countdownDate;
@property(nonatomic, assign) int levelsPassed;
@property(nonatomic, retain) NSTimer* timer;
@property(nonatomic, assign) Boolean resetViewShown;

-(void)establishCountdown;
-(NSTimeInterval)generateNextRandomInterval;
-(void)updateCountdownLabel;
-(void)saveUserPreferences;
-(void)retrieveUserPreferences;
-(void)endTheWorld;
-(void)showResults;
-(void)resetData;
@end
