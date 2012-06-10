//
//  StoreViewController.m
//  desmond-project
//
//  Created by Gonzalo Rey on 6/10/12.
//  Copyright (c) 2012 OLX. All rights reserved.
//

#import "StoreViewController.h"
#import "MBProgressHUD.h"
#import "StoreCell.h"

@implementation StoreViewController

@synthesize inAppPurchasesTableView = _inAppPurchasesTableView, delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        cellLoader = [UINib nibWithNibName:@"StoreCell" bundle:[NSBundle mainBundle]];
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
    
    if([IAPHelper sharedHelper].products == nil) {
        [[IAPHelper sharedHelper] requestProducts:self.view];
    }
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismiss)];
    
    self.navigationItem.leftBarButtonItem = backButton;
    
    self.title = @"Store";
    
    // Set the notification to be triggered after the products were loaded
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadTableView) name:kProductsLoadedNotification object:nil];
    
    // Set the notifications to be triggered after a buy event
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(productPurchased:) name:kProductPurchasedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector: @selector(productPurchaseFailed:) name:kProductPurchaseFailedNotification object: nil];
}

- (void)dismiss
{
    [self.delegate dismissModalViewControllerAnimated:TRUE];
}

- (void)loadTableView
{
    [uiTableView reloadData];    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)productPurchased:(NSNotification *)notification {
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    
    NSString *productIdentifier = (NSString *) notification.object;
    NSLog(@"Purchased: %@", productIdentifier);
    
    int totalReminders = [[NSUserDefaults standardUserDefaults] integerForKey:@"totalReminders"];
    
    // Parse the purchased remainders from the response
    NSArray *tokens = [productIdentifier componentsSeparatedByString: @"."];
    totalReminders += [[tokens objectAtIndex:[tokens count] - 1] intValue];
    
    // Save it on the NSUserDefaults
    [[NSUserDefaults standardUserDefaults] setInteger:totalReminders forKey:@"totalReminders"];    
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    // Set a notification
    [[NSNotificationCenter defaultCenter] postNotificationName:kProductPurchaseRemaindersAmount object:nil];
    
    [uiTableView reloadData];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success!" 
                                                    message:@"You successfully purchased the reminders" 
                                                   delegate:nil 
                                          cancelButtonTitle:nil 
                                          otherButtonTitles:@"OK", nil];
    
    [alert show];
    
    [MBProgressHUD hideWaitAlertInView:self.view];
    
}

- (void)productPurchaseFailed:(NSNotification *)notification {
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    
    SKPaymentTransaction * transaction = (SKPaymentTransaction *) notification.object;    
    if (transaction.error.code != SKErrorPaymentCancelled) {    
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error!" 
                                                         message:transaction.error.localizedDescription 
                                                        delegate:nil 
                                               cancelButtonTitle:nil 
                                               otherButtonTitles:@"OK", nil];
        
        [alert show];
    }
    
    [MBProgressHUD hideWaitAlertInView:self.view];
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{    
    NSLog(@"COUNT:%d", [[IAPHelper sharedHelper].products count]);
    return [[IAPHelper sharedHelper].products count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{	
    // Cells population
    StoreCell *cell = (StoreCell *)[tableView dequeueReusableCellWithIdentifier:@"StoreCell"];
    if (!cell)
    {
        NSArray *topLevelItems = [cellLoader instantiateWithOwner:self options:nil];
        cell = [topLevelItems objectAtIndex:0];
    }
    
    // Set up the cell.
    SKProduct *product = [[IAPHelper sharedHelper].products objectAtIndex:indexPath.row];
    
//    NSLog(@"Product title: %@" , p.localizedTitle);
//    NSLog(@"Product description: %@" , p.localizedDescription);
//    NSLog(@"Product price: %@" , [self localizedPrice:p.price inLocale:p.priceLocale]);
//    NSLog(@"Product id: %@" , p.productIdentifier);

    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [numberFormatter setLocale:product.priceLocale];
    NSString *formattedString = [numberFormatter stringFromNumber:product.price];
    
    NSArray *tokens = [product.productIdentifier componentsSeparatedByString: @"."];
    
    cell.reminderNumberLabel.text = [tokens objectAtIndex:[tokens count] - 1];
    cell.buyButton.titleLabel.text = formattedString;
    [cell.buyButton setTitle:formattedString forState:UIControlStateNormal];
    [cell.buyButton setTitle:formattedString forState:UIControlStateHighlighted];
    [cell.buyButton setTitle:formattedString forState:UIControlStateSelected];
    cell.buyButton.tag = indexPath.row;
    [cell.buyButton addTarget:self action:@selector(buyButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
//    if ([[IAPHelper sharedHelper].purchasedProducts containsObject:product.productIdentifier]) {
//        cell.accessoryType = UITableViewCellAccessoryCheckmark;
//        cell.accessoryView = nil;
//    } else {        
    
//    }	
    
    return cell;
}

- (IBAction)buyButtonTapped:(id)sender {
    
    UIButton *buyButton = (UIButton *)sender;    
    SKProduct *product = [[IAPHelper sharedHelper].products objectAtIndex:buyButton.tag];
    
    [MBProgressHUD showWaitAlert:@"Loading" inView:self.view];
    
    NSLog(@"Buying %@...", product.productIdentifier);
    [[IAPHelper sharedHelper] buyProductIdentifier:product.productIdentifier];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    StoreCell * cell = (StoreCell *)[tableView cellForRowAtIndexPath:indexPath];
    
    [self buyButtonTapped:cell.buyButton];
}

@end
