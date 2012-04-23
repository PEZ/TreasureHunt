//
//  THPDFGenerator.m
//  treasure
//
//  Created by Peter Stromberg on 2012-04-22.
//  Copyright (c) 2012 NA. All rights reserved.
//

#import "THAppDelegate.h"
#import "THPDFGenerator.h"
#import "THCheckpoint.h"

@implementation THPDFGenerator

@synthesize delegate = _delegate;

+ (NSString*)filePath {
    THAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    return [[[delegate applicationDocumentsDirectory] URLByAppendingPathComponent:PDF_FILE_NAME] path];
}

- (id)initWithDelegate:(id<THPDFGeneratorDelegate>)delegate
{
    if ((self = [super init])) {
        self.delegate = delegate;
    }
    return self;
}

- (void)generatePDFForHunt:(THHunt*)hunt withPageSize:(CGSize)pageSize
{
    NSString *pdfFilePath = [THPDFGenerator filePath];
    UIImage *bgImage = [UIImage imageNamed:PDF_BG_A4];
    if (UIGraphicsBeginPDFContextToFile(pdfFilePath, CGRectMake(0, 0, pageSize.width, pageSize.height), nil)) {
        UIGraphicsBeginPDFPage();
        [bgImage drawAtPoint:CGPointMake(0, 0)];
        UIGraphicsEndPDFContext();
        [self.delegate PDFGenerated:pdfFilePath];
    }
    self.delegate = nil;
}

@end
