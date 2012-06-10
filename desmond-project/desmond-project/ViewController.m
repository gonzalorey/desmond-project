//
//  ViewController.m
//  desmond-project
//
//  Created by David Grandes on 6/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController

@synthesize  countdownLabel, codeTextField, countdownDate, levelsPassed, timer;

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
            [self saveUserPreferences];
            self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateCountdownLabel) userInfo:nil repeats:YES];
        }
}

-(void)updateCountdownLabel{
    
    NSDate * nowDate = [NSDate dateWithTimeIntervalSinceNow:0];
    NSCalendar *sysCalendar = [NSCalendar currentCalendar];
    unsigned int unitFlags = NSSecondCalendarUnit| NSHourCalendarUnit | NSMinuteCalendarUnit | NSDayCalendarUnit | NSMonthCalendarUnit;

    
    NSDateComponents *conversionInfo = [sysCalendar components:unitFlags fromDate:nowDate  toDate:self.countdownDate  options:0];
    
    NSString* formattedDate = [NSString stringWithFormat:@"%02d:%02d:%02d", [conversionInfo hour], [conversionInfo minute], 
                               [conversionInfo second]];
    
    self.countdownLabel.text = formattedDate;
}

-(NSTimeInterval)generateNextRandomInterval{
    int x = arc4random() % 100;
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

@end
