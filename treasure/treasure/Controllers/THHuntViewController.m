//
//  THDetailViewController.m
//  treasure
//
//  Created by Peter Stromberg on 2012-04-08.
//  Copyright (c) 2012 NA. All rights reserved.
//

#import "THHuntViewController.h"
#import "THCheckpointViewController.h"
#import "THCheckpoint.h"
#import "THCheckpointCell.h"
#import "THUtils.h"
#import "THHunt+OrderedCheckpoints.h"
#import "THHuntBackgroundViewController.h"
#import "UIView+Additions.h"

@interface THHuntViewController () {
    THCheckpointCell *_measurementCell;
}

- (void)configureView;
- (void)configureCell:(THCheckpointCell *)cell atIndexPath:(NSIndexPath *)indexPath;
@end

@implementation THHuntViewController

@synthesize managedObjectContext = __managedObjectContext;

@synthesize titleTextField = _titleTextField;
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
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    _measurementCell = [self.tableView dequeueReusableCellWithIdentifier:@"CheckpointCell"];
    [self configureView];
}

- (void)viewDidUnload
{
    self.titleTextField = nil;
    self.delegate = nil;
    self.hunt = nil;
    _measurementCell = nil;
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

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.hunt removeCheckpointsObject:[self.hunt.checkpoints objectAtIndex:indexPath.row]];
        [THUtils saveContext:self.managedObjectContext];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
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
    THCheckpoint *checkpoint = [self.hunt.checkpoints objectAtIndex:indexPath.row];

    NSUInteger clueLabelX = _measurementCell.imageClueImageView.frame.origin.x +
                            _measurementCell.imageClueImageView.frame.size.width + DEFAULT_PADDING;
    if (checkpoint.imageClue) {
        height = MAX(_measurementCell.imageClueImageView.frame.origin.y +
                     _measurementCell.imageClueImageView.frame.size.height + DEFAULT_PADDING, height);
    }
    else {
        clueLabelX = _measurementCell.imageClueImageView.frame.origin.x;
    }
    if (checkpoint.textClue && checkpoint.textClue.length > 0) {
        UILabel *clueLabel = _measurementCell.textClueLabel;
        clueLabel.frame = CGRectMake(clueLabelX,
                                     clueLabel.frame.origin.y,
                                     _measurementCell.contentView.frame.size.width - clueLabelX - DEFAULT_PADDING,
                                     0);
        clueLabel.text = checkpoint.textClue;
        [clueLabel sizeToFit];
        height = MAX(height, clueLabel.frame.origin.y + clueLabel.frame.size.height);
    }
    
    height += CHECKPOINT_CELL_MARGIN * 2;
    height = [THCheckpointCell heightRoundedToTileHeight:height tileHeight:MAP_TRAIL_IMAGE_HEIGHT];
    return height;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
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

#pragma mark - Helpers

- (void)configureCell:(THCheckpointCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    THCheckpoint *checkpoint = [self.hunt.checkpoints objectAtIndex:indexPath.row];
    if (checkpoint.hasClue) {
        if (indexPath.row == 0) {
            cell.trailIconImageView.image = [UIImage imageNamed:@"trail-start-icon.png"];
        }
        else if (indexPath.row == [_hunt.checkpoints count] - 1) {
            cell.trailIconImageView.image = [UIImage imageNamed:@"trail-goal-icon.png"];
        }
        else {
            cell.trailIconImageView.image = [UIImage imageNamed:@"trail-point-icon.png"];
        }
    }
    else {
        cell.trailIconImageView.image = [UIImage imageNamed:@"trail-point-missing-icon.png"];
    }
    
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
    _hunt.title = textField.text;
    [self.delegate huntEdited:self.hunt];
}

- (BOOL)textField:(UITextField *) textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    return [THUtils isTextReplacementWithinMaxLength:HUNT_TITLE_MAXLENGTH
                                            forRange:range
                                          andOldText:textField.text
                                          andNewText:string];
}


@end
