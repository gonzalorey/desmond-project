//
//  ViewController.h
//  desmond-project
//
//  Created by David Grandes on 6/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GameKit/GameKit.h>
#import "IAPHelper.h"

@interface ViewController : UIViewController<UIAlertViewDelegate, GKLeaderboardViewControllerDelegate, UITextFieldDelegate>{

    IBOutlet UILabel * countdownLabel;
    IBOutlet UITextField * codeTextField;
    IBOutlet UILabel *codeLabel;
    IBOutlet UILabel *codeNameLabel;
    IBOutlet UILabel * topMessage;
    IBOutlet UILabel * promptLabel;
    IBOutlet UILabel * scoreLabel;
    NSDate * countdownDate;
    int levelsPassed;
    int clearanceCode;
    NSTimer * timer;
    Boolean resetViewShown;
    CGPoint codeTextFieldOriginalPosition;
    CGPoint codeLabelOriginalPosition;
    CGPoint codeNameLabelOriginalPosition;
}

@property(nonatomic, retain) UILabel * countdownLabel;
@property(nonatomic, retain) UITextField * codeTextField;
@property(nonatomic, retain) NSDate * countdownDate;
@property(nonatomic, assign) int levelsPassed;
@property(nonatomic, retain) NSTimer* timer;
@property(nonatomic, assign) Boolean resetViewShown;
@property(nonatomic, retain) UILabel *codeLabel;
@property(nonatomic, retain) UILabel *codeNameLabel;
@property(nonatomic, retain) UILabel *topMessage;
@property(nonatomic, retain) UILabel *promptLabel;
@property(nonatomic, retain) UILabel *scoreLabel;
@property(nonatomic, assign) int clearanceCode;

-(void)establishCountdown;
-(NSTimeInterval)generateNextRandomInterval;
-(void)updateCountdownLabel;
-(void)saveUserPreferences;
-(void)generateCode;
-(void)retrieveUserPreferences;
-(void)endTheWorld;
-(void)showResults;
-(void)resetData;
-(void)enableTextField:(NSTimeInterval)time;
-(Boolean)checkCode;
-(void)nextLevel;
-(void) reportScore: (int64_t) score forCategory: (NSString*) category;
@end
