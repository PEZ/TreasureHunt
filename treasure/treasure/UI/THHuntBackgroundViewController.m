//
//  THHuntBackgroundViewController.m
//  treasure
//
//  Created by Peter Stromberg on 2012-04-13.
//  Copyright (c) 2012 NA. All rights reserved.
//

#import "THHuntBackgroundViewController.h"

@interface THHuntBackgroundViewController ()

@end

@implementation THHuntBackgroundViewController

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
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

@end
