//
//  MyPrintPageRender.m
//  XinYuanERP
//
//  
//

#import "MyPrintPageRender.h"


@implementation MyPrintPageRender


- (CGRect) paperRect
{
    if (!_generatingPdf)
        return [super paperRect];
    
    return UIGraphicsGetPDFContextBounds();
}

- (CGRect) printableRect
{
    if (!_generatingPdf)
        return [super printableRect];
    
    return CGRectInset( self.paperRect, 20, 20 );
}

- (NSData*) convertUIWebViewToPDFsaveWidth: (float)pdfWidth saveHeight:(float) pdfHeight
{
    _generatingPdf = YES;
    
    NSMutableData *pdfData = [NSMutableData data];
    
    UIGraphicsBeginPDFContextToData( pdfData, CGRectMake(0, 0, pdfWidth, pdfHeight), nil );
    
    [self prepareForDrawingPages: NSMakeRange(0, 1)];
    
    CGRect bounds = UIGraphicsGetPDFContextBounds();
    
    for ( int i = 0 ; i < self.numberOfPages ; i++ )
    {
        UIGraphicsBeginPDFPage();
        
        [self drawPageAtIndex: i inRect: bounds];
    }
    
    UIGraphicsEndPDFContext();
    
    _generatingPdf = NO;
    
    return pdfData;
}


@end
