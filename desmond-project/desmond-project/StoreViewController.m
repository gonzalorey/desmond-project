//
//  StoreViewController.m
//  desmond-project
//
//  Created by Gonzalo Rey on 6/10/12.
//  Copyright (c) 2012 OLX. All rights reserved.
//

#import "StoreViewController.h"

@implementation StoreViewController

@synthesize inAppPurchasesTableView = _inAppPurchasesTableView, delegate;

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
    
    [uiTableView reloadData];    
    
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
//	// Try to retrieve from the table view a now-unused cell with the given identifier.
//	UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:MyIdentifier];
//	
//	// If no cell is available, create a new one using the given identifier.
//	if (cell == nil) {
//		// Use the default cell style.
//		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MyIdentifier];
//	}
//	
    
    // Cells population
    NSLog(@"y??? Que pasa?!?!?");
    
    static NSString *MyIdentifier = @"MyIdentifier";
	
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MyIdentifier];
    }
    
//    cell.textLabel.text = @"SARASA";
    
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
    
    cell.textLabel.text = product.localizedTitle;
    cell.detailTextLabel.text = formattedString;
    
    if ([[IAPHelper sharedHelper].purchasedProducts containsObject:product.productIdentifier]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        cell.accessoryView = nil;
    } else {        
        UIButton *buyButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        buyButton.frame = CGRectMake(0, 0, 72, 37);
        [buyButton setTitle:@"Buy" forState:UIControlStateNormal];
        buyButton.tag = indexPath.row;
        [buyButton addTarget:self action:@selector(buyButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.accessoryView = buyButton;     
    }	
    
    return cell;
}

- (IBAction)buyButtonTapped:(id)sender {
    
    UIButton *buyButton = (UIButton *)sender;    
    SKProduct *product = [[IAPHelper sharedHelper].products objectAtIndex:buyButton.tag];
    
    NSLog(@"Buying %@...", product.productIdentifier);
    [[IAPHelper sharedHelper] buyProductIdentifier:product.productIdentifier];
}

@end
