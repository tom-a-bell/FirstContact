//
//  AppDelegate.m
//  SmartContacts
//
//  Created by Tom Bell on 19/06/2013.
//  Copyright (c) 2013 Tom Bell. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "AppDelegate.h"

#import "Contact.h"
#import "Model.h"
#import "Usage.h"

#import "ShowContactViewController.h"
#import "EditContactViewController.h"
#import "AddContactViewController.h"
#import "PreferencesWindowController.h"

#import "ContactTableCellView.h"
#import "FacebookQuery.h"

@implementation AppDelegate

@synthesize popover;

@synthesize managedObjectModel = _managedObjectModel;
@synthesize managedObjectContext = _managedObjectContext;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize persistentStoreType = _persistentStoreType;

@synthesize currentModel = _currentModel;

- (id)init
{
    self = [super init];
    if (self)
    {
        [self setDefaultPreferences];
        [self setPersistentStoreType:NSSQLiteStoreType];
        deleteMode = NO;

//        // Delete all previously saved models
//        [self deleteSavedModels];
    }
    return self;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    detachedWindow.contentView = detachedWindowViewController.view;
    
    // Sort the contact list by priority, then by last,first name
    NSSortDescriptor *sortByPriority = [NSSortDescriptor sortDescriptorWithKey:@"priority" ascending:NO];
    NSSortDescriptor *sortByLastName = [NSSortDescriptor sortDescriptorWithKey:@"lastName" ascending:YES
                                                                      selector:@selector(caseInsensitiveCompare:)];
    NSSortDescriptor *sortByFirstName = [NSSortDescriptor sortDescriptorWithKey:@"firstName" ascending:YES
                                                                       selector:@selector(caseInsensitiveCompare:)];

    [_arrayController setSortDescriptors:@[sortByPriority, sortByLastName, sortByFirstName]];
    
    // Get the current model for determining contact priorities
    [self currentModel];
    
    // Instantiate the Facebook query object and fetch an access token
    facebookQuery = [[FacebookQuery alloc] init];
    [facebookQuery getAccessToken];
    
//    // Create a half-hourly dispatch timer on the main queue to
//    // update each contact's priority and sort the contact list
//    priorityListUpdateTimer = CreateDispatchTimer(1800ull * NSEC_PER_SEC, 1ull * NSEC_PER_SEC,
//                                                  dispatch_get_main_queue(),
//    ^{
//        [self updatePriorities];
//    });
    
    // Create a half-hourly dispatch timer on the main queue
    // to refresh the Facebook API access token
    facebookAccessTokenTimer = CreateDispatchTimer(1800ull * NSEC_PER_SEC, 1ull * NSEC_PER_SEC,
                                                   dispatch_get_main_queue(),
    ^{
        [facebookQuery getAccessToken];
    });
                                                        
    // Create an hourly dispatch timer on the global queue to
    // fetch each contact's Facebook status message, if available
    facebookStatusUpdateTimer = CreateDispatchTimer(3600ull * NSEC_PER_SEC, 1ull * NSEC_PER_SEC,
                                                    dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
    ^{
        NSError *error = nil;
//        NSManagedObjectContext *moc = [self managedObjectContext];
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Contact"];
        NSArray *fetchedContacts = [[self managedObjectContext] executeFetchRequest:request error:&error];
        if (fetchedContacts == nil || error != nil)
        {
            NSLog(@"Error while fetching contacts\n%@", ([error localizedDescription] != nil) ?[error localizedDescription] : @"Unknown Error");
        }
        for (Contact *contact in fetchedContacts)
        {
            [facebookQuery statusForContact:contact];
        }
    });
    
    // Create a daily dispatch timer on the global queue to search
    // for the missing Facebook IDs for new contacts, if available
    facebookIdQueryTimer = CreateDispatchTimer(86400ull * NSEC_PER_SEC, 1ull * NSEC_PER_SEC,
                                               dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0),
    ^{
        NSLog(@"Searching for missing Facebook IDs...");
        NSError *error = nil;
//        NSManagedObjectContext *moc = [self managedObjectContext];
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Contact"];
        NSArray *fetchedContacts = [[self managedObjectContext] executeFetchRequest:request error:&error];
        if (fetchedContacts == nil || error != nil)
        {
            NSLog(@"Error while fetching contacts\n%@", ([error localizedDescription] != nil) ?[error localizedDescription] : @"Unknown Error");
        }
        for (Contact *contact in fetchedContacts)
        {
            [facebookQuery idForContact:contact];
        }
    });

    // Configure the table's scroll view to send frame change notifications
    id clipView = [[_tableView enclosingScrollView] contentView];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(tableScrolledNotificationHandler:)
                                                 name:NSViewBoundsDidChangeNotification
                                               object:clipView];
}

// Returns the directory the application uses to store the Core Data store file.
// This code uses a directory named "com.TomBell.SmartContacts" in the user's Application Support directory.
- (NSURL *)applicationFilesDirectory
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *appSupportURL = [[fileManager URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask] lastObject];
    return [appSupportURL URLByAppendingPathComponent:@"com.TomBell.SmartContacts"];
}

// Creates if necessary and returns the managed object model for the application.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel) return _managedObjectModel;
	
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"SmartContacts" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. (The directory for the store is created, if necessary.)
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator) return _persistentStoreCoordinator;
    
    NSManagedObjectModel *mom = [self managedObjectModel];
    if (!mom)
    {
        NSLog(@"%@:%@ No model to generate a store from", [self class], NSStringFromSelector(_cmd));
        return nil;
    }
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *applicationFilesDirectory = [self applicationFilesDirectory];
    NSError *error = nil;
    
    NSDictionary *properties = [applicationFilesDirectory resourceValuesForKeys:@[NSURLIsDirectoryKey] error:&error];
    
    if (!properties)
    {
        BOOL ok = NO;
        if ([error code] == NSFileReadNoSuchFileError)
        {
            ok = [fileManager createDirectoryAtPath:[applicationFilesDirectory path] withIntermediateDirectories:YES attributes:nil error:&error];
        }
        if (!ok)
        {
            [[NSApplication sharedApplication] presentError:error];
            return nil;
        }
    }
    else
    {
        if (![properties[NSURLIsDirectoryKey] boolValue])
        {
            // Customize and localize this error.
            NSString *failureDescription = [NSString stringWithFormat:@"Expected a folder to store application data, found a file (%@).", [applicationFilesDirectory path]];
            
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            [dict setValue:failureDescription forKey:NSLocalizedDescriptionKey];
            error = [NSError errorWithDomain:@"SmartContacts" code:101 userInfo:dict];
            
            [[NSApplication sharedApplication] presentError:error];
            return nil;
        }
    }
    
    NSURL *url = [applicationFilesDirectory URLByAppendingPathComponent:@"SmartContacts.storedata"];
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                             [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
    NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:mom];
    if (![coordinator addPersistentStoreWithType:_persistentStoreType configuration:nil
                                             URL:url options:options error:&error])
    {
        [[NSApplication sharedApplication] presentError:error];
        return nil;
    }
    _persistentStoreCoordinator = coordinator;
    
    return _persistentStoreCoordinator;
}

// Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext) return _managedObjectContext;
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator)
    {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setValue:@"Failed to initialize the store" forKey:NSLocalizedDescriptionKey];
        [dict setValue:@"There was an error building up the data file." forKey:NSLocalizedFailureReasonErrorKey];
        NSError *error = [NSError errorWithDomain:@"SmartContacts" code:9999 userInfo:dict];
        [[NSApplication sharedApplication] presentError:error];
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    
    return _managedObjectContext;
}

// Returns the NSUndoManager for the application. In this case, the manager returned is that of the managed object context for the application.
- (NSUndoManager *)windowWillReturnUndoManager:(NSWindow *)window
{
    return [[self managedObjectContext] undoManager];
}

// Performs the save action for the application, which is to send the save: message to the application's managed object context. Any encountered errors are presented to the user.
- (IBAction)saveAction:(id)sender
{
    NSError *error = nil;
    
    if (![[self managedObjectContext] commitEditing])
    {
        NSLog(@"%@:%@ unable to commit editing before saving", [self class], NSStringFromSelector(_cmd));
    }
    
    if (![[self managedObjectContext] save:&error])
    {
        [[NSApplication sharedApplication] presentError:error];
        NSLog(@"Unresolved error when saving core data:\n%@\n%@", error, [error userInfo]);
    }
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender
{
    // Save changes in the application's managed object context before the application terminates.
    
    if (!_managedObjectContext) return NSTerminateNow;
    
    if (![[self managedObjectContext] commitEditing])
    {
        NSLog(@"%@:%@ unable to commit editing to terminate", [self class], NSStringFromSelector(_cmd));
        return NSTerminateCancel;
    }
    
    if (![[self managedObjectContext] hasChanges]) return NSTerminateNow;
    
    NSError *error = nil;
    if (![[self managedObjectContext] save:&error])
    {
        // Customize this code block to include application-specific recovery steps.
        BOOL result = [sender presentError:error];
        if (result) return NSTerminateCancel;
        
        NSString *question = NSLocalizedString(@"Could not save changes while quitting. Quit anyway?",
                                               @"Quit without saves error question message");
        NSString *info = NSLocalizedString(@"Quitting now will lose any changes you have made since the last successful save",
                                           @"Quit without saves error question info");
        NSString *quitButton = NSLocalizedString(@"Quit anyway", @"Quit anyway button title");
        NSString *cancelButton = NSLocalizedString(@"Cancel", @"Cancel button title");
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:question];
        [alert setInformativeText:info];
        [alert addButtonWithTitle:quitButton];
        [alert addButtonWithTitle:cancelButton];
        
        NSInteger answer = [alert runModal];
        
        if (answer == NSAlertAlternateReturn) return NSTerminateCancel;
    }
    
    dispatch_source_cancel(facebookIdQueryTimer);
    dispatch_source_cancel(facebookStatusUpdateTimer);
    dispatch_source_cancel(facebookAccessTokenTimer);
    facebookIdQueryTimer = nil;
    facebookStatusUpdateTimer = nil;
    facebookAccessTokenTimer = nil;
    
    return NSTerminateNow;
}

// -------------------------------------------------------------------------------
//  applicationShouldTerminateAfterLastWindowClosed:sender
//
//  NSApplication delegate method placed here so the sample conveniently quits
//  after we close the window.
// -------------------------------------------------------------------------------
- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender
{
    return YES;
}

- (void)migrateStoreToType:(NSString *)newStoreType
{
    newStoreType = NSSQLiteStoreType;
    
    NSString *XMLStoreTypeExtension = @"xml";
    NSString *SQLiteStoreTypeExtension = @"sqlite";

    NSURL *oldURL = [[self applicationFilesDirectory] URLByAppendingPathComponent:@"SmartContacts.storedata"];
	NSURL *newURL = nil;
	NSURL *archiveURL = nil;
    
	if ([newStoreType isEqualToString:NSXMLStoreType])
    {
		newURL = [oldURL URLByAppendingPathExtension:XMLStoreTypeExtension];
		archiveURL = [oldURL URLByAppendingPathExtension:@"archive"];
	}
    else if ([newStoreType isEqualToString:NSSQLiteStoreType])
    {
		newURL = [oldURL URLByAppendingPathExtension:SQLiteStoreTypeExtension];
		archiveURL = [oldURL URLByAppendingPathExtension:@"archive"];
	}
    else
    {
        NSLog(@"Unrecognised persistent store type: %@", newStoreType);
        return;
    }
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:[oldURL path]])
    {
        NSLog(@"Persistent store file does not exist: %@", oldURL);
        return;
    }
    
    NSError *error = nil;
	if ([[NSFileManager defaultManager] fileExistsAtPath:[newURL path]])
    {
		if (![[NSFileManager defaultManager] removeItemAtPath:[newURL path] error:&error])
        {
			NSLog(@"Failed to delete the pre-existing file %@: %@", newURL, error);
			return;
		}
	}
    
    NSPersistentStoreCoordinator *coordinator = [[self managedObjectContext] persistentStoreCoordinator];
	NSPersistentStore *oldStore = [coordinator persistentStoreForURL:oldURL];
    if (!oldStore)
    {
        NSLog(@"Failed to retrieve the existing persistent store %@", oldURL);
        return;
    }

    NSPersistentStore *newStore = [coordinator migratePersistentStore:oldStore toURL:newURL options:nil
                                                             withType:newStoreType error:&error];
    if (!newStore)
    {
        NSLog(@"Failed to create the migrated persistent store %@: %@", newURL, error);
        return;
    }

//    // Archive the old store
//    if ([[NSFileManager defaultManager] fileExistsAtPath:[archiveURL path] isDirectory:nil])
//    {
//		if (![[NSFileManager defaultManager] removeItemAtPath:[archiveURL path] error:&error])
//        {
//            NSLog(@"Failed to delete the pre-existing archive %@: %@", archiveURL, error);
//			return;
//        }
//    }
//    if (![[NSFileManager defaultManager] moveItemAtPath:[oldURL path] toPath:[archiveURL path] error:&error])
//    {
//        NSLog(@"Failed to archive the old store %@: %@", oldURL, error);
//        return;
//    }
//    if (![[NSFileManager defaultManager] moveItemAtPath:[newURL path] toPath:[oldURL path] error:&error])
//    {
//        NSLog(@"Failed to rename the new store %@: %@", newURL, error);
//        return;
//    }
//    persistentStoreType = newStoreType;
}

#pragma mark -
#pragma mark Menu Items

- (IBAction)menuItemOpenSelected:(id)sender
{
    NSLog(@"File->Open menu item selected");
}

- (IBAction)menuItemPreferencesSelected:(id)sender
{
    if (preferencesWindowController == nil)
    {
        preferencesWindowController = [[PreferencesWindowController alloc] initWithWindowNibName:@"PreferencesWindow"];
        
        // Instantiate the managed object context in the Preferences window controller
        [preferencesWindowController setManagedObjectContext:[self managedObjectContext]];
        
        // Show the Preferences window
        [preferencesWindowController showWindow:self];
    }
}

- (IBAction)menuItemDeleteContactsSelected:(id)sender
{
    deleteMode = YES;
    CGFloat targetAlpha = deleteMode ? 1 : 0;
    [[_doneButton animator] setAlphaValue:targetAlpha];
    [_tableView enumerateAvailableRowViewsUsingBlock:^(NSTableRowView *rowView, NSInteger row)
    {
        ContactTableCellView *cellView = [self.tableView viewAtColumn:0 row:row makeIfNecessary:NO];
        [cellView layoutViewsForDeleteMode:deleteMode animated:YES];
    }];
}

#pragma mark -
#pragma mark Popover

// Show the relevant contact details in a popover view.
- (IBAction)showDetailsPopover:(id)sender
{
    // Close the popover if it is already visible
    if (self.popover)
    {
        [self closePopover:sender];
        return;
    }

    // Instantiate the view controller
    ShowContactViewController *detailsViewController = [[ShowContactViewController alloc] initWithNibName:@"ShowContactView" bundle:nil];
    
    popoverViewController = detailsViewController;
    detachedWindowViewController = detailsViewController;
    
    // Pass the selected contact to the popover view controller
    NSInteger index = [_tableView rowForView:sender];
    Contact *selectedContact = [[_arrayController arrangedObjects] objectAtIndex:index];
    [detailsViewController setContact:selectedContact];
    
    // Create the popover
    [self createPopover];
    
    // Get the button that was clicked
    NSButton *targetButton = (NSButton *)sender;
    
    // Specify the preferred position of the popover
    [self.popover showRelativeToRect:[targetButton bounds] ofView:sender preferredEdge:NSMaxYEdge];
    
    // Add an entry to the usage table each time a contact is viewed
    Usage *newAccess = [NSEntityDescription insertNewObjectForEntityForName:@"Usage"
                                                     inManagedObjectContext:[self managedObjectContext]];
    newAccess.contact = selectedContact;
    newAccess.date = [NSDate date];
    [self saveAction:nil];
    
    // Revise the priority model each time a contact is viewed
    Model *newModel = [NSEntityDescription insertNewObjectForEntityForName:@"Model"
                                                    inManagedObjectContext:[self managedObjectContext]];
    
    NSError *error = nil;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Contact"];
    NSArray *fetchedContacts = [[self managedObjectContext] executeFetchRequest:request error:&error];
    
    if (fetchedContacts == nil || error != nil)
    {
        NSLog(@"Error while fetching contacts\n%@", ([error localizedDescription] != nil) ?[error localizedDescription] : @"Unknown Error");
        return;
    }
    
    for (Contact *thisContact in fetchedContacts)
    {
        if (thisContact == selectedContact)
            [newModel updateParametersUsingModel:[self currentModel] forContact:thisContact wasSelected:YES];
        else
            [newModel updateParametersUsingModel:[self currentModel] forContact:thisContact wasSelected:NO];
        self.currentModel = newModel;
    }
    [self saveAction:nil];
}

// -------------------------------------------------------------------------------
//  Enter the details for a new contact in a popover view.
// -------------------------------------------------------------------------------
- (IBAction)showInsertPopover:(id)sender
{
    if (self.popover == nil)
    {
        // Instantiate the view controller
        AddContactViewController *insertViewController =
        [[AddContactViewController alloc] initWithNibName:@"AddContactView" bundle:nil];
        
        popoverViewController = insertViewController;
        detachedWindowViewController = insertViewController;
        
        // Create the popover
        [self createPopover];
        
        // Get the button that was clicked
        NSButton *targetButton = (NSButton *)sender;
        
        // Configure the preferred position of the popover
        NSRectEdge prefEdge = NSMaxXEdge;
        [self.popover showRelativeToRect:[targetButton bounds] ofView:sender preferredEdge:prefEdge];
        
        // Instantiate the managed object context in the popover view controller
        [insertViewController setManagedObjectContext:[self managedObjectContext]];
    }
    else
    {
        [self closePopover:sender];
    }
}

// -------------------------------------------------------------------------------
// Edit the relevant contact details in a popover view.
// -------------------------------------------------------------------------------
- (void)showEditPopoverWithContact:(Contact *)contact
{
    EditContactViewController *editViewController =
    [[EditContactViewController alloc] initWithNibName:@"EditContactView" bundle:nil];
    
    popoverViewController = editViewController;
    detachedWindowViewController = editViewController;
    
    // Specify the view controller content of the popover
    self.popover.contentViewController = popoverViewController;
    
    // Pass the contact details to the view controller
    [editViewController setContact:contact];
}

// -------------------------------------------------------------------------------
// Show the contact details after finished editing.
// -------------------------------------------------------------------------------
- (void)showDetailsPopoverWithContact:(Contact *)contact
{
    ShowContactViewController *detailsViewController =
    [[ShowContactViewController alloc] initWithNibName:@"ContactDetailsView" bundle:nil];
    
    // Pass the contact details to the view controller
    [detailsViewController setContact:contact];

    // Retain the controller for both the popover and detached window
    popoverViewController = detailsViewController;
    detachedWindowViewController = detailsViewController;
    
    // Specify the view controller content of the popover
    self.popover.contentViewController = popoverViewController;
}

// -------------------------------------------------------------------------------
//  createPopover
// -------------------------------------------------------------------------------
- (void)createPopover
{
    if (self.popover == nil)
    {
        // Create and set up the popover
        popover = [[NSPopover alloc] init];
        
        // The popover retains us and we retain the popover, and
        // we drop the popover whenever it is closed to avoid a cycle
        
        // Specify the view controller content of the popover
        self.popover.contentViewController = popoverViewController;
        
        // Use the default popover appearance
        self.popover.appearance = NSPopoverAppearanceMinimal;
        
        // Animate the popover view
        self.popover.animates = YES;
        
        // AppKit will close the popover when the user interacts with a user interface element outside the popover.
        // Note that interacting with menus or panels that become key only when needed will not cause a transient popover to close.
        self.popover.behavior = NSPopoverBehaviorSemitransient;
        
        // So we can be notified when the popover appears or closes
        self.popover.delegate = self;
    }
}

// -------------------------------------------------------------------------------
//  closePopover
// -------------------------------------------------------------------------------
- (IBAction)closePopover:(id)sender
{
    [self.popover performClose:sender];
}

#pragma mark -
#pragma mark Popover Delegate

// -------------------------------------------------------------------------------
// Invoked on the delegate when the NSPopoverWillShowNotification notification is sent.
// This method will also be invoked on the popover.
// -------------------------------------------------------------------------------
- (void)popoverWillShow:(NSNotification *)notification
{
    // add new code here before the popover has been shown
}

// -------------------------------------------------------------------------------
// Invoked on the delegate when the NSPopoverDidShowNotification notification is sent.
// This method will also be invoked on the popover.
// -------------------------------------------------------------------------------
- (void)popoverDidShow:(NSNotification *)notification
{
    // add new code here after the popover has been shown
}

// -------------------------------------------------------------------------------
// Invoked on the delegate when the NSPopoverWillCloseNotification notification is sent.
// This method will also be invoked on the popover.
// -------------------------------------------------------------------------------
- (void)popoverWillClose:(NSNotification *)notification
{
    NSString *closeReason = [[notification userInfo] valueForKey:NSPopoverCloseReasonKey];
    if ([closeReason isEqualToString:NSPopoverCloseReasonDetachToWindow])
    {
        detachedWindowViewController.view = popoverViewController.view;
        detachedWindow.contentView = detachedWindowViewController.view;
    }
}

// -------------------------------------------------------------------------------
// Invoked on the delegate when the NSPopoverDidCloseNotification notification is sent.
// This method will also be invoked on the popover.
// -------------------------------------------------------------------------------
- (void)popoverDidClose:(NSNotification *)notification
{
    popover = nil;
    [self updatePriorities];
}

// -------------------------------------------------------------------------------
// Invoked on the delegate asked for the detachable window for the popover.
// -------------------------------------------------------------------------------
- (NSWindow *)detachableWindowForPopover:(NSPopover *)popover
{
    NSWindow *window = detachedWindow;
    
    // Set the size of the window to that of the popover
    NSRect contentFrame = popoverViewController.view.frame;
    NSRect windowFrame = [window frameRectForContentRect:contentFrame];
    windowFrame.size.height += 20;
    [window setFrame:windowFrame display:YES animate:YES];
    return window;
}

#pragma mark -
#pragma mark Table View

- (void)updatePriorities
{
    // Store the current order of the contact list
    NSArray *oldContactList = [NSArray arrayWithArray:[_arrayController arrangedObjects]];

    // Update the priority for each contact
    NSError *error = nil;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Contact"];
    NSArray *fetchedContacts = [[self managedObjectContext] executeFetchRequest:request error:&error];

    if (fetchedContacts == nil || error != nil)
    {
        NSLog(@"Error while fetching contacts\n%@", ([error localizedDescription] != nil) ?[error localizedDescription] : @"Unknown Error");
        return;
    }

    for (Contact *contact in fetchedContacts)
        [contact setPriorityForModel:[self currentModel]];
    
    // Store the new order of the contact list after sorting by priority, then by last,first name
    NSSortDescriptor *sortByPriority = [NSSortDescriptor sortDescriptorWithKey:@"priority" ascending:NO];
    NSSortDescriptor *sortByLastName = [NSSortDescriptor sortDescriptorWithKey:@"lastName" ascending:YES
                                                                      selector:@selector(caseInsensitiveCompare:)];
    NSSortDescriptor *sortByFirstName = [NSSortDescriptor sortDescriptorWithKey:@"firstName" ascending:YES
                                                                       selector:@selector(caseInsensitiveCompare:)];
    NSArray *newContactList = [oldContactList sortedArrayUsingDescriptors:@[sortByPriority, sortByLastName, sortByFirstName]];

    // Rearrange the contacts in the table view
    [_tableView beginUpdates];
    [newContactList enumerateObjectsUsingBlock:^(id object, NSUInteger insertionPoint, BOOL *stop) {

        NSUInteger deletionPoint = [oldContactList indexOfObject:object];

        // Do nothing if the object's position remains unchanged
        if (insertionPoint == deletionPoint) return;

        // If the object already exists in the table, tell the table view to animate the moving row
        if (deletionPoint != NSNotFound)
            [_tableView moveRowAtIndex:deletionPoint toIndex:insertionPoint];

        // If the object is a new addition to the table, tell the table view to animate the inserted row
        else
            [_tableView insertRowsAtIndexes:[NSIndexSet indexSetWithIndex:insertionPoint] withAnimation:NSTableViewAnimationSlideDown];
    }];
    [_tableView endUpdates];
}

- (IBAction)deleteContact:(id)sender
{
    // Retrieve the selected contact
    NSInteger selectedRow = [_tableView rowForView:sender];
    Contact *selectedContact = [[_arrayController arrangedObjects] objectAtIndex:selectedRow];

    // Delete the contact
    [[self managedObjectContext] deleteObject:selectedContact];

    // Update the table data and animate the deleted entry
    NSError *error = nil;
    if (![[self managedObjectContext] save:&error])
    {
        [[NSApplication sharedApplication] presentError:error];
        NSLog(@"Unresolved error when saving core data:\n%@\n%@", error, [error userInfo]);
    }
    else
    {
        [_tableView beginUpdates];
//        [_arrayController removeObject:selectedContact];
        [_tableView removeRowsAtIndexes:[NSIndexSet indexSetWithIndex:selectedRow] withAnimation:NSTableViewAnimationSlideRight];
        [_tableView endUpdates];
    }
}

- (IBAction)doneEditing:(id)sender
{
    deleteMode = NO;
    CGFloat targetAlpha = deleteMode ? 1 : 0;
    [[_doneButton animator] setAlphaValue:targetAlpha];
    [self.tableView enumerateAvailableRowViewsUsingBlock:^(NSTableRowView *rowView, NSInteger row)
     {
         ContactTableCellView *cellView = [self.tableView viewAtColumn:0 row:row makeIfNecessary:NO];
         [cellView layoutViewsForDeleteMode:deleteMode animated:YES];
     }];
}

- (void)tableScrolledNotificationHandler:(NSNotification *)notification
{
    
    if ([notification object] == [[_tableView enclosingScrollView] contentView])
    {
        // Index of the first and last entry in the contact list
        NSInteger firstRow = 0;
        NSInteger lastRow = [[_arrayController arrangedObjects] count] - 1;

        // Rectangles enclosing the scroll view, the first and last rows in the table view, and the top and bottom fade gradients
        NSRect rectOfScrollView = [[_tableView enclosingScrollView] frame];
        NSRect rectOfFirstCellInTableView = [_tableView frameOfCellAtColumn:0 row:firstRow];
        NSRect rectOfFirstCellInScrollView = [_tableView convertRect:rectOfFirstCellInTableView
                                                              toView:[_tableView enclosingScrollView]];
        NSRect rectOfLastCellInTableView = [_tableView frameOfCellAtColumn:0 row:lastRow];
        NSRect rectOfLastCellInScrollView = [_tableView convertRect:rectOfLastCellInTableView
                                                             toView:[_tableView enclosingScrollView]];
        NSRect topFadeFrame = [self.topFade frame];
        NSRect bottomFadeFrame = [self.bottomFade frame];
        
        // Pixel locations of the top of the first cell and the top of the scroll view
        int topOfCell = rectOfFirstCellInScrollView.origin.y;
        int topOfView = rectOfScrollView.origin.y;

        // Pixel locations of the bottom of the last cell and the bottom of the scroll view
        int bottomOfCell = rectOfLastCellInScrollView.origin.y + rectOfLastCellInScrollView.size.height;
        int bottomOfView = rectOfScrollView.origin.y + rectOfScrollView.size.height;

        float distanceFromTop = topOfView - topOfCell;
        float distanceFromBottom = bottomOfCell - bottomOfView;

        CGFloat targetAlpha;
        targetAlpha = MIN(distanceFromTop / topFadeFrame.size.height * 2, 1);
        [self.topFade setAlphaValue:targetAlpha];
        targetAlpha = MIN(distanceFromBottom / bottomFadeFrame.size.height * 2, 1);
        [self.bottomFade setAlphaValue:targetAlpha];
    }
}

#pragma mark -
#pragma mark Priority Model

// Get the current model used to determine contact priority values
- (Model *)currentModel
{
    if (_currentModel) return _currentModel;
    
    // Get all saved versions of the model parameters, sorted by date with the most recent entry first
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Model"];
    NSSortDescriptor *sortByDate = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:NO];
    [request setSortDescriptors:@[sortByDate]];
    
    NSError *error = nil;
    NSArray *fetchedModels = [[self managedObjectContext] executeFetchRequest:request error:&error];
    if (fetchedModels == nil || error != nil)
        NSLog(@"Error while fetching models\n%@", ([error localizedDescription] != nil) ?[error localizedDescription] : @"Unknown Error");
    
    if ([fetchedModels count] > 0)
        // Use the most recent model
        _currentModel = fetchedModels[0];
    else
        // Create an initial model if none exist
        _currentModel = [self createInitialModel];
    
    return _currentModel;
}

// Set the current model used to determine contact priority values
- (void)setCurrentModel:(Model *)model
{
    _currentModel = model;
}

// Create an initial priority model with default parameters
- (Model *)createInitialModel
{
    Model *initialModel = [NSEntityDescription insertNewObjectForEntityForName:@"Model"
                                                        inManagedObjectContext:[self managedObjectContext]];
    initialModel.date  = [NSDate date];
    initialModel.alpha = [NSNumber numberWithDouble:1.0e-4];
    initialModel.theta = @[[NSNumber numberWithDouble:0.0],
                           [NSNumber numberWithDouble:1.0],
                           [NSNumber numberWithDouble:0.5],
                           [NSNumber numberWithDouble:0.1],
                           [NSNumber numberWithDouble:0.5],
                           [NSNumber numberWithDouble:1.0]];
    return initialModel;
}

// Delete all saved models
- (void)deleteSavedModels
{
    NSError *error = nil;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Model"];
    NSArray *fetchedModels = [[self managedObjectContext] executeFetchRequest:request error:&error];
    if (fetchedModels == nil || error != nil)
    {
        NSLog(@"Error while fetching models\n%@", ([error localizedDescription] != nil) ?[error localizedDescription] : @"Unknown Error");
    }
    
    for (Model *model in fetchedModels)
    {
        [[self managedObjectContext] deleteObject:model];
    }
    
    [self saveAction:nil];
}

#pragma mark -
#pragma mark Helper Methods

- (void)setDefaultPreferences
{
    NSDictionary *appDefaults = [NSDictionary dictionaryWithObjectsAndKeys:
                                 [NSNumber numberWithBool:NO],  @"FacebookStatus",
                                 [NSNumber numberWithBool:NO],  @"FacebookPhoto",
                                 [NSNumber numberWithBool:YES], @"UpcomingBirthdays",
                                 nil];
    [[NSUserDefaults standardUserDefaults] registerDefaults:appDefaults];
}

// Create a GCD dispatch source timer on the specified queue, with a 60 second delay before the first call
dispatch_source_t CreateDispatchTimer(uint64_t interval, uint64_t leeway, dispatch_queue_t queue, dispatch_block_t block)
{
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    if (timer)
    {
        dispatch_source_set_timer(timer, dispatch_walltime(NULL, 60ull * NSEC_PER_SEC), interval, leeway);
        dispatch_source_set_event_handler(timer, block);
        dispatch_resume(timer);
    }
    return timer;
}

@end
