//
//  THPDFViewController.m
//  treasure
//
//  Created by Peter Stromberg on 2012-04-22.
//  Copyright (c) 2012 NA. All rights reserved.
//

#import "THPDFViewController.h"

@interface THPDFViewController ()

@end

@implementation THPDFViewController

@synthesize hunt = _hunt;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"Select paper size"
                                                       delegate:self
                                              cancelButtonTitle:nil
                                         destructiveButtonTitle:nil
                                              otherButtonTitles:@"Letter", @"A4", nil];
    [sheet showInView:self.view];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)PDFGenerated:(NSString*)pdfFilePath
{
    NSLog(@"PDF Generated: %@", pdfFilePath);
    NSURL *targetURL = [NSURL fileURLWithPath:pdfFilePath];
    
    UIDocumentInteractionController *document = [UIDocumentInteractionController interactionControllerWithURL: targetURL];
    document.delegate = self;
    [document presentPreviewAnimated:YES];
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    CGSize paperSize = buttonIndex == 0 ? PDF_PAGE_SIZE_LETTER_LANDSCAPE : PDF_PAGE_SIZE_A4_LANDSCAPE;
    THPDFGenerator *generator = [[THPDFGenerator alloc] initWithDelegate:self];
    [generator generatePDFForHunt:_hunt withPageSize:paperSize];
}

#pragma mark - UIDocumentInteractionControllerDelegate
-(UIViewController *)documentInteractionControllerViewControllerForPreview: (UIDocumentInteractionController *) controller
{
    return self;
}

@end
