//
//  ViewController.m
//  desmond-project
//
//  Created by David Grandes on 6/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"
#import "IAPHelper.h"
#import "config.h"
#import "WelcomeViewController.h"
#import "StoreViewController.h"

@implementation ViewController

@synthesize  countdownLabel, codeTextField, countdownDate, levelsPassed, timer, resetViewShown, codeLabel, codeNameLabel, clearanceCode, promptLabel, topMessage, scoreLabel;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle


- (void)keyboardWillHide:(NSNotification *)n
{    
    NSDictionary* userInfo = [n userInfo];
    
    CGSize keyboardSize = [[userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    int slideAmount = keyboardSize.height/2;
    
    CGRect codeLabelFrame = self.codeLabel.frame;
    CGRect codeNameLabelFrame = self.codeNameLabel.frame;
    CGRect topMessageLabelFrame = self.topMessage.frame;
    CGRect promptLabelFrame = self.promptLabel.frame;
    CGRect countDownLabelFrame = self.countdownLabel.frame;
    CGRect codeTextFieldFrame = self.codeTextField.frame;
    
    codeLabelFrame.origin.y += slideAmount;
    codeNameLabelFrame.origin.y += slideAmount;
    topMessageLabelFrame.origin.y += slideAmount;
    promptLabelFrame.origin.y += slideAmount;
    countDownLabelFrame.origin.y += slideAmount;
    codeTextFieldFrame.origin.y += slideAmount;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:0.3];
    [self.codeTextField setFrame:codeTextFieldFrame];
    [self.codeLabel setFrame:codeLabelFrame];
    [self.codeNameLabel setFrame:codeNameLabelFrame];
    [self.topMessage setFrame:topMessageLabelFrame];
    [self.promptLabel setFrame:promptLabelFrame];
    [self.countdownLabel setFrame:countDownLabelFrame];
    [UIView commitAnimations];
}


- (void)keyboardWillShow:(NSNotification *)n
{   
    NSDictionary* userInfo = [n userInfo];

    CGSize keyboardSize = [[userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    int slideAmount = keyboardSize.height/2;

    
    CGRect codeLabelFrame = self.codeLabel.frame;
    CGRect codeNameLabelFrame = self.codeNameLabel.frame;
    CGRect topMessageLabelFrame = self.topMessage.frame;
    CGRect promptLabelFrame = self.promptLabel.frame;
    CGRect countDownLabelFrame = self.countdownLabel.frame;
    CGRect codeTextFieldFrame = self.codeTextField.frame;
    
    codeLabelFrame.origin.y -= slideAmount;
    codeNameLabelFrame.origin.y -= slideAmount;
    topMessageLabelFrame.origin.y -= slideAmount;
    promptLabelFrame.origin.y -= slideAmount;
    countDownLabelFrame.origin.y -= slideAmount;
    codeTextFieldFrame.origin.y -= slideAmount;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:0.3];
    [self.codeTextField setFrame:codeTextFieldFrame];
    [self.codeLabel setFrame:codeLabelFrame];
    [self.codeNameLabel setFrame:codeNameLabelFrame];
    [self.topMessage setFrame:topMessageLabelFrame];
    [self.promptLabel setFrame:promptLabelFrame];
    [self.countdownLabel setFrame:countDownLabelFrame];
    [UIView commitAnimations];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.codeTextField resignFirstResponder];
    if([self checkCode])
        [self nextLevel];
    else
        [self endTheWorld];
    return YES;
}

-(Boolean)checkCode{
    return [self.codeLabel.text isEqualToString:self.codeTextField.text];
}

-(void)nextLevel{
    self.levelsPassed = self.levelsPassed + 1;
    self.scoreLabel.text = [NSString stringWithFormat:@"%d",self.levelsPassed];
    self.countdownDate = nil;
    self.codeTextField.text = @"";
    [self saveUserPreferences];
    [self establishCountdown];
    
    int prevHighScore = [[NSUserDefaults standardUserDefaults] integerForKey:@"DesmondHighScore"];
    
    if (self.levelsPassed > prevHighScore) {
        [[NSUserDefaults standardUserDefaults] setInteger:self.levelsPassed forKey:@"DesmondHighScore"];
        [self reportScore:self.levelsPassed forCategory:@"com.igvsoft.desmondproject.savedworldleaderboard"];
    }
    
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.codeTextField.text = @"";
    // Dismiss the keyboard when the view outside the text field is touched.
    [self.codeTextField resignFirstResponder];
    [super touchesBegan:touches withEvent:event];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    //[[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"intervalDate"];
    
    [self retrieveUserPreferences];
    
    self.scoreLabel.text = [NSString stringWithFormat:@"%d",self.levelsPassed];
    self.codeLabel.text = [NSString stringWithFormat:@"%d", self.clearanceCode];
    
    self.codeTextField.clearsOnBeginEditing = YES;

	// Do any additional setup after loading the view, typically from a nib.
    // register for keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(keyboardWillShow:) 
                                                 name:UIKeyboardWillShowNotification 
                                               object:self.view.window];
    // register for keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(keyboardWillHide:) 
                                                 name:UIKeyboardWillHideNotification 
                                               object:self.view.window];
    
    codeTextFieldOriginalPosition = self.codeTextField.frame.origin;
    codeLabelOriginalPosition = self.codeLabel.frame.origin;
    codeNameLabelOriginalPosition = self.codeNameLabel.frame.origin;
}

- (void)viewDidUnload
{
    codeLabel = nil;
    codeNameLabel = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    [self.timer invalidate];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                    name:UIKeyboardWillShowNotification 
                                                  object:nil]; 
    // unregister for keyboard notifications while not visible.
    [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                    name:UIKeyboardWillHideNotification 
                                                  object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                    name:UIKeyboardWillShowNotification 
                                                  object:nil]; 
    // unregister for keyboard notifications while not visible.
    [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                    name:UIKeyboardWillHideNotification 
                                                  object:nil];

}

-(void)showWelcomeScreen{
    WelcomeViewController * wel = [[WelcomeViewController alloc] initWithNibName:@"WelcomeViewController" bundle:nil];
    wel.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    wel.delegate = self;
    
    [self presentModalViewController:wel animated:NO];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (!self.countdownDate) {
        //show Welcome screen
        [self showWelcomeScreen];
    }else {
        [self establishCountdown];
    }
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
                [self generateCode];
                self.countdownDate = [NSDate dateWithTimeIntervalSinceNow:interval];

                
            }
            [self saveUserPreferences];

        }
    
    [self updateCountdownLabel];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateCountdownLabel) userInfo:nil repeats:YES];
}

-(void)generateCode{
    self.clearanceCode = arc4random() %10000000;
    self.clearanceCode = abs(self.clearanceCode);
    self.codeLabel.text = [NSString stringWithFormat:@"%d", self.clearanceCode];
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
    }else
        [self enableTextField:interval];
    
    NSDateComponents *conversionInfo = [sysCalendar components:unitFlags fromDate:nowDate  toDate:self.countdownDate  options:0];
    

    NSString* formattedDate = [NSString stringWithFormat:@"%02d:%02d:%02d", [conversionInfo hour], [conversionInfo minute], 
                               [conversionInfo second]];
    
    self.countdownLabel.text = formattedDate;
}

-(void)enableTextField:(NSTimeInterval)time{
        if(time < INPUT_WINDOW)
        {
            [self.codeTextField setAlpha:1.0];
            [self.codeTextField setEnabled:TRUE];   
        }
        else{
            [self.codeTextField setAlpha:0.0];
            [self.codeTextField setEnabled:FALSE];
        }
}

-(void)endTheWorld
{
    self.countdownLabel.text = @"BOOM";
    [self showResults];
    self.countdownDate = nil;
    [self saveUserPreferences];
}

-(void)showResults{
    if(!self.resetViewShown){
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Oh No!" message:@"The world is over!" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [alert show];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    self.codeTextField.text = @"";
    [self resetData];
    [self showWelcomeScreen];
}

- (void)willPresentAlertView:(UIAlertView *)alertView
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
    
    self.scoreLabel.text = [NSString stringWithFormat:@"%d",self.levelsPassed];
}

-(NSTimeInterval)generateNextRandomInterval{
    int offset;
    
    if (self.levelsPassed < LEVELS_UNDER_FIVE_MIN) {
        offset = FIVE_MIN;
    }else if (self.levelsPassed <= LEVELS_UNDER_HOUR) {
       offset = ONE_HOUR;
    }else {
        offset = ONE_DAY;
    }
    
    int x = (arc4random() % offset) + MINIMUM_TIME;
    return x;
}


-(void)saveUserPreferences{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    [prefs setObject:self.countdownDate forKey:@"intervalDate"];
    [prefs setInteger:self.levelsPassed forKey:@"level"];
    [prefs setInteger:self.clearanceCode forKey:@"clearCode"];
    [prefs synchronize];
}

-(void)retrieveUserPreferences{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    int level = [prefs integerForKey:@"level"];
    NSDate * date = [prefs objectForKey:@"intervalDate"];
    int clear = [prefs integerForKey:@"clearCode"];
    
    self.levelsPassed = level; 
    self.countdownDate = date;
    self.clearanceCode = clear;
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

- (void) showInAppPurchaseOptions
{
    StoreViewController *storeViewController = [[StoreViewController alloc] initWithNibName:@"StoreViewController" bundle:nil];
                                            
    if(storeViewController != Nil)
    {
        storeViewController.delegate = self;
        
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:storeViewController];
        [self presentModalViewController:nav animated:TRUE];
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

-(IBAction)showInAppPurchaseOptionsButton:(id)sender{
    [self showInAppPurchaseOptions];
}
@end
