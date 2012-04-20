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
#import "THHuntBackgroundViewController.h"

@interface THHuntViewController ()
- (void)configureView;
- (void)configureCell:(THCheckpointCell *)cell atIndexPath:(NSIndexPath *)indexPath;
@end

@implementation THHuntViewController

@synthesize fetchedResultsController = __fetchedResultsController;
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
    NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
    NSEntityDescription *entity = [[self.fetchedResultsController fetchRequest] entity];
    THCheckpoint *checkpoint = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:context];
    
    //[_hunt addCheckpointsObject:checkpoint];
    checkpoint.hunt = _hunt;
    checkpoint.displayOrder = [NSNumber numberWithInt:[_hunt.checkpoints count]];
    
    [THUtils saveContext:context];
    return checkpoint;
}

#pragma mark - UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
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
        NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
        [context deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
        [THUtils saveContext:context];
    }
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {         
    
    NSUInteger fromIndex = fromIndexPath.row;  
    NSUInteger toIndex = toIndexPath.row;
    
    if (fromIndex == toIndex) {
        return;
    }
    
    THCheckpoint *affectedObject = [self.fetchedResultsController.fetchedObjects objectAtIndex:fromIndex];  
    affectedObject.displayOrder = [NSNumber numberWithInt:toIndex];
    
    NSUInteger start, end;
    int delta;
    
    if (fromIndex < toIndex) {
        // move was down, need to shift up
        delta = -1;
        start = fromIndex + 1;
        end = toIndex;
    } else {
        // move was up, need to shift down
        delta = 1;
        start = toIndex;
        end = fromIndex - 1;
    }
    
    for (NSUInteger i = start; i <= end; i++) {
        THCheckpoint *otherObject = [self.fetchedResultsController.fetchedObjects objectAtIndex:i];  
        //NSLog(@"Updated %@ from %@ to %@", otherObject.title, otherObject.displayOrder, otherObject.displayOrder + delta);  
        otherObject.displayOrder = [NSNumber numberWithInt:[otherObject.displayOrder intValue] + delta];
    }
    
    NSError *error;
    [self.fetchedResultsController performFetch:&error];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int height = CHECKPOINT_CELL_MIN_HEIGHT;
    THCheckpoint *checkpoint = [[self fetchedResultsController] objectAtIndexPath:indexPath];

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
    }
    if (isAddCheckpoint || [[segue identifier] isEqualToString:@"ShowCheckpoint"]) {
        if (!checkpoint) {
            NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
            checkpoint = [[self fetchedResultsController] objectAtIndexPath:indexPath];
        }
        THCheckpointViewController* checkpointController = [segue destinationViewController];
        [checkpointController setCheckpoint:checkpoint];
        checkpointController.delegate = self;
    }
}

#pragma mark - Helpers

- (void)configureCell:(THCheckpointCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    THCheckpoint *checkpoint = (THCheckpoint *)[self.fetchedResultsController objectAtIndexPath:indexPath];
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
    NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
    [THUtils saveContext:context]; 
}

#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController
{
    if (__fetchedResultsController != nil) {
        return __fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"hunt == %@", _hunt];
    [fetchRequest setPredicate:pred];

    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Checkpoint" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    [fetchRequest setFetchBatchSize:20];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"displayOrder" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor, nil];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    NSString *cacheName = [NSString stringWithFormat:@"Checkpoints_%@", _hunt];
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:cacheName];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
	NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error]) {
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	}
    
    return __fetchedResultsController;
}    

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    UITableView *tableView = self.tableView;
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
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
