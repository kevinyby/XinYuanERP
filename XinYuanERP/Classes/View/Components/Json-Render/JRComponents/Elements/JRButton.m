#import "JRButton.h"
#import "JRComponents.h"
#import "AppInterface.h"

@implementation JRButton
{
    NSString* _attribute ;
}

#pragma mark - JRComponentProtocal Methods
-(void) initializeComponents: (NSDictionary*)config
{
}

-(NSString*) attribute
{
    return _attribute;
}

-(void) setAttribute: (NSString*)attribute
{
    _attribute = attribute;
}


-(void) subRender: (NSDictionary*)dictionary {
    // for text alignment
    self.cnSpace = dictionary[JSON_CHWORD_SPACE] ;
    self.enSpace = dictionary[JSON_ENWORD_SPACE] ;
    if (dictionary[k_JR_ENABLE]) self.userInteractionEnabled = [dictionary[k_JR_ENABLE] boolValue];
    
    // here , set defalut
    if (dictionary[k_JR_CONT_Insets]) [self setContentEdgeInsets: [FrameHelper convertCanvasEdgeInsets: [RectHelper parseUIEdgeInsets:  dictionary[k_JR_CONT_Insets]]]];
    if (dictionary[k_JR_FGIMG_Insets]) [self setImageEdgeInsets: [FrameHelper convertCanvasEdgeInsets:[RectHelper parseUIEdgeInsets: dictionary[k_JR_FGIMG_Insets]]]];
    if (dictionary[k_JR_TITLE_Insets]) [self setTitleEdgeInsets: [FrameHelper convertCanvasEdgeInsets:[RectHelper parseUIEdgeInsets: dictionary[k_JR_TITLE_Insets]]]];
    
    // title font
    [JsonViewHelper setLabelFontAttribute: self.titleLabel config:dictionary];
    if (dictionary[JSON_FONT_N_COLOR])[self setTitleColor: [ColorHelper parseColor: dictionary[JSON_FONT_N_COLOR]] forState:UIControlStateNormal];
    if (dictionary[JSON_FONT_H_COLOR])[self setTitleColor: [ColorHelper parseColor: dictionary[JSON_FONT_H_COLOR]] forState:UIControlStateHighlighted];
    if (dictionary[JSON_FONT_S_COLOR])[self setTitleColor: [ColorHelper parseColor: dictionary[JSON_FONT_S_COLOR]] forState:UIControlStateSelected];
    int size = [dictionary objectForKey: JSON_FONT_SIZE] ? [[dictionary objectForKey: JSON_FONT_SIZE] integerValue] : 20 ;
    self.titleLabel.font = [self.titleLabel.font fontWithSize: [FrameTranslater convertFontSize: size]];


    // background image
    UIImage* bgImage = [UIImage imageNamed:[dictionary objectForKey: k_JR_BGN_Image]];
    if (bgImage) {
        UIImage* hightlightBGImage = [UIImage imageNamed:[dictionary objectForKey: k_JR_BGH_Image]];
        if (!hightlightBGImage) hightlightBGImage = [ImageHelper applyingAlphaToImage: bgImage alpha:0.5];
        UIImage* selectedBGImage = [UIImage imageNamed:[dictionary objectForKey: k_JR_BGS_Image]];
        if (!selectedBGImage) selectedBGImage = [ImageHelper applyingAlphaToImage: bgImage alpha:0.5];
        
        [self setBackgroundImage:bgImage forState:UIControlStateNormal];
        [self setBackgroundImage:selectedBGImage forState:UIControlStateSelected];
        [self setBackgroundImage:hightlightBGImage forState:UIControlStateHighlighted];
    }
    
    
    // foreground image
    UIImage* fgImage = [UIImage imageNamed:[dictionary objectForKey: k_JR_FGN_Image]];
    if (fgImage) {
        UIImage* hightlightFGImage = [UIImage imageNamed:[dictionary objectForKey: k_JR_FGH_Image]];
        if (!hightlightFGImage) hightlightFGImage = [ImageHelper applyingAlphaToImage: fgImage alpha:0.5];
        UIImage* selectedFGImage = [UIImage imageNamed:[dictionary objectForKey: k_JR_FGS_Image]];
        if (!selectedFGImage) selectedFGImage = [ImageHelper applyingAlphaToImage: fgImage alpha:0.5];
        
        [self setImage:fgImage forState:UIControlStateNormal];
        [self setImage:selectedFGImage forState:UIControlStateSelected];
        [self setImage:hightlightFGImage forState:UIControlStateHighlighted];
    }
    
    // size
    UIImage* sizeImage = bgImage ? bgImage : fgImage;
    [self setSize: [FrameTranslater convertCanvasSize: sizeImage.size]];
    
}


-(id) getValue {
    id result = nil;
    if (self.getJRButtonValueBlock) result = self.getJRButtonValueBlock(self);
    return result;
}

-(void) setValue: (id)value {
    if (self.setJRButtonValueBlock) self.setJRButtonValueBlock(self, value);
}


@end
