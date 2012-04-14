//
//  PlayerCell.m
//  Ratings
//
//  Created by Peter Stromberg on 2012-04-07.
//  Copyright (c) 2012 NA. All rights reserved.
//

#import "THCheckpointCell.h"

@implementation THCheckpointCell

@synthesize mapTrailView;
@synthesize titleLabel;
@synthesize textClueLabel;
@synthesize imageClueImageView;
@synthesize trailIconImageView;

+ (CGFloat)heightRoundedToTileHeight:(int)height tileHeight:(int)tileHeight {
    if (!(height % tileHeight)) {
        return height;
    }
    return height + tileHeight - (height % tileHeight);
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
    }
    return self;
}

- (void)layoutSubviews {
    mapTrailView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"map-trail.png"]];
    mapTrailView.opaque = NO;    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
