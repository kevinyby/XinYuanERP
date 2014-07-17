//
//  SpliceImageView.m
//  XinYuanERP
//
//  Created by Xinyuan4 on 14-1-25.
//  Copyright (c) 2014年 Xinyuan4. All rights reserved.
//

#import "SpliceImageView.h"
#import "UIView+UIViewAdditions.h"
#import "FrameTranslater.h"

@implementation SpliceImageView

- (id)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        _topImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [self addSubview:_topImageView];
        _midImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [self addSubview:_midImageView];
        _bottomImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [self addSubview:_bottomImageView];
    }
    return self;
}


- (void)drawRect:(CGRect)rect{
    [super drawRect:rect];

    
    CGRect _imageViewRect;
    
    _topImageView.image = _topImage;
    _imageViewRect = CGRectMake((int)(self.frame.size.width-_topImage.size.width)/2, 0, (int)_topImage.size.width, (int)_topImage.size.height);
	[_topImageView setFrame:[FrameTranslater convertCanvasRect: _imageViewRect]];
	
	_bottomImageView.image = _bottomImage;
    _imageViewRect = CGRectMake((int)(self.frame.size.width-_bottomImage.size.width)/2, 0, (int)_bottomImage.size.width,(int) _bottomImage.size.height);
	[_bottomImageView setFrame:[FrameTranslater convertCanvasRect: _imageViewRect]];
	
	_midImageView.image = _midImage;
    _imageViewRect = CGRectMake((int)(self.frame.size.width-_midImage.size.width)/2, ((int)_topImage.size.height),
                                (int)_midImage.size.width,
                                self.frame.size.height-([FrameTranslater convertCanvasHeight:(_topImageView.frame.size.height+_bottomImageView.frame.size.height)]));
	[_midImageView setFrame:[FrameTranslater convertCanvasRect: _imageViewRect]];

    _imageViewRect = CGRectMake((int)(self.frame.size.width-_bottomImage.size.width)/2,
                                _imageViewRect.origin.y+_imageViewRect.size.height,
                                (int)_bottomImage.size.width, (int)_bottomImage.size.height);
	[_bottomImageView setFrame:[FrameTranslater convertCanvasRect: _imageViewRect]];
    
    
	
//	_topImageView.image = _topImage;
//	[_topImageView setFrame:CGRectMake((int)(self.frame.size.width-_topImage.size.width/hightLevel)/2, 0, (int)_topImage.size.width/hightLevel, (int)_topImage.size.height/hightLevel)];
//	
//	_bottomImageView.image = _bottomImage;
//	[_bottomImageView setFrame:CGRectMake((int)(self.frame.size.width-_bottomImage.size.width/hightLevel)/2, 0, (int)_bottomImage.size.width/hightLevel,(int) _bottomImage.size.height/hightLevel)];
//	
//	_midImageView.image = _midImage;
//	[_midImageView setFrame:CGRectMake((int)(self.frame.size.width-_midImage.size.width/hightLevel)/2, (int)_topImage.size.height/hightLevel,
//									   _midImage.size.width/hightLevel,
//									   self.frame.size.height-_topImageView.frame.size.height-_bottomImageView.frame.size.height)];
//	
//	[_bottomImageView setFrame:CGRectMake((int)(self.frame.size.width-_bottomImage.size.width/hightLevel)/2, _midImageView.frame.origin.y+_midImageView.frame.size.height,
//                                          (int)_bottomImage.size.width/hightLevel, (int)_bottomImage.size.height/hightLevel)];
}

@end
