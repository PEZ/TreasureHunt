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

@interface THHuntViewController ()
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
    [self configureView];
}

- (void)viewDidUnload
{
    self.titleTextField = nil;
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
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int height = CHECKPOINT_CELL_MIN_HEIGHT;
    THCheckpoint *checkpoint = [self.hunt.checkpoints objectAtIndex:indexPath.row];

    if (checkpoint.imageClue) {
        height = MAX(CHECKPOINT_CELL_THUMBNAIL_HEIGHT, height);
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
    }
}

#pragma mark - Helpers

- (void)configureCell:(THCheckpointCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    THCheckpoint *checkpoint = [self.hunt.checkpoints objectAtIndex:indexPath.row];
    CGFloat trailIconCenterY = cell.textClueLabel.frame.origin.y - 2;
    if (checkpoint.imageClue) {
        trailIconCenterY = cell.imageClueImageView.frame.origin.y + cell.imageClueImageView.frame.size.height / 2;
    }
    cell.trailIconImageView.frame = CGRectMake(cell.trailIconImageView.frame.origin.x,
                                               trailIconCenterY - cell.trailIconImageView.frame.size.height / 2,
                                               cell.trailIconImageView.frame.size.width,
                                               cell.trailIconImageView.frame.size.height);
    if (checkpoint.hasClue) {
        cell.trailIconImageView.image = [UIImage imageNamed:@"trail-point-icon.png"];
    }
    else {
        cell.trailIconImageView.image = [UIImage imageNamed:@"trail-point-missing-icon.png"];
    }
    cell.titleLabel.text = (checkpoint.title && ![checkpoint.title isEqualToString:@""]) ? checkpoint.title : @"(Untitled checkpoint)";
    cell.textClueLabel.text = checkpoint.textClue;
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
