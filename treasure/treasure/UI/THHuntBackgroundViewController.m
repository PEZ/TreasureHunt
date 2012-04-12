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

@synthesize mapTrailView;

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
    [self setMapTrailView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
