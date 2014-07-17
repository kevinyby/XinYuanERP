//
//  NetworkImageView.m
//  XinYuanERP
//
//  Created by Xinyuan4 on 13-12-23.
//  Copyright (c) 2014年 Xinyuan4. All rights reserved.
//

#import "NetworkImageView.h"
#import "AppInterface.h"

@implementation NetworkImageView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
      
        _activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        self.activityView.frame = CGRectMake((frame.size.width-20)/2, (frame.size.height-20)/2, 20, 20);
        self.activityView.userInteractionEnabled = YES;
        [self addSubview:self.activityView];
        [self.activityView setHidesWhenStopped:YES];
        [self.activityView startAnimating];
    }
    return self;
}

#pragma mark -
#pragma mark - Public

- (void)loadImageFromURL:(NSString*)url{
    if (isEmptyString(url)) {
        [self.activityView stopAnimating];
        return;
    }
	if (nil != self.requester) self.requester = nil;
    
    [self.activityView setHidden:NO];
    [self.activityView startAnimating];
    
    _requester = [[HTTPRequester alloc] init];
    [self.requester startDownloadRequest:IMAGE_URL(DOWNLOAD) parameters:@{@"PATH":[NSString stringWithFormat:@"/%@",url]} completeHandler:nil];
    self.requester.delegate = self;
  
    
}

-(void) didFailRequestWithError: (HTTPRequester*)request error:(NSError*)error {
    DBLOG(@"didFailRequestWithError, %@",error);
}

-(void) didFinishReceiveData: (HTTPRequester*)request data:(ResponseJsonModel*)data {
    DBLOG(@"didReceiveData");
    [self.activityView stopAnimating];
	if ([[self subviews] count]>0) {
		if ([[self subviews] objectAtIndex:0] == self.activityView) {
			[self.activityView setHidden:YES];
            [self.activityView removeFromSuperview];
		}
		else {
			[[[self subviews] objectAtIndex:0] removeFromSuperview];
		}
	}
	
	
	if (nil!=self.dataImage) {
		self.dataImage = nil;
	}
	_dataImage = [[UIImage alloc] initWithData:data.binaryData];
	
	self.image = self.dataImage;

}

@end
