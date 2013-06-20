//
//  AppDelegate.m
//  SmartContacts
//
//  Created by Tom Bell on 19/06/2013.
//  Copyright (c) 2013 Tom Bell. All rights reserved.
//

#import "AppDelegate.h"
#import <QuartzCore/QuartzCore.h>
#import "ContactTableCellView.h"
#import "ContactDetailsController.h"

@implementation AppDelegate

@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize managedObjectContext = _managedObjectContext;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    if (_tableContents == nil) {
        _tableContents = [NSMutableArray new];
        [self willChangeValueForKey:@"_tableContents"];
        [_tableContents addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                   @"Tom Bell", @"Name",
                                   @"Me", @"Relation",
                                   @"tom.bell.main@gmail.com", @"Email",
                                   @"+34 662 557 811", @"Phone",
                                   @"Calle de los Cañizares, 1, 2D\
                                   28012 Madrid", @"Address",
                                   [NSImage imageNamed:@"TomFace.png"], @"Image",
                                   [NSDate dateWithString:@"1980-10-18 00:00:00 +0000"], @"Birthday",
                                   nil]];
        
        [_tableContents addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                   @"Gise Bañó Esplugues", @"Name",
                                   @"Girlfriend", @"Relation",
                                   @"gise.esplugues@outlook.com", @"Email",
                                   @"+34 637 015 834", @"Phone",
                                   @"Calle de los Cañizares, 1, 2D\
                                   28012 Madrid", @"Address",
                                   [NSImage imageNamed:@"GiseFace.png"], @"Image",
                                   [NSDate dateWithString:@"1985-09-25 00:00:00 +0100"], @"Birthday",
                                   nil]];
        
        [_tableContents addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                   @"Hilary Bell", @"Name",
                                   @"Mum", @"Relation",
                                   @"hbell554@btinternet.com", @"Email",
                                   @"+44 1536 771375", @"Phone",
                                   @"12 Corby Road\
                                   Cottingham\
                                   Market Harborough\
                                   Leicestershire\
                                   LE16 8XH", @"Address",
                                   [NSImage imageNamed:@"NSUser"], @"Image",
                                   [NSDate dateWithString:@"1950-04-18 00:00:00 +0000"], @"Birthday",
                                   nil]];
        
        [self didChangeValueForKey:@"_tableContents"];
        [_tableView reloadData];
    }
}

// The only essential/required tableview dataSource method
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return [_tableContents count];
}

// This method is optional if you use bindings to provide the data
- (NSView *)tableView:(NSTableView *)tableView
   viewForTableColumn:(NSTableColumn *)tableColumn
                  row:(NSInteger)row
{
    // Group our "model" object, which is a dictionary
    NSDictionary *dictionary = [_tableContents objectAtIndex:row];
    
    NSString *identifier = [tableColumn identifier];
    
    if ([identifier isEqualToString:@"ContactList"]) {
        // We pass us as the owner so we can setup target/actions into this main controller object
        ContactTableCellView *cellView = [tableView makeViewWithIdentifier:@"ContactCell" owner:self];
        // Then setup properties on the cellView based on the column
        cellView.textField.stringValue = [dictionary objectForKey:@"Name"];
        cellView.subTitleTextField.stringValue = [dictionary objectForKey:@"Relation"];
        
//        // Create a CGImage from an NSImage to use the circular mask
//        CGImageRef maskRef = [[NSImage imageNamed:@"CircularMask.png"] CGImage];
//        
//        CGImageRef mask = CGImageMaskCreate(CGImageGetWidth(maskRef),
//                                            CGImageGetHeight(maskRef),
//                                            CGImageGetBitsPerComponent(maskRef),
//                                            CGImageGetBitsPerPixel(maskRef),
//                                            CGImageGetBytesPerRow(maskRef),
//                                            CGImageGetDataProvider(maskRef), nil, YES);
//        
//        CGImageRef imageRef = [[dictionary objectForKey:@"Image"] CGImage];
//        
//        CGImageRef masked = CGImageCreateWithMask(imageRef, mask);
//        
//        NSImage *roundImage = (__bridge NSImage *)masked;
//        cellView.detailsButton.image = roundImage;
        cellView.detailsButton.image = [dictionary objectForKey:@"Image"];
        return cellView;
    } else {
        NSAssert1(NO, @"Unhandled table column identifier %@", identifier);
    }
    return nil;
}

// Returns the directory the application uses to store the Core Data store file. This code uses a directory named "com.TomBell.SmartContacts" in the user's Application Support directory.
- (NSURL *)applicationFilesDirectory
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *appSupportURL = [[fileManager URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask] lastObject];
    return [appSupportURL URLByAppendingPathComponent:@"com.TomBell.SmartContacts"];
}

// Creates if necessary and returns the managed object model for the application.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel) {
        return _managedObjectModel;
    }
	
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"SmartContacts" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. (The directory for the store is created, if necessary.)
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator) {
        return _persistentStoreCoordinator;
    }
    
    NSManagedObjectModel *mom = [self managedObjectModel];
    if (!mom) {
        NSLog(@"%@:%@ No model to generate a store from", [self class], NSStringFromSelector(_cmd));
        return nil;
    }
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *applicationFilesDirectory = [self applicationFilesDirectory];
    NSError *error = nil;
    
    NSDictionary *properties = [applicationFilesDirectory resourceValuesForKeys:@[NSURLIsDirectoryKey] error:&error];
    
    if (!properties) {
        BOOL ok = NO;
        if ([error code] == NSFileReadNoSuchFileError) {
            ok = [fileManager createDirectoryAtPath:[applicationFilesDirectory path] withIntermediateDirectories:YES attributes:nil error:&error];
        }
        if (!ok) {
            [[NSApplication sharedApplication] presentError:error];
            return nil;
        }
    } else {
        if (![properties[NSURLIsDirectoryKey] boolValue]) {
            // Customize and localize this error.
            NSString *failureDescription = [NSString stringWithFormat:@"Expected a folder to store application data, found a file (%@).", [applicationFilesDirectory path]];
            
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            [dict setValue:failureDescription forKey:NSLocalizedDescriptionKey];
            error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:101 userInfo:dict];
            
            [[NSApplication sharedApplication] presentError:error];
            return nil;
        }
    }
    
    NSURL *url = [applicationFilesDirectory URLByAppendingPathComponent:@"SmartContacts.storedata"];
    NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:mom];
    if (![coordinator addPersistentStoreWithType:NSXMLStoreType configuration:nil URL:url options:nil error:&error]) {
        [[NSApplication sharedApplication] presentError:error];
        return nil;
    }
    _persistentStoreCoordinator = coordinator;
    
    return _persistentStoreCoordinator;
}

// Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setValue:@"Failed to initialize the store" forKey:NSLocalizedDescriptionKey];
        [dict setValue:@"There was an error building up the data file." forKey:NSLocalizedFailureReasonErrorKey];
        NSError *error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        [[NSApplication sharedApplication] presentError:error];
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    
    return _managedObjectContext;
}

// Show the popover window with the relevant contact details.
- (IBAction)showDetails:(id)sender {

    // Find out what row was clicked and bring up the contact details popup
    NSInteger row = [_tableView rowForView:sender];
    if (row != -1) {
        [self _showContactDetailsForRow:row];
    }

//    if (row != -1) {
//        [_tableContents removeObjectAtIndex:row];
//        [_tableView removeRowsAtIndexes:[NSIndexSet indexSetWithIndex:row]
//                          withAnimation:NSTableViewAnimationEffectFade];
//    }
}

- (void)_showContactDetailsForRow:(NSInteger)row {
    NSDictionary *dictionary = [_tableContents objectAtIndex:row];
    ContactTableCellView *cellView = [_tableView viewAtColumn:0 row:row makeIfNecessary:NO];
    
    [[ContactDetailsController contactDetailsController] setDelegate:self];
    [[ContactDetailsController contactDetailsController] updatePopover:dictionary
                                               withPositioningView:cellView.detailsButton];
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
    
    if (![[self managedObjectContext] commitEditing]) {
        NSLog(@"%@:%@ unable to commit editing before saving", [self class], NSStringFromSelector(_cmd));
    }
    
    if (![[self managedObjectContext] save:&error]) {
        [[NSApplication sharedApplication] presentError:error];
    }
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender
{
    // Save changes in the application's managed object context before the application terminates.
    
    if (!_managedObjectContext) {
        return NSTerminateNow;
    }
    
    if (![[self managedObjectContext] commitEditing]) {
        NSLog(@"%@:%@ unable to commit editing to terminate", [self class], NSStringFromSelector(_cmd));
        return NSTerminateCancel;
    }
    
    if (![[self managedObjectContext] hasChanges]) {
        return NSTerminateNow;
    }
    
    NSError *error = nil;
    if (![[self managedObjectContext] save:&error]) {
        
        // Customize this code block to include application-specific recovery steps.
        BOOL result = [sender presentError:error];
        if (result) {
            return NSTerminateCancel;
        }
        
        NSString *question = NSLocalizedString(@"Could not save changes while quitting. Quit anyway?", @"Quit without saves error question message");
        NSString *info = NSLocalizedString(@"Quitting now will lose any changes you have made since the last successful save", @"Quit without saves error question info");
        NSString *quitButton = NSLocalizedString(@"Quit anyway", @"Quit anyway button title");
        NSString *cancelButton = NSLocalizedString(@"Cancel", @"Cancel button title");
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:question];
        [alert setInformativeText:info];
        [alert addButtonWithTitle:quitButton];
        [alert addButtonWithTitle:cancelButton];
        
        NSInteger answer = [alert runModal];
        
        if (answer == NSAlertAlternateReturn) {
            return NSTerminateCancel;
        }
    }
    
    return NSTerminateNow;
}

@end
