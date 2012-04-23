//
//  THPDFGenerator.h
//  treasure
//
//  Created by Peter Stromberg on 2012-04-22.
//  Copyright (c) 2012 NA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "THHunt.h"

#define PDF_FILE_NAME @"Hunt.pdf"
#define PDF_BG_A4 @"huntpdf-bg-a4.png"
#define PDF_PAGE_SIZE_A4_LANDSCAPE CGSizeMake(842, 595)
#define PDF_PAGE_SIZE_LETTER_LANDSCAPE CGSizeMake(792, 612)

@protocol THPDFGeneratorDelegate <NSObject>

- (void)PDFGenerated:(NSString*)pdfFilePath;

@end

@interface THPDFGenerator : NSObject

@property (strong, nonatomic) id<THPDFGeneratorDelegate> delegate;

- (id)initWithDelegate:(id<THPDFGeneratorDelegate>)delegate;
- (void)generatePDFForHunt:(THHunt*)hunt withPageSize:(CGSize)pageSize;

@end

@interface THPDFGenerator (Internal)

@end

