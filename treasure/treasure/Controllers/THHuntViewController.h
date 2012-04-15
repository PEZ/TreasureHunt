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

@class THHuntViewController;

@protocol THEditHuntDelegate <NSObject>
- (void)huntEdited:(THHunt*)hunt;
@end

@interface THHuntViewController : UITableViewController <UITextFieldDelegate,
NSFetchedResultsControllerDelegate, THEditCheckpointDelegate>

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (strong, nonatomic) id<THEditHuntDelegate> delegate;
@property (strong, nonatomic) THHunt* hunt;
@property (strong, nonatomic) IBOutlet UITextField *nameTextField;

@end
