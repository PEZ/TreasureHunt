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
@synthesize pdfWebView = _pdfWebView;
@synthesize toolbar = _toolbar;
@synthesize doneButton = _doneButton;
@synthesize printButton = _printButton;
@synthesize emailButton = _emailButton;
@synthesize toolbarSpacer = _toolbarSpacer;
@synthesize paperSize = _paperSize;
@synthesize pdfFilePath = _pdfFilePath;

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
    NSMutableArray *toolbarItems = [NSMutableArray arrayWithArray:_toolbar.items];
    if (![UIPrintInteractionController isPrintingAvailable]) {
        [toolbarItems removeObject:_printButton];
    }
    _toolbar.items = toolbarItems;
    _printButton.enabled = NO;
    _emailButton.enabled = NO;
    [[[THPDFGenerator alloc] init] generatePDFForHunt:_hunt withPageSize:_paperSize andDelegate:self];
}

- (void)viewDidUnload
{
    self.pdfWebView = nil;
    self.doneButton = nil;
    self.printButton = nil;
    self.hunt = nil;
    self.pdfFilePath = nil;
    [self setEmailButton:nil];
    [self setToolbarSpacer:nil];
    [self setToolbar:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)loadDocument:(NSString*)filePath inView:(UIWebView*)webView
{
    NSURL *targetURL = [NSURL fileURLWithPath:filePath];
    NSURLRequest *request = [NSURLRequest requestWithURL:targetURL];
    [webView loadRequest:request];
    _printButton.enabled = YES;
    _emailButton.enabled = YES;
}

- (void)PDFGenerated:(NSString*)pdfFilePath
{
    _pdfFilePath = pdfFilePath;
    [self loadDocument:pdfFilePath inView:self.pdfWebView];
    
    //UIDocumentInteractionController *document = [UIDocumentInteractionController interactionControllerWithURL: targetURL];
    //document.delegate = self;
    //[document presentPreviewAnimated:YES];
}

- (IBAction)doneButtonPressed:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)printButtonPressed:(id)sender {
    UIPrintInteractionController *controller = [UIPrintInteractionController sharedPrintController];
    controller.delegate = self;
    controller.printingItem = [NSURL fileURLWithPath:_pdfFilePath];
    controller.showsPageRange = YES;
    UIPrintInfo *printInfo = [UIPrintInfo printInfo];
    printInfo.outputType = UIPrintInfoOutputGeneral;
    printInfo.jobName = [_pdfFilePath lastPathComponent];
    printInfo.duplex = UIPrintInfoDuplexNone;
    controller.printInfo = printInfo;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [controller presentFromBarButtonItem:self.printButton animated:YES
                           completionHandler:nil];
    } else {
        [controller presentAnimated:YES completionHandler:nil];
    }
}

#pragma mark - UIPrintInteractionControllerDelegate

- (UIPrintPaper *)printInteractionController:(UIPrintInteractionController *)pic
                                 choosePaper:(NSArray *)paperList {
    return [UIPrintPaper bestPaperForPageSize:self.paperSize
                          withPapersFromArray:paperList];
}
@end
