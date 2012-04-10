//
//  PlayerCell.h
//  Ratings
//
//  Created by Peter Stromberg on 2012-04-07.
//  Copyright (c) 2012 NA. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface THCheckpointCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UILabel *titleLabel;
@property (nonatomic, strong) IBOutlet UILabel *textClueLabel;
@property (nonatomic, strong) IBOutlet UIImageView *imageClueImageView;

@end
