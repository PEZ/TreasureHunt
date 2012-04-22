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
UIDocumentInteractionControllerDelegate>

@property (strong, nonatomic) THHunt *hunt;

@end
