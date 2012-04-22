//
//  THCheckpointViewController.h
//  treasure
//
//  Created by Peter Stromberg on 2012-04-09.
//  Copyright (c) 2012 NA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "THCheckpoint.h"
#import "THCheckpointCell.h"

@class THCheckpointViewController;

@protocol THEditCheckpointDelegate <NSObject>
- (void)checkpointEdited:(THCheckpoint*)checkpoint;
@end


@interface THCheckpointViewController : UITableViewController <UITextFieldDelegate,
UITextViewDelegate, UIActionSheetDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (strong, nonatomic) IBOutlet UISwitch *isQRSwitch;
@property (strong, nonatomic) id<THEditCheckpointDelegate> delegate;
@property (strong, nonatomic) THCheckpoint *checkpoint;
@property (strong, nonatomic) IBOutlet UITextField *titleTextField;
@property (strong, nonatomic) IBOutlet UITextView *textClueTextView;
@property (strong, nonatomic) IBOutlet UIImageView *imageClueImageView;
@property (strong, nonatomic) THCheckpointCell* checkpointCell;

- (IBAction)qrSwitchChanged:(id)sender;
- (IBAction)clueImageDoubleTapped:(UITapGestureRecognizer *)sender;

@end
