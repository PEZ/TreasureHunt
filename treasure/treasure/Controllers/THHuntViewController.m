//
//  THDetailViewController.m
//  treasure
//
//  Created by Peter Stromberg on 2012-04-08.
//  Copyright (c) 2012 NA. All rights reserved.
//

#import "THHuntViewController.h"

@interface THHuntViewController ()
- (void)configureView;
@end

@implementation THHuntViewController

@synthesize nameTextField = _nameTextField;
@synthesize delegate = _delegate;
@synthesize hunt = _hunt;

#pragma mark - Managing the detail item

- (void)setHunt:(id)newDetailItem
{
    if (_hunt != newDetailItem) {
        _hunt = newDetailItem;
        
        // Update the view.
        [self configureView];
    }
}

- (void)configureView
{
    // Update the user interface for the detail item.

  if (self.hunt) {
      self.nameTextField.text = _hunt.title;
  }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
  [self configureView];
}

- (void)viewDidUnload
{
    [self setNameTextField:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
  self.nameTextField = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
  return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    _hunt.title = textField.text;
    [self.delegate huntEdited:self.hunt];
}

@end
