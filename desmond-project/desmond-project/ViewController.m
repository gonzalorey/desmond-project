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

@synthesize  countdownLabel, codeTextField, countdownDate, levelsPassed, timer, resetViewShown, codeLabel, codeNameLabel, iaph = _iaph;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle


- (void)keyboardWillHide:(NSNotification *)n
{    
    CGRect codeTextFieldFrame = self.codeTextField.frame;
    CGRect codeLabelFrame = self.codeLabel.frame;
    CGRect codeNameLabelFrame = self.codeNameLabel.frame;
    
    codeTextFieldFrame.origin = codeTextFieldOriginalPosition;
    codeLabelFrame.origin = codeLabelOriginalPosition;
    codeNameLabelFrame.origin = codeNameLabelOriginalPosition;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    // The kKeyboardAnimationDuration I am using is 0.3
    [UIView setAnimationDuration:0.3];
    [self.codeTextField setFrame:codeTextFieldFrame];
    [self.codeLabel setFrame:codeLabelFrame];
    [self.codeNameLabel setFrame:codeNameLabelFrame];
    [UIView commitAnimations];
}

//- (void) printElement:(UIView *)v
//{
//    NSLog(@"%@ frame size: %@, origin: %@", v, NSStringFromCGSize(v.frame.size), NSStringFromCGPoint(v.frame.origin));
//}

- (void)keyboardWillShow:(NSNotification *)n
{   
    NSDictionary* userInfo = [n userInfo];

//    // get the size of the keyboard
    CGSize keyboardSize = [[userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
//    CGPoint keyboardOrigin = CGPointMake(0, 216);

    CGRect codeTextFieldFrame = self.codeTextField.frame;

//    NSLog(@"keyboard size: %@, origin: %@", NSStringFromCGSize(keyboardSize), NSStringFromCGPoint(keyboardOrigin));
    
    codeTextFieldFrame.origin.y = keyboardSize.height-codeTextFieldFrame.size.height;
    
    CGRect codeLabelFrame = self.codeLabel.frame;
    CGRect codeNameLabelFrame = self.codeNameLabel.frame;
    
    codeLabelFrame.origin.y = codeTextFieldFrame.origin.y - codeLabelFrame.size.height;
    codeNameLabelFrame.origin.y = codeLabelFrame.origin.y;
//    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:0.3];
    [self.codeTextField setFrame:codeTextFieldFrame];
    [self.codeLabel setFrame:codeLabelFrame];
    [self.codeNameLabel setFrame:codeNameLabelFrame];
    [UIView commitAnimations];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.codeTextField resignFirstResponder];
    
    return YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    // Dismiss the keyboard when the view outside the text field is touched.
    [self.codeTextField resignFirstResponder];
    [super touchesBegan:touches withEvent:event];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self establishCountdown];
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
    self.countdownDate = nil;
    [self saveUserPreferences];
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
