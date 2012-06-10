//
//  ViewController.h
//  desmond-project
//
//  Created by David Grandes on 6/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController{

    IBOutlet UILabel * countdownLabel;
    IBOutlet UITextField * codeTextField;
}

@property(nonatomic, retain) UILabel * countdownLabel;
@property(nonatomic, retain) UITextField * codeTextField;

@end
