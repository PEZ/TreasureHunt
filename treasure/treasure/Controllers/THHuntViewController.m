//
//  THDetailViewController.m
//  treasure
//
//  Created by Peter Stromberg on 2012-04-08.
//  Copyright (c) 2012 NA. All rights reserved.
//

#import "THHunt+Behavior.h"
#import "THHuntViewController.h"
#import "THCheckpointViewController.h"
#import "THPDFViewController.h"
#import "THCheckpoint.h"
#import "THCheckpoint+Behavior.h"
#import "THCheckpointCell.h"
#import "THSparePartsViewController.h"
#import "THUtils.h"
#import "THHunt+OrderedCheckpoints.h"
#import "THHuntBackgroundViewController.h"
#import "UIView+Additions.h"

@interface THHuntViewController () {
    THCheckpointCell *_measurementCell;
    THSparePartsViewController *_sparePartsViewController;
    BOOL _isReordering;
}

- (void)configureView;
- (void)configureCell:(THCheckpointCell *)cell atIndexPath:(NSIndexPath *)indexPath;
@end

@implementation THHuntViewController

@synthesize managedObjectContext = __managedObjectContext;

@synthesize titleTextField = _titleTextField;
@synthesize reorderButton = _reorderButton;
@synthesize delegate = _delegate;
@synthesize hunt = _hunt;

#pragma mark - Managing the detail item

- (void)setHunt:(id)newDetailItem
{
    if (_hunt != newDetailItem) {
        _hunt = newDetailItem;
        [self configureView];
    }
}

- (void)configureView
{
    if (self.hunt && self.titleTextField) {
        self.titleTextField.text = _hunt.title;
        if (!_titleTextField.text || [_titleTextField.text isEqualToString:@""]) {
            [_titleTextField becomeFirstResponder];
        }
        UIButton *reorderButton = _sparePartsViewController.checkpointsReorderButton;
        [reorderButton addTarget:self action:@selector(reorderButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _measurementCell = [self.tableView dequeueReusableCellWithIdentifier:@"CheckpointCell"];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"THStoryboard" bundle:nil];
    _sparePartsViewController = [storyboard instantiateViewControllerWithIdentifier:@"SpareParts"];
    [_sparePartsViewController loadView];
    [self configureView];
}

- (void)viewDidUnload
{
    self.titleTextField = nil;
    self.delegate = nil;
    self.hunt = nil;
    _measurementCell = nil;
    [self setReorderButton:nil];
    _sparePartsViewController = nil;
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
  return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (THCheckpoint *)insertNewObject
{
    THCheckpoint *checkpoint = [NSEntityDescription insertNewObjectForEntityForName:@"Checkpoint" inManagedObjectContext:self.managedObjectContext];
    [self.hunt addCheckpointsObject:checkpoint];    
    [THUtils saveContext:self.managedObjectContext];
    return checkpoint;
}

#pragma mark - UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.hunt.checkpoints count];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return _sparePartsViewController.checkpointsSectionHeaderView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return _sparePartsViewController.checkpointsSectionHeaderView.frame.size.height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    THCheckpointCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CheckpointCell"];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return _isReordering ? UITableViewCellEditingStyleNone : UITableViewCellEditingStyleDelete;
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.hunt removeCheckpointsObject:[self.hunt.checkpoints objectAtIndex:indexPath.row]];
        [THUtils saveContext:self.managedObjectContext];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [tableView performSelector:@selector(reloadData) withObject:tableView afterDelay:0.3];
    }
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {         
    THCheckpoint *checkpoint = [self.hunt.checkpoints objectAtIndex:fromIndexPath.row];
    [self.hunt removeCheckpointsObject:checkpoint];
    [self.hunt insertObject:checkpoint inCheckpointsAtIndex:toIndexPath.row];
    [THUtils saveContext:self.managedObjectContext];
    [tableView performSelector:@selector(reloadData) withObject:tableView afterDelay:0.3];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int height = CHECKPOINT_CELL_MIN_HEIGHT;
    [self configureCell:_measurementCell atIndexPath:indexPath];
    THCheckpoint *checkpoint = [self.hunt.checkpoints objectAtIndex:indexPath.row];
    if (checkpoint.hasClue) {
        if (checkpoint.imageClue) {
            height = MAX(_measurementCell.imageClueImageView.bottom, _measurementCell.textClueLabel.bottom);
        }
        else {
            height = _measurementCell.textClueLabel.bottom;
        }
    }
    height = [THCheckpointCell heightRoundedToTileHeight:height tileHeight:MAP_TRAIL_IMAGE_HEIGHT];
    return height;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"GeneratePDF"]) {
        THPDFViewController *pdfController = [segue destinationViewController];
        pdfController.hunt = _hunt;
    }
    else {
        THCheckpoint* checkpoint;
        BOOL isAddCheckpoint = [[segue identifier] isEqualToString:@"AddCheckpoint"];
        if (isAddCheckpoint) {
            checkpoint = [self insertNewObject];
            NSArray *indexPaths = [NSArray arrayWithObject:[NSIndexPath indexPathForRow:[_hunt.checkpoints count]-1 inSection:0]];
            [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
        }
        if (isAddCheckpoint || [[segue identifier] isEqualToString:@"ShowCheckpoint"]) {
            if (!checkpoint) {
                NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
                checkpoint = [self.hunt.checkpoints objectAtIndex:indexPath.row];
            }
            THCheckpointViewController* checkpointController = [segue destinationViewController];
            [checkpointController setCheckpoint:checkpoint];
            checkpointController.delegate = self;
            checkpointController.checkpointCell = _measurementCell;
        }
    }
}

#pragma mark - Helpers

- (void)configureCell:(THCheckpointCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    THCheckpoint *checkpoint = [self.hunt.checkpoints objectAtIndex:indexPath.row];
    CGFloat mapTrailStartY = 0;
    CGFloat mapTrailEndY = 260;
    if (checkpoint.hasClue) {
        if (indexPath.row == 0) {
            cell.trailIconImageView.image = [UIImage imageNamed:@"trail-start-icon.png"];
            mapTrailStartY = [THCheckpointCell heightRoundedToTileHeight:cell.trailIconImageView.frame.origin.y tileHeight:MAP_TRAIL_IMAGE_HEIGHT];
        }
        else if (indexPath.row == [_hunt.checkpoints count] - 1) {
            cell.trailIconImageView.image = [UIImage imageNamed:@"trail-goal-icon.png"];
            mapTrailEndY = cell.trailIconImageView.frame.origin.y;
        }
        else {
            cell.trailIconImageView.image = [UIImage imageNamed:@"trail-point-icon.png"];
        }
    }
    else {
        mapTrailEndY = 0;
        cell.trailIconImageView.image = [UIImage imageNamed:@"trail-point-missing-icon.png"];
    }
    cell.mapTrailView.frame = CGRectMake(cell.mapTrailView.frame.origin.x,
                                         mapTrailStartY,
                                         cell.mapTrailView.frame.size.width,
                                         mapTrailEndY - mapTrailStartY);
    
    NSUInteger clueLabelX = cell.imageClueImageView.frame.origin.x +
    cell.imageClueImageView.frame.size.width + DEFAULT_PADDING;
    if (!checkpoint.imageClue) {
        clueLabelX = cell.imageClueImageView.frame.origin.x;
    }
    if (checkpoint.textClue && checkpoint.textClue.length > 0) {
        UILabel *clueLabel = cell.textClueLabel;
        clueLabel.frame = CGRectMake(clueLabelX,
                                     clueLabel.frame.origin.y,
                                     cell.contentView.frame.size.width - clueLabelX - DEFAULT_PADDING,
                                     0);
    }

    
    cell.titleLabel.text = (checkpoint.title && ![checkpoint.title isEqualToString:@""]) ? checkpoint.title : @"(Untitled checkpoint)";

    cell.textClueLabel.text = checkpoint.textClue;
    NSUInteger originalWidth = cell.textClueLabel.frame.size.width;
    [cell.textClueLabel sizeToFit];
    cell.textClueLabel.frame = CGRectMake(cell.textClueLabel.frame.origin.x,
                                          cell.textClueLabel.frame.origin.y,
                                          originalWidth,
                                          cell.textClueLabel.frame.size.height);
    cell.imageClueImageView.image = checkpoint.imageClueThumbnail;
}

#pragma mark - THCheckpointEditedDelegate

- (void)checkpointEdited:(THCheckpoint *)checkpoint {
    [THUtils saveContext:self.managedObjectContext];
    [self.tableView reloadData];
}


#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    _hunt.title = [THUtils trim:textField.text];
    [self.delegate huntEdited:self.hunt];
}

- (BOOL)textField:(UITextField *) textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    return [THUtils isTextReplacementWithinMaxLength:HUNT_TITLE_MAXLENGTH
                                            forRange:range
                                          andOldText:textField.text
                                          andNewText:string];
}

- (IBAction)generateButtonPressed:(id)sender {
    if (_hunt.isComplete) {
        UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"Select paper size"
                                                           delegate:self
                                                  cancelButtonTitle:nil
                                             destructiveButtonTitle:nil
                                                  otherButtonTitles:@"Letter", @"A4", nil];
        [sheet showInView:self.view];
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Incomplete hunt"
                                                        message:@"In order to generate a PDF, you need at least two checkpoints and all checkpoints must have at least one clue."
                                                       delegate:nil
                                              cancelButtonTitle:nil
                                              otherButtonTitles:@"OK", nil];
        [alert show];
    }
}

- (IBAction)reorderButtonPressed:(id)sender {
    _isReordering = !self.editing;
    [self setEditing:!self.editing animated:YES];
    [_sparePartsViewController.checkpointsReorderButton setTitle:(self.editing ? @"Done" : @"Reorder") forState:UIControlStateNormal];
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    CGSize paperSize = buttonIndex == 0 ? PDF_PAGE_SIZE_LETTER_LANDSCAPE : PDF_PAGE_SIZE_A4_LANDSCAPE;
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"THStoryboard"
                                                         bundle:nil];
    THPDFViewController *viewController =
    [storyboard instantiateViewControllerWithIdentifier:@"PDFViewController"];
    viewController.hunt = _hunt;
    viewController.paperSize = paperSize;
    [self presentModalViewController:viewController animated:YES];
}

@end
