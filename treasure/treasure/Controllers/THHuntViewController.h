//
//  THDetailViewController.h
//  treasure
//
//  Created by Peter Stromberg on 2012-04-08.
//  Copyright (c) 2012 NA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "THHunt.h"
#import "THCheckpointViewController.h"
#import "THSparePartsViewController.h"

@class THHuntViewController;

@protocol THEditHuntDelegate <NSObject>
- (void)huntEdited:(THHunt*)hunt;
@end

@interface THHuntViewController : UITableViewController <UITextFieldDelegate, THEditCheckpointDelegate, UIActionSheetDelegate> {
    @private
    THCheckpointCell *_measurementCell;
    THSparePartsViewController *_sparePartsViewController;
    BOOL _isReordering;
}

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (strong, nonatomic) id<THEditHuntDelegate> delegate;
@property (strong, nonatomic) THHunt* hunt;
@property (strong, nonatomic) IBOutlet UITextField *titleTextField;
@property (strong, nonatomic) IBOutlet UIButton *reorderButton;

- (IBAction)generateButtonPressed:(id)sender;
- (IBAction)reorderButtonPressed:(id)sender;

@end
