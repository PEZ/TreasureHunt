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

@synthesize nameTextField = _nameTextField;
@synthesize mapTrailView = _mapTrailView;
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
    if (self.hunt && self.nameTextField) {
        self.nameTextField.text = _hunt.title;
        if (!_nameTextField.text || [_nameTextField.text isEqualToString:@""]) {
            [_nameTextField becomeFirstResponder];
        }
    }
}

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.tableView.backgroundView = [[THHuntBackgroundViewController alloc] initWithNibName:@"THHuntBackgroundView" bundle:nil].view;
    [self configureView];
}

- (void)viewDidUnload
{
    [self setNameTextField:nil];
    // Release any retained subviews of the main view.
    self.nameTextField = nil;
    [self setMapTrailView:nil];
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
    
    checkpoint.hunt = _hunt;
    
    // If appropriate, configure the new managed object.
    //[newManagedObject setValue:[NSDate date] forKey:@"timeStamp"];
    
    [THUtils saveContext:context];
    return checkpoint;
}

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
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"displayOrder" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor, nil];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
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
