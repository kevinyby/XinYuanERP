//
//  BubbleMenuItem.m
//  bubbleMenu
//
//  Created by bravo on 14-4-18.
//  Copyright (c) 2014年 bravo. All rights reserved.
//

#import "BubbleMenuItem.h"

static inline CGRect ScaleRect(CGRect rect, float n){return CGRectMake((rect.size.width - rect.size.width*n)/2, (rect.size.height - rect.size.height*n)/2, rect.size.width*n, rect.size.height*n);}

@implementation BubbleMenuItem
@synthesize delegate;
@synthesize title;
@synthesize titleLabel;

-(id) initWithImage:(UIImage *)img title:(NSString*)tstr highlightedImage:(UIImage *)himg contentImage:(UIImage *)cimg hightedContentImage:(UIImage *)hcimg{
    if (self = [super init]){
        self.title = tstr;
        self.image = img;
        self.highlightedImage = himg;
        self.userInteractionEnabled = YES;
        contentImageView = [[UIImageView alloc] initWithImage:cimg];
        contentImageView.highlightedImage = hcimg;
        titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.image.size.width/2 - 15, self.image.size.height/2 - 20, 50, 30)];
//        titleLabel.center = self.center;
        titleLabel.text = self.title;
        titleLabel.textColor = [UIColor blackColor];
        titleLabel.font = [UIFont fontWithName:@"Arial" size:15];
//        titleLabel.backgroundColor = [UIColor greenColor];
        [self addSubview:contentImageView];
        [self addSubview:titleLabel];
    }
    return self;
}

-(void) layoutSubviews{
    [super layoutSubviews];
    self.bounds = CGRectMake(0, 0, self.image.size.width, self.image.size.height);
    float width = contentImageView.image.size.width;
    float height = contentImageView.image.size.height;
    contentImageView.frame = CGRectMake(self.image.size.width/2 - width/2, self.image.size.height/2 - height/2, width, height);
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    self.highlighted = YES;
    if (delegate && [delegate respondsToSelector:@selector(bubbleMenuItemTouchesBegan:)]){
        [delegate bubbleMenuItemTouchesBegan:self];
    }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    self.highlighted = NO;
    CGPoint location = [[touches anyObject] locationInView:self];
    if (CGRectContainsPoint(ScaleRect(self.bounds, 2.0f), location)){
        if (delegate && [delegate respondsToSelector:@selector(bubbleMenuItemTouchesEnd:)]){
            [delegate bubbleMenuItemTouchesEnd:self];
        }
    }
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    CGPoint location = [[touches anyObject] locationInView:self];
    if (!CGRectContainsPoint(ScaleRect(self.bounds, 2.0f), location)){
        self.highlighted = NO;
    }
}

-(void) setHighlighted:(BOOL)highlighted{
    [super setHighlighted:highlighted];
    [contentImageView setHighlighted:highlighted];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
