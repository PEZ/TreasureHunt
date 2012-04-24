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

#define CARD_MARGIN 30

#define CLUE_NUMBER_FONT_SIZE 18
#define CLUE_NUMBER_FONT [UIFont systemFontOfSize:CLUE_NUMBER_FONT_SIZE]

#define TEXT_CLUE_FONT_SIZE 14
#define TEXT_CLUE_FONT [UIFont systemFontOfSize:TEXT_CLUE_FONT_SIZE]
#define TEXT_CLUE_MARGIN 20

#define IMAGE_SIDE_LENGTH_RATIO 1 / 3.5

@implementation THPDFGenerator

+ (NSString*)filePath {
    THAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    return [[[delegate applicationDocumentsDirectory] URLByAppendingPathComponent:PDF_FILE_NAME] path];
}

- (void)drawText:(NSString*)text withFont:(UIFont*)font andMaxSize:(CGSize)maxSize
centeredAtPoint:(CGPoint)point alsoCenterVertically:(BOOL)centerVertically
{
    CGSize textSize = [text sizeWithFont:font
                       constrainedToSize:maxSize
                           lineBreakMode:UILineBreakModeWordWrap];
    CGRect textRect = CGRectMake(point.x - textSize.width / 2.0,
                                 point.y - (centerVertically ? textSize.height / 2.0 : 0),
                                 textSize.width,
                                 textSize.height);
    [text drawInRect:textRect withFont:font];
}

- (void)generatePDFForHunt:(THHunt*)hunt withPageSize:(CGSize)pageSize andDelegate:(id<THPDFGeneratorDelegate>)delegate
{
    NSString *pdfFilePath = [THPDFGenerator filePath];
    UIImage *bgImage = [UIImage imageNamed:PDF_BG_A4];
    int imageSideLength = pageSize.width * IMAGE_SIDE_LENGTH_RATIO;
    if (UIGraphicsBeginPDFContextToFile(pdfFilePath, CGRectMake(0, 0, pageSize.width, pageSize.height), nil)) {
        for (int i = 0, n = [hunt.checkpoints count]; i < n; i++) {
            if (i % 4 == 0) {
                UIGraphicsBeginPDFPage();
                [bgImage drawAtPoint:CGPointMake(0, 0)];
            }
            int ul_x = (i % 2) * pageSize.width / 2;
            int ul_y = ((i % 4 < 2) ? 0 : 1) * pageSize.height / 2;
            int center_x = ul_x + pageSize.width / 4;
            int center_y = ul_y + pageSize.height / 4;
            int ix = center_x - imageSideLength / 2;
            int iy = center_y - imageSideLength / 2;

            THCheckpoint *checkpoint = [hunt.checkpoints objectAtIndex:i];
            if (checkpoint.textClue && [checkpoint.textClue length] > 0) {
                iy -= imageSideLength / 5;
            }
            [checkpoint.imageClue drawInRect:CGRectMake(ix, iy, imageSideLength, imageSideLength)];

            [self drawText:[NSString stringWithFormat:@"%d.", i + 1]
                  withFont:CLUE_NUMBER_FONT
                andMaxSize:CGSizeMake(CLUE_NUMBER_FONT_SIZE * 10, CLUE_NUMBER_FONT_SIZE * 5)
           centeredAtPoint:CGPointMake(ul_x + CARD_MARGIN, ul_y + CARD_MARGIN - CLUE_NUMBER_FONT_SIZE)
             alsoCenterVertically:NO];

            if (checkpoint.textClue && [checkpoint.textClue length] > 0) {
                int ty = (checkpoint.imageClue ? iy + imageSideLength + TEXT_CLUE_MARGIN : center_y);
                [self drawText:checkpoint.textClue
                      withFont:TEXT_CLUE_FONT
                    andMaxSize:CGSizeMake(imageSideLength, imageSideLength)
               centeredAtPoint:CGPointMake(center_x, ty)
                 alsoCenterVertically:checkpoint.imageClue == nil];
            }            
        }
        UIGraphicsEndPDFContext();
        [delegate PDFGenerated:pdfFilePath];
    }
}

@end
