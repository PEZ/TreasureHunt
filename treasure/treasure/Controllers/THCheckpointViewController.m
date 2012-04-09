//
//  THCheckpointViewController.m
//  treasure
//
//  Created by Peter Stromberg on 2012-04-09.
//  Copyright (c) 2012 NA. All rights reserved.
//

#import "THCheckpointViewController.h"

@interface THCheckpointViewController ()
- (void)configureView;
@end

@implementation THCheckpointViewController

@synthesize isQRSwitch = _isQRSwitch;
@synthesize delegate = _delegate;
@synthesize titleTextField = _titleTextField;
@synthesize textClueTextView = _textClueTextField;
@synthesize imageClueImageView = _imageClueImageView;
@synthesize checkpoint = _checkpoint;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
    }
    return self;
}

#pragma mark - Managing the detail item

- (void)setCheckpoint:(THCheckpoint *)checkpoint
{
    if (_checkpoint != checkpoint) {
        _checkpoint = checkpoint;
        //[self configureView];
    }
}

- (void)configureView
{
    _textClueTextField.textAlignment = UITextAlignmentLeft;
    _textClueTextField.contentInset = UIEdgeInsetsMake(-4, -8, 0, 0);
    if (self.checkpoint && self.titleTextField) {
        self.titleTextField.text = _checkpoint.title;
        self.textClueTextView.text = _checkpoint.textClue;
        self.isQRSwitch.on = [_checkpoint.isQR boolValue];
        self.imageClueImageView.image = _checkpoint.imageClue;
        if (!_titleTextField.text || [_titleTextField.text isEqualToString:@""]) {
            [_titleTextField becomeFirstResponder];
        }
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self configureView];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [self setTitleTextField:nil];
    [self setTitleTextField:nil];
    [self setTextClueTextView:nil];
    [self setIsQRSwitch:nil];
    [self setImageClueImageView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (void)doneEditingTextClue
{
    self.navigationItem.rightBarButtonItem = nil;
    [_textClueTextField resignFirstResponder];
}


- (IBAction)qrSwitchChanged:(id)sender {
    _checkpoint.isQR = [NSNumber numberWithBool:_isQRSwitch.on];
    [self.delegate checkpointEdited:_checkpoint];
}

- (IBAction)clueImageDoubleTapped:(UITapGestureRecognizer *)sender {
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"Select image source"
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                         destructiveButtonTitle:nil
                                              otherButtonTitles:@"Take a photo", @"Choose from library", nil];
    [sheet showInView:self.view];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0:
            [_titleTextField becomeFirstResponder];
            break;
        case 3:
            [_textClueTextField becomeFirstResponder];
            break;
        default:
            break;
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    _checkpoint.title = textField.text;
    [self.delegate checkpointEdited:_checkpoint];
}

#pragma mark - UITextViewDelegate

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                           target:self
                                                                                           action:@selector(doneEditingTextClue)];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    _checkpoint.textClue = textView.text;
    [self.delegate checkpointEdited:_checkpoint];
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.sourceType =  buttonIndex == 0 ? UIImagePickerControllerSourceTypeCamera : UIImagePickerControllerSourceTypePhotoLibrary;
    imagePicker.delegate = self;    
    imagePicker.allowsEditing = YES;
    
    [self presentModalViewController:imagePicker animated:YES];
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSLog(@"info: %@", info);
    [picker dismissModalViewControllerAnimated:YES];
    _checkpoint.imageClue = _imageClueImageView.image = [info valueForKey:@"UIImagePickerControllerEditedImage"];
    [self.delegate checkpointEdited:_checkpoint];
}

@end
