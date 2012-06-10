//
//  WelcomeViewController.m
//  desmond-project
//
//  Created by ign on 6/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "WelcomeViewController.h"

@interface WelcomeViewController (){
    IBOutlet UIButton * saveTheWorldButton;
}

@property (nonatomic, retain) IBOutlet UIButton * saveTheWorldButton;
@end

@implementation WelcomeViewController

@synthesize delegate = _delegate, saveTheWorldButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    int highScore = [[NSUserDefaults standardUserDefaults] integerForKey:@"DesmondHighScore"];
    
    highScoreLabel.text = [NSString stringWithFormat:@"%d",highScore];
    [self designButtons];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void) showLeaderboard
{
    GKLeaderboardViewController *leaderboardController = [[GKLeaderboardViewController alloc] init];
    if (leaderboardController != nil)
    {
        leaderboardController.leaderboardDelegate = self;
        [self presentModalViewController: leaderboardController animated: YES];
    }
}

- (void)leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController
{
    [self dismissModalViewControllerAnimated:YES];
}

-(IBAction)showLeaderboardButton:(id)sender{
    [self showLeaderboard];
}

-(IBAction)startGame:(id)sender{
    [self.delegate establishCountdown];
    [self.delegate dismissModalViewControllerAnimated:YES];
}

-(void)designButtons{
    UIImage *buttonImage = [[UIImage imageNamed:@"blackButton.png"]
                            resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
    UIImage *buttonImageHighlight = [[UIImage imageNamed:@"blackButtonHighlight.png"]
                                     resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
    // Set the background for any states you plan to use
    [self.saveTheWorldButton setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [self.saveTheWorldButton setBackgroundImage:buttonImageHighlight forState:UIControlStateHighlighted];
    
}


@end
