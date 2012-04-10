//
//  PlayerCell.m
//  Ratings
//
//  Created by Peter Stromberg on 2012-04-07.
//  Copyright (c) 2012 NA. All rights reserved.
//

#import "THCheckpointCell.h"

@implementation THCheckpointCell

@synthesize titleLabel;
@synthesize textClueLabel;
@synthesize imageClueImageView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
