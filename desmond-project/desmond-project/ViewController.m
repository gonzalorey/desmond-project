//
//  ViewController.m
//  desmond-project
//
//  Created by David Grandes on 6/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"
#import "IAPHelper.h"

@implementation ViewController

@synthesize  countdownLabel, codeTextField, countdownDate, levelsPassed, timer, resetViewShown, iaph = _iaph;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self establishCountdown];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    [self.timer invalidate];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSSet *productIdentifiers = [NSSet setWithObjects: 
                                 @"com.igvsoft.desmondproject.1reminder", 
                                 nil];
    
    self.iaph = [[IAPHelper alloc] initWithProductIdentifiers:productIdentifiers];
    
    if(self.iaph.products == nil) {
        
        NSLog(@"ABOUT TO SHOW THE STUFF...");
        
        [self.iaph requestProducts];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

-(void)establishCountdown{

        if(self.countdownDate == nil)
        {
            [self retrieveUserPreferences];
            if(self.countdownDate == nil){
                NSTimeInterval interval = [self generateNextRandomInterval];
                self.countdownDate = [NSDate dateWithTimeIntervalSinceNow:interval];
            }
            [self saveUserPreferences];
            [self updateCountdownLabel];
            self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateCountdownLabel) userInfo:nil repeats:YES];
        }
}

-(void)updateCountdownLabel{
    
    NSDate * nowDate = [NSDate dateWithTimeIntervalSinceNow:0];
    NSCalendar *sysCalendar = [NSCalendar currentCalendar];
    unsigned int unitFlags = NSSecondCalendarUnit| NSHourCalendarUnit | NSMinuteCalendarUnit | NSDayCalendarUnit | NSMonthCalendarUnit;

    NSTimeInterval interval = [self.countdownDate timeIntervalSinceDate:nowDate];
    if(interval <= 0 )
    {
        [self endTheWorld];   
        return;
    }
    
    NSDateComponents *conversionInfo = [sysCalendar components:unitFlags fromDate:nowDate  toDate:self.countdownDate  options:0];
    

    NSString* formattedDate = [NSString stringWithFormat:@"%02d:%02d:%02d", [conversionInfo hour], [conversionInfo minute], 
                               [conversionInfo second]];
    
    self.countdownLabel.text = formattedDate;
}

-(void)endTheWorld
{
    self.countdownLabel.text = @"BOOM";
    [self showResults];
}

-(void)showResults{
    if(!self.resetViewShown){
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Oh No!" message:@"The world is over!" delegate:self cancelButtonTitle:@"Restart" otherButtonTitles: nil];
        [alert show];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    [self resetData];    
}

- (void)didPresentAlertView:(UIAlertView *)alertView
{
    self.resetViewShown = true;
}
-(void)resetData
{
    self.countdownDate = nil;
    self.levelsPassed = 0;
    self.resetViewShown = false;
    [self.timer invalidate];
    [self saveUserPreferences];    
    [self establishCountdown];
}

-(NSTimeInterval)generateNextRandomInterval{
    int x = arc4random() % 15;
    return x;
}

-(void)saveUserPreferences{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    [prefs setObject:self.countdownDate forKey:@"intervalDate"];
    [prefs setInteger:self.levelsPassed forKey:@"level"];
    [prefs synchronize];
}

-(void)retrieveUserPreferences{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    int level = [prefs integerForKey:@"level"];
    NSDate * date = [prefs objectForKey:@"intervalDate"];
    
    self.levelsPassed = level; 
    self.countdownDate = date;
}

#pragma mark - GameKit

- (void) reportScore: (int64_t) score forCategory: (NSString*) category
{
    GKScore *scoreReporter = [[GKScore alloc] initWithCategory:category];
    scoreReporter.value = score;
    
    [scoreReporter reportScoreWithCompletionHandler:^(NSError *error) {
        if (error) {
            NSLog(@"Error authenticating: %@",[error localizedDescription]);
        }else {
            NSLog(@"no error");
        }
    }];
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

-(IBAction)reportScoreButton:(id)sender{
    [self reportScore:12 forCategory:@"com.igvsoft.desmondproject.savedworldleaderboard"];
}

-(IBAction)showLeaderboardButton:(id)sender{
    [self showLeaderboard];
}

@end
