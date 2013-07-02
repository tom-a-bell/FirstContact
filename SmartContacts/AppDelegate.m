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
#import "ContactTableCellView.h"
#import "ContactDetailsViewController.h"
#import "EditContactViewController.h"
#import "AddContactViewController.h"

@implementation AppDelegate

@synthesize popover;

@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize managedObjectContext = _managedObjectContext;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    if (_tableContents == nil)
    {
        _tableContents = self.getContactList;
        [self willChangeValueForKey:@"_tableContents"];
        [self didChangeValueForKey:@"_tableContents"];
        [_tableView reloadData];
    }
    
    // To make a popover detachable to a separate window you need:
    // 1) a separate NSWindow instance
    //      - it must not be visible:
    //          (if created by Interface Builder: not "Visible at Launch")
    //          (if created in code: must not be ordered front)
    //      - must not be released when closed
    //      - ideally the same size as the view controller's view frame size
    //
    // 2) two separate NSViewController instances
    //      - one for the popover, the other for the detached window
    //      - view best loaded as a sebarate nib (file's owner = NSViewController)
    //
    // To make the popover detached, simply drag the visible popover away from its attached view
    //
    // Fore more detailed information, refer to NSPopover.h
    
    detachedWindow.contentView = detachedWindowViewController.view;
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
    
    if ([identifier isEqualToString:@"ContactList"])
    {
        // We pass us as the owner so we can setup target/actions into this main controller object
        ContactTableCellView *cellView = [tableView makeViewWithIdentifier:@"ContactCell" owner:self];

        // Then setup properties on the cellView based on the column
        cellView.textField.stringValue = [dictionary objectForKey:@"Name"];
        cellView.subTitleTextField.stringValue = [dictionary objectForKey:@"Relation"];

        //  Specify the button source images
        NSImage *image = [dictionary objectForKey:@"Image"];
        NSImage *mask  = [NSImage imageNamed:@"avatarMask"];
        NSImage *bezel = [NSImage imageNamed:@"avatarBezel"];

        NSImage *mainImage = [self createButtonImage:image withMask:nil withBezel:bezel];
        NSImage *pushImage = [self createButtonImage:image withMask:mask withBezel:bezel];

        cellView.detailsButton.image = mainImage;
        cellView.detailsButton.alternateImage = pushImage;

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

// Returns the persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. (The directory for the store is created, if necessary.)
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

// Show the relevant contact details in a popover view.
- (IBAction)showDetailsPopover:(id)sender
{
    if (self.popover == nil)
    {
        // Instantiate the view controller
        ContactDetailsViewController *detailsViewController =
        [[ContactDetailsViewController alloc] initWithNibName:@"ContactDetails" bundle:nil];
        
        popoverViewController = detailsViewController;
        detachedWindowViewController = detailsViewController;
        
        // Create the popover
        [self createPopover];
        
        // Get the button that was clicked
        NSButton *targetButton = (NSButton *)sender;
        
        // Configure the preferred position of the popover
        NSRectEdge prefEdge = NSMaxYEdge;
        [self.popover showRelativeToRect:[targetButton bounds] ofView:sender preferredEdge:prefEdge];
        
        // Find out which row was clicked and pass the relevant contact details to the popup
        NSInteger row = [_tableView rowForView:sender];
        if (row != -1) {
            NSDictionary *contactDetails = [_tableContents objectAtIndex:row];
            [detailsViewController setContact:[contactDetails valueForKey:@"Contact"]];
        }
    }
    else
    {
        [self closePopover:sender];
    }
}

// -------------------------------------------------------------------------------
//  showInsertPopover:sender
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
    ContactDetailsViewController *detailsViewController =
    [[ContactDetailsViewController alloc] initWithNibName:@"ContactDetails" bundle:nil];
    
    popoverViewController = detailsViewController;
    detachedWindowViewController = detailsViewController;
    
    // Specify the view controller content of the popover
    self.popover.contentViewController = popoverViewController;
    
    // Pass the contact details to the view controller
    [detailsViewController setContact:contact];
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
#pragma mark NSPopoverDelegate

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

    [self willChangeValueForKey:@"_tableContents"];
    _tableContents = self.getContactList;
    [self didChangeValueForKey:@"_tableContents"];
    [_tableView reloadData];
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


-(NSMutableArray *)getContactList
{
    // Instantiate the managed object context.
    NSManagedObjectContext *moc = self.managedObjectContext;

    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Contact"];
    
    // Sort the entries by last name, then by first name.
    NSSortDescriptor *sortByLastName = [[NSSortDescriptor alloc] initWithKey:@"lastName" ascending:YES];
    NSSortDescriptor *sortByFirstName = [[NSSortDescriptor alloc] initWithKey:@"firstName" ascending:YES];
    [request setSortDescriptors:@[sortByLastName, sortByFirstName]];
    
    // Execute the fetch request by sending it to the managed object context.
    NSError *error;
    NSArray *fetchedContacts = [moc executeFetchRequest:request error:&error];
    if (fetchedContacts == nil)
    {
        NSLog(@"Error while fetching\n%@", ([error localizedDescription] != nil) ?[error localizedDescription] : @"Unknown Error");
    }
    
    // Add the contacts to the contact list
    NSMutableArray *contactList = [NSMutableArray new];
    for (Contact *contact in fetchedContacts)
    {
        [contactList addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                contact, @"Contact",
                                contact.fullName, @"Name",
                                contact.relation, @"Relation",
                                contact.email, @"Email",
                                contact.phone, @"Phone",
                                contact.fullAddress, @"Address",
                                [[NSImage alloc] initWithData:contact.image], @"Image",
                                contact.birthday, @"Birthday",
                                nil]];
    }

    return contactList;
}

- (NSImage *)createButtonImage:(NSImage *)image withMask:(NSImage *)mask withBezel:(NSImage *)bezel
{
    NSImage *finalImage = [[NSImage alloc] initWithSize:NSMakeSize(94, 92)];
    
    if (image == nil)
    {
        return finalImage;
    }
    
    // Create a CGImageRef from the NSImage in order to apply a circular mask
    CGImageRef imageRef = [image CGImageForProposedRect:NULL context:NULL hints:NULL];
    
    // Create the mask
    CGImageRef circularMask = [[NSImage imageNamed:@"circularMask"] CGImageForProposedRect:NULL context:NULL hints:NULL];
    CGImageRef maskRef = CGImageMaskCreate(CGImageGetWidth(circularMask),
                                           CGImageGetHeight(circularMask),
                                           CGImageGetBitsPerComponent(circularMask),
                                           CGImageGetBitsPerPixel(circularMask),
                                           CGImageGetBytesPerRow(circularMask),
                                           CGImageGetDataProvider(circularMask), NULL, YES);
    
    NSImage *base = [[NSImage alloc] initWithCGImage:CGImageCreateWithMask(imageRef, maskRef)
                                                size:NSMakeSize(82, 82)];
    
    [finalImage lockFocus];
    
    // Draw the base image
    [base drawInRect:NSMakeRect(6, 6, 82, 82)
            fromRect:NSZeroRect
           operation:NSCompositeSourceOver fraction:1.0];
    
    // Draw the mask overlay image
    if (mask != nil)
    {
        float maskWidth = [mask size].width;
        float maskHeight = [mask size].height;
        [mask drawInRect:NSMakeRect((94-maskWidth)/2, (92-maskHeight)/2+1, maskWidth, maskHeight)
                fromRect:NSZeroRect
               operation:NSCompositeSourceOver fraction:0.2];
    }
    
    // Draw the bezel overlay image
    if (bezel != nil)
    {
        [bezel drawInRect:NSMakeRect(0, 0, 94, 92)
                 fromRect:NSZeroRect
                operation:NSCompositeSourceOver fraction:1.0];
    }
    
    [finalImage unlockFocus];
    
    return finalImage;
}

@end

//    [contactList addObject:[NSDictionary dictionaryWithObjectsAndKeys:
//                            @"Tom Bell", @"Name",
//                            @"Me", @"Relation",
//                            @"tom.bell.main@gmail.com", @"Email",
//                            @"+34 662 557 811", @"Phone",
//                            @"Calle de los Cañizares, 1, 2D\
//                            28012 Madrid", @"Address",
//                            [NSImage imageNamed:@"TomFace"], @"Image",
//                            [NSDate dateWithString:@"1980-10-18 00:00:00 +0000"], @"Birthday",
//                            nil]];
//
//    [contactList addObject:[NSDictionary dictionaryWithObjectsAndKeys:
//                            @"Gise Bañó Esplugues", @"Name",
//                            @"Girlfriend", @"Relation",
//                            @"gise.esplugues@outlook.com", @"Email",
//                            @"+34 637 015 834", @"Phone",
//                            @"Calle de los Cañizares, 1, 2D\
//                            28012 Madrid", @"Address",
//                            [NSImage imageNamed:@"GiseFace2"], @"Image",
//                            [NSDate dateWithString:@"1985-09-25 00:00:00 +0100"], @"Birthday",
//                            nil]];
//
//    [contactList addObject:[NSDictionary dictionaryWithObjectsAndKeys:
//                            @"Hilary Bell", @"Name",
//                            @"Mum", @"Relation",
//                            @"hbell554@btinternet.com", @"Email",
//                            @"+44 1536 771375", @"Phone",
//                            @"12 Corby Road\
//                            Cottingham\
//                            Market Harborough\
//                            Leicestershire\
//                            LE16 8XH", @"Address",
//                            [NSImage imageNamed:@"CatFace"], @"Image",
//                            [NSDate dateWithString:@"1950-04-18 00:00:00 +0000"], @"Birthday",
//                            nil]];
//
//    [contactList addObject:[NSDictionary dictionaryWithObjectsAndKeys:
//                            @"Steven Bell", @"Name",
//                            @"Dad", @"Relation",
//                            @"steve@stevenbellediting.co.uk", @"Email",
//                            @"+44 7717 742432", @"Phone",
//                            @"12 Corby Road\
//                            Cottingham\
//                            Market Harborough\
//                            Leicestershire\
//                            LE16 8XH", @"Address",
//                            [NSImage imageNamed:@"DadFace"], @"Image",
//                            [NSDate dateWithString:@"1950-04-01 00:00:00 +0000"], @"Birthday",
//                            nil]];
//
//    [contactList addObject:[NSDictionary dictionaryWithObjectsAndKeys:
//                            @"Katherine Bell", @"Name",
//                            @"Sister", @"Relation",
//                            @"katherine.bell@twobirds.com", @"Email",
//                            @"+44 7971 975111", @"Phone",
//                            @"Bird & Bird (Services) Limited\
//                            15 Fetter Lane\
//                            London\
//                            EC4A 1JP", @"Address",
//                            [NSImage imageNamed:@"DotsFace2"], @"Image",
//                            [NSDate dateWithString:@"1985-05-16 00:00:00 +0000"], @"Birthday",
//                            nil]];
//
//    [contactList addObject:[NSDictionary dictionaryWithObjectsAndKeys:
//                            @"Dan Bell", @"Name",
//                            @"Brother", @"Relation",
//                            @"danjbell@hotmail.co.uk", @"Email",
//                            @"+44 7816 267170", @"Phone",
//                            @"Flat 16\
//                            Sutherland House\
//                            Royal Herbert Pavilions\
//                            Gilbert Close\
//                            Shooters Hill\
//                            London\
//                            SE18 4PS", @"Address",
//                            [NSImage imageNamed:@"DanFace"], @"Image",
//                            [NSDate dateWithString:@"1982-12-14 00:00:00 +0000"], @"Birthday",
//                            nil]];
