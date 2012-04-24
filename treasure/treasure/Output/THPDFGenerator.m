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

+ (NSString*)filePath {
    THAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    return [[[delegate applicationDocumentsDirectory] URLByAppendingPathComponent:PDF_FILE_NAME] path];
}

- (void)generatePDFForHunt:(THHunt*)hunt withPageSize:(CGSize)pageSize andDelegate:(id<THPDFGeneratorDelegate>)delegate
{
    NSString *pdfFilePath = [THPDFGenerator filePath];
    UIImage *bgImage = [UIImage imageNamed:PDF_BG_A4];
    int imageHeight = pageSize.height / 3.5;
    if (UIGraphicsBeginPDFContextToFile(pdfFilePath, CGRectMake(0, 0, pageSize.width, pageSize.height), nil)) {
        for (int i = 0, n = [hunt.checkpoints count]; i < n; i++) {
            if (i % 4 == 0) {
                UIGraphicsBeginPDFPage();
                [bgImage drawAtPoint:CGPointMake(0, 0)];
            }
            int center_x = pageSize.width / 4 + (i % 2) * pageSize.width / 2;
            int center_y = pageSize.height / 4 + ((i % 4 < 2) ? 0 : 1) * pageSize.height / 2;
            int ix = center_x - imageHeight / 2;
            int iy = center_y - imageHeight / 2;

            THCheckpoint *checkpoint = [hunt.checkpoints objectAtIndex:i];
            if (checkpoint.textClue && [checkpoint.textClue length] > 0) {
                iy -= imageHeight / 6;
            }
            [checkpoint.imageClue drawInRect:CGRectMake(ix, iy, imageHeight, imageHeight)];
        }
        UIGraphicsEndPDFContext();
        [delegate PDFGenerated:pdfFilePath];
    }
}

@end
