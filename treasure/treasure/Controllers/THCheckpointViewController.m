//
//  THCheckpointViewController.m
//  treasure
//
//  Created by Peter Stromberg on 2012-04-09.
//  Copyright (c) 2012 NA. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "THCheckpointViewController.h"
#import "UIImage+Scale.h"
#import "UIImage+ProportionalFill.h"
#import "THUtils.h"

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
@synthesize checkpointCell = _checkpointCell;

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
        self.imageClueImageView.layer.cornerRadius = 5.0;
        self.imageClueImageView.layer.masksToBounds = YES;
        
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
    if (indexPath.section == 0 && indexPath.row == 0) {
        [_titleTextField becomeFirstResponder];
    }
    else if (indexPath.section == 1) {
        [_textClueTextField becomeFirstResponder];
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

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    return [THUtils isTextReplacementWithinMaxLength:CHECKPOINT_TITLE_MAXLENGTH
                                            forRange:range
                                          andOldText:textField.text
                                          andNewText:string];
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

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    return [THUtils isTextReplacementWithinMaxLength:CHECKPOINT_TEXTCLUE_MAXLENGTH
                                            forRange:range
                                          andOldText:textView.text
                                          andNewText:text];
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex < 2) {
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.sourceType =  buttonIndex == 0 ? UIImagePickerControllerSourceTypeCamera : UIImagePickerControllerSourceTypePhotoLibrary;
        imagePicker.delegate = self;    
        imagePicker.allowsEditing = YES;        
        [self presentModalViewController:imagePicker animated:YES];
    }
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = [info valueForKey:@"UIImagePickerControllerEditedImage"];
    NSUInteger shortest = MIN(image.size.width, image.size.height);
    image = [image imageCroppedToFitSize:CGSizeMake(shortest, shortest)];
    UIImage *clueImage = [image scaleToSize:_imageClueImageView.frame.size];
    _checkpoint.imageClue = _imageClueImageView.image = clueImage;
    _checkpoint.imageClueThumbnail = [clueImage scaleToSize:_checkpointCell.imageClueImageView.frame.size];
    [self.delegate checkpointEdited:_checkpoint];
    [picker dismissModalViewControllerAnimated:YES];
}

@end
