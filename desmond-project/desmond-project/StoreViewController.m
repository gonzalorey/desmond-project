//
//  StoreViewController.m
//  desmond-project
//
//  Created by Gonzalo Rey on 6/10/12.
//  Copyright (c) 2012 OLX. All rights reserved.
//

#import "StoreViewController.h"

@implementation StoreViewController

@synthesize inAppPurchasesTableView = _inAppPurchasesTableView, iapHelper = _iapHelper;

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
    
    NSSet *productIdentifiers = [NSSet setWithObjects: 
                                 @"com.igvsoft.desmondproject.1reminder", 
                                 nil];
    
    self.iapHelper = [[IAPHelper alloc] initWithProductIdentifiers:productIdentifiers];
    
    if(self.iapHelper.products == nil) {
        [self.iapHelper requestProducts];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadTableView) name:kProductsLoadedNotification object:nil];
}

- (void)loadTableView
{
    // Initialization of the tableView
    UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.frame
                                                          style:UITableViewStylePlain];
    tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    tableView.delegate = self;
    tableView.dataSource = self;
    [tableView reloadData];
    
    [self.view addSubview:tableView];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{    
    NSLog(@"COUNT:%d", [self.iapHelper.products count]);
    return [self.iapHelper.products count];
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
    SKProduct *product = [self.iapHelper.products objectAtIndex:indexPath.row];
    
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
    
    if ([self.iapHelper.purchasedProducts containsObject:product.productIdentifier]) {
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

@end
