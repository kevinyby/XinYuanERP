//
//  MyPrintPageRender.h
//  XinYuanERP
//
//  利用UIWebView存储为多页的PDF（项目中预览的是doc,docx等文档的时候，可以转成成PDF档，保存起来并打印）
//

#import <Foundation/Foundation.h>

@interface MyPrintPageRender : UIPrintPageRenderer
{
     BOOL _generatingPdf;
}

- (NSData*) convertUIWebViewToPDFsaveWidth: (float)pdfWidth saveHeight:(float) pdfHeight;

@end
