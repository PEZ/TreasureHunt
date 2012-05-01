//
//  THPDFViewController.m
//  treasure
//
//  Created by Peter Stromberg on 2012-04-22.
//  Copyright (c) 2012 NA. All rights reserved.
//

#import "THPDFViewController.h"
#import "ALToastView.h"

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
    if (![MFMailComposeViewController canSendMail]) {
        [toolbarItems removeObject:_emailButton];
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
}

- (void)showToastWithMessage:(NSString*)message
{
    [ALToastView toastInView:self.view withText:message];    
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

- (IBAction)emailButtonPressed:(id)sender {
    MFMailComposeViewController *controller = [[MFMailComposeViewController alloc] init];
    
    [controller setSubject:[NSString stringWithFormat:@"Trail of Clues PDF: %@", _hunt.title]];
    [controller addAttachmentData:[NSData dataWithContentsOfFile:_pdfFilePath]
                         mimeType:@"application/pdf"
                         fileName:[NSString stringWithFormat:@"Trail of Clues - %@.pdf", _hunt.title]];
    [controller setMessageBody:@"Print it and enjoy!" isHTML:NO];
    
    controller.mailComposeDelegate = self;
    [self presentModalViewController:controller animated:YES];
}

#pragma mark - UIPrintInteractionControllerDelegate

- (UIPrintPaper *)printInteractionController:(UIPrintInteractionController *)pic
                                 choosePaper:(NSArray *)paperList {
    return [UIPrintPaper bestPaperForPageSize:self.paperSize
                          withPapersFromArray:paperList];
}


#pragma mark - MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    [controller dismissModalViewControllerAnimated:YES];
    if (result == MFMailComposeResultSent) {
        [self performSelector:@selector(showToastWithMessage:) withObject:@"E-mail message queued successfully" afterDelay:0.5];
    }
    else if (result == MFMailComposeResultFailed) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error sending e-mail"
                                                        message:[error localizedDescription]
                                                       delegate:nil
                                              cancelButtonTitle:nil
                                              otherButtonTitles:@"OK", nil];
        [alert show];
    }
}

@end
