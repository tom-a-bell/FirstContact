//
//  AppDelegate.h
//  SmartContacts
//
//  Created by Tom Bell on 19/06/2013.
//  Copyright (c) 2013 Tom Bell. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Contact.h"

@class AddContactViewController;
@class ContactDetailsViewController;

@interface AppDelegate : NSObject <NSApplicationDelegate, NSPopoverDelegate,
                                   NSTableViewDelegate, NSTableViewDataSource>
{
@private
    // Popover object
    NSPopover *popover;

    // Detached window for popover
    IBOutlet NSWindow *detachedWindow;

    // View controllers for popovers and detachable windows
    NSViewController *popoverViewController;
    NSViewController *detachedWindowViewController;

    // An array of dictionaries that contain the contents to display
    NSMutableArray *_tableContents;
    IBOutlet NSTableView *_tableView;
}

@property (assign) IBOutlet NSWindow *window;
@property (retain) NSPopover *popover;

@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;

- (IBAction)showInsertPopover:(id)sender;
- (IBAction)showDetailsPopover:(id)sender;
- (IBAction)closePopover:(id)sender;
- (IBAction)saveAction:(id)sender;

- (void)showEditPopoverWithContact:(Contact *)contact;
- (void)showDetailsPopoverWithContact:(Contact *)contact;

@end
