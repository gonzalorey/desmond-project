//
//  WelcomeViewController.h
//  desmond-project
//
//  Created by ign on 6/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GameKit/GameKit.h>
#import "ViewController.h"

@interface WelcomeViewController : UIViewController<GKLeaderboardViewControllerDelegate>{
    IBOutlet UILabel * highScoreLabel;
    
    ViewController * _delegate;
}

@property(nonatomic, retain) ViewController * delegate;

-(void)designButtons;
@end
