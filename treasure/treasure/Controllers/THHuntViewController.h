//
//  THDetailViewController.h
//  treasure
//
//  Created by Peter Stromberg on 2012-04-08.
//  Copyright (c) 2012 NA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Hunt.h"

@class THHuntViewController;

@protocol THEditHuntDelegate <NSObject>
- (void)huntEdited:(Hunt*)hunt;
@end

@interface THHuntViewController : UITableViewController <UITextFieldDelegate>

@property (strong, nonatomic) id<THEditHuntDelegate> delegate;
@property (strong, nonatomic) Hunt* hunt;
@property (strong, nonatomic) IBOutlet UITextField *nameTextField;

@end
