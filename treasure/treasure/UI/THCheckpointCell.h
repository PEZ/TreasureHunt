//
//  PlayerCell.h
//  Ratings
//
//  Created by Peter Stromberg on 2012-04-07.
//  Copyright (c) 2012 NA. All rights reserved.
//

#import <UIKit/UIKit.h>

#define MAP_TRAIL_IMAGE_HEIGHT 13
#define CHECKPOINT_CELL_MARGIN 8
#define CHECKPOINT_CELL_MIN_HEIGHT 30
#define CHECKPOINT_CELL_THUMBNAIL_HEIGHT 48

@interface THCheckpointCell : UITableViewCell


@property (nonatomic, strong) IBOutlet UIView *mapTrailView;
@property (nonatomic, strong) IBOutlet UILabel *titleLabel;
@property (nonatomic, strong) IBOutlet UILabel *textClueLabel;
@property (nonatomic, strong) IBOutlet UIImageView *imageClueImageView;
@property (nonatomic, strong) IBOutlet UIImageView *trailIconImageView;

+ (CGFloat)heightRoundedToTileHeight:(int)height tileHeight:(int)tileHeight;

@end
