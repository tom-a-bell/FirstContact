//
//  AppDelegate.h
//  SmartContacts
//
//  Created by Tom Bell on 19/06/2013.
//  Copyright (c) 2013 Tom Bell. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Contact.h"
#import "Model.h"
#import "Usage.h"

@class FacebookContent;
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
    
    // The current model used to predict the priority of each contact
    Model *currentModel;

    // The Facebook graph API handler and query timer
    FacebookContent *facebookContent;
    dispatch_source_t facebookQueryTimer;
}

@property (assign) IBOutlet NSWindow *window;
@property (retain) NSPopover *popover;

@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (weak) IBOutlet NSImageView *bottomFade;

- (IBAction)showInsertPopover:(id)sender;
- (IBAction)showDetailsPopover:(id)sender;
- (IBAction)closePopover:(id)sender;
- (IBAction)saveAction:(id)sender;

- (void)showEditPopoverWithContact:(Contact *)contact;
- (void)showDetailsPopoverWithContact:(Contact *)contact;

@end
