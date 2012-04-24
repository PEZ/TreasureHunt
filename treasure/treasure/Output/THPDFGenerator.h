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
#define PDF_PAGE_SIZE_A4_LANDSCAPE CGSizeMake(592, 842)
#define PDF_PAGE_SIZE_LETTER_LANDSCAPE CGSizeMake(612, 792)

@protocol THPDFGeneratorDelegate <NSObject>

- (void)PDFGenerated:(NSString*)pdfFilePath;

@end

@interface THPDFGenerator : NSObject

- (void)generatePDFForHunt:(THHunt*)hunt withPageSize:(CGSize)pageSize andDelegate:(id<THPDFGeneratorDelegate>)delegate;

@end

@interface THPDFGenerator (Internal)

@end

