//
//  THPDFViewController.h
//  treasure
//
//  Created by Peter Stromberg on 2012-04-22.
//  Copyright (c) 2012 NA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "THPDFGenerator.h"
#import "THHunt.h"

@interface THPDFViewController : UIViewController <THPDFGeneratorDelegate, UIActionSheetDelegate,
UIPrintInteractionControllerDelegate>

@property (strong, nonatomic) THHunt *hunt;
@property (strong, nonatomic) IBOutlet UIWebView *pdfWebView;
@property (strong, nonatomic) IBOutlet UIToolbar *toolbar;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *doneButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *printButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *emailButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *toolbarSpacer;
@property (nonatomic) CGSize paperSize;
@property (strong, nonatomic) NSString *pdfFilePath;

- (IBAction)doneButtonPressed:(id)sender;
- (IBAction)printButtonPressed:(id)sender;

@end
