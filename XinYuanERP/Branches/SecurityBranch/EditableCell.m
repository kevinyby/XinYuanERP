//
//  EditableCell.m
//  XinYuanERP
//
//  Created by bravo on 13-12-20.
//  Copyright (c) 2013年 Xinyuan4. All rights reserved.
//

#import "EditableCell.h"
#import "AppInterface.h"


@implementation UITableViewCell (ButtonCell)

-(void)setVisiable:(BOOL)visiable type:(id)viewType{
    for (UIView *e in self.contentView.subviews){
        if ([e isKindOfClass:viewType]){
            e.hidden = !visiable;
        }
    }
    [self setNeedsDisplay];
}
@end

@interface EditableCell(){
    NSString *oldValue;
}

@end

//===========================================

@implementation EditableCell{
    CGFloat contentHeight;
}

@synthesize input;
@synthesize indexPath;
@synthesize delegate;



- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        contentHeight = 30.0f;
        self.input = [[UITextView alloc] initWithFrame:CGRectMake(20, 10, 380, 30)];
        self.input.backgroundColor = [UIColor redColor];
        self.input.delegate = self;
//        self.editing = YES;
        self.input.editable = YES;
        [self.contentView addSubview:self.input];
//        self.input.contentMode = UIViewContentModeScaleToFill;
    }
    return self;
}

//-(BOOL) textFieldShouldReturn:(UITextView *)textField{
//    if (self.delegate){
//        EditableCell* currentCell = (EditableCell*)textField.superview;
//        while (![currentCell isKindOfClass:[EditableCell class]]) {
//            currentCell = (EditableCell*)currentCell.superview;
//        }
//        [self.delegate editCellDidPressReturnOnCell:currentCell];
//    }
//    return YES;
//}

-(BOOL) textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if ([text isEqualToString:@"\n"]){
        if (self.delegate){
            EditableCell* currentCell = (EditableCell*)textView.superview;
            while (![currentCell isKindOfClass:[EditableCell class]]) {
                currentCell = (EditableCell*)currentCell.superview;
            }
            [self.delegate editCellDidPressReturnOnCell:currentCell];
        }
        return NO;
    }
    else{
        if ((textView.text.length != 0)&&(textView.text.length%80)==0 ){
            NSLog(@"resize");
            [textView sizeToFit];
            [self.delegate adjustHeightForCell:self];
        }
    }
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView{
    [JRTextFieldHelper adjustKeyBoardPositions:textView];
    if (self.delegate &&
        [self.delegate respondsToSelector:@selector(editCell:didBeginEditingAtIndexPath:)]){
        [self.delegate editCell:self didBeginEditingAtIndexPath:self.indexPath];
    }
}

-(void) UITextViewDidBeginEditing:(UITextView *)textField{
    [JRTextFieldHelper adjustKeyBoardPositions:textField];
    if (self.delegate &&
        [self.delegate respondsToSelector:@selector(editCell:didBeginEditingAtIndexPath:)]){
        [self.delegate editCell:self didBeginEditingAtIndexPath:self.indexPath];
    }
}


-(void) UITextViewDidEndEditing:(UITextView *)textField{
    if (self.delegate &&
        [self.delegate respondsToSelector:@selector(editCell:didEndEditingAtIndexPath:)]){
        
        [self.delegate editCell:self didEndEditingAtIndexPath:self.indexPath];
        
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

-(void) setEditing:(BOOL)editing animated:(BOOL)animated{
    [super setEditing:editing animated:animated];
    if (editing){
        self.input.editable = YES;
        oldValue = [NSString stringWithString:self.input.text];
    }else{
        self.input.editable = NO;
//        self.input.enabled = NO;
    }
}

-(id) getContent{
    NSString* data = [self.input.text copy];
    return data;
}

@end