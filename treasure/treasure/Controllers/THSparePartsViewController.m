//
//  THSparePartsViewController.m
//  treasure
//
//  Created by Peter Stromberg on 2012-04-25.
//  Copyright (c) 2012 NA. All rights reserved.
//

#import "THSparePartsViewController.h"

@interface THSparePartsViewController ()

@end

@implementation THSparePartsViewController
@synthesize checkpointsSectionHeaderView;
@synthesize checkPointsHeaderLabel;
@synthesize checkpointsReorderButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [self setCheckpointsSectionHeaderView:nil];
    [self setCheckPointsHeaderLabel:nil];
    [self setCheckpointsReorderButton:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
