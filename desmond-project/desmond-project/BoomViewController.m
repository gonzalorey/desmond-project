//
//  BoomViewController.m
//  desmond-project
//
//  Created by David Grandes on 6/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BoomViewController.h"

@implementation BoomViewController

@synthesize skull, funnyMessage;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self fadeInSkull];
    self.funnyMessage.text = [self getRandomFunnyMessage];
}

-(NSString*)getRandomFunnyMessage{
    NSMutableArray* messages = [[NSMutableArray alloc] initWithObjects:@"Justin Bieber will never sing again :(!",@"You have killed all the remaining Pandas", @"Are you a celebrating Mayan?", @"What about global warming and climate change?",@"You did not use enough duck tape",@"You won't get to see The Hobbit now",@"That's for mixing diet coke and mentos", nil];
    int size = [messages count];
    int index = arc4random() % size;
    return [messages objectAtIndex:index];
}

-(void)fadeInSkull{
    // instantaneously make the image view small (scaled to 1% of its actual size)
    skull.alpha = 0;
    [UIView animateWithDuration:2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        // animate it to the identity transform (100% scale)
        skull.alpha = 0.5;
    } completion:^(BOOL finished){
        // if you want to do something once the animation finishes, put it here

    }];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)imageTapped:(UITapGestureRecognizer *)sender{
    [self dismissModalViewControllerAnimated:NO];
}
@end
