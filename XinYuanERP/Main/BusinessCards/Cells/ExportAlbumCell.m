//
//  ExportAlbumCellTableViewCell.m
//  Photolib
//
//  Created by bravo on 14-6-20.
//  Copyright (c) 2014年 bravo. All rights reserved.
//

#import "ExportAlbumCell.h"
#import "Card.h"
#import "UIImageView+WebCache.h"

@implementation ExportAlbumCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

-(void) configureCell:(id)item{
    Card* card = item;
    self.description.adjustsFontSizeToFitWidth = YES;
    if (card.isAlbum){
        [self.thumb setImage:[UIImage imageNamed:@"album_frame.png"]];
        self.description.text = card.path.path;
    }else{
        [self.thumb setImageWithURL:((Card*)item).thumb_path placeholderImage:nil options:SDWebImageRetryFailed];
        NSString* des = [[[card.path.absoluteString componentsSeparatedByString:@"?"] lastObject] stringByRemovingPercentEncoding];
        self.description.text = des;
    }
    self.title.text = ((Card*) item).name;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
