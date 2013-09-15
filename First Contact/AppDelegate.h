//
//  AppDelegate.h
//  First Contact
//
//  Created by Tom Bell on 19/06/2013.
//  Copyright (c) 2013 Tom Bell. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class Contact, Address, Email, Phone, Model, Usage;
@class PreferencesWindowController;
@class FacebookQuery;

@interface AppDelegate : NSObject <NSApplicationDelegate,
                                   NSTableViewDelegate,
                                   NSPopoverDelegate>
{
@private
    // Popover object
    NSPopover *popover;

    // Detached window for popover
    IBOutlet NSWindow *detachedWindow;

    // View controllers for popovers and detachable windows
    NSViewController *popoverViewController;
    NSViewController *detachedWindowViewController;
    
    // Window controller for preferences
    PreferencesWindowController *preferencesWindowController;
    
    // GCD dispatch source timer to update the priority order of the contact list
    dispatch_source_t priorityUpdateTimer;

    // The Facebook graph API handler and query timers
    FacebookQuery *facebookQuery;
    dispatch_queue_t  facebookQueryQueue;
    dispatch_source_t facebookAccessTokenTimer;
    dispatch_source_t facebookStatusUpdateTimer;
    dispatch_source_t facebookIdQueryTimer;
    
    // Batch delete mode status
    BOOL deleteMode;
    
}

@property (assign) IBOutlet NSWindow *window;
@property (retain) NSPopover *popover;

@property (weak) IBOutlet NSTableView *tableView;
@property (weak) IBOutlet NSArrayController *arrayController;

@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (retain) NSString *persistentStoreType;

// The current model used to predict the priority of each contact
@property (retain) Model *currentModel;

@property (weak) IBOutlet NSImageView *topFade;
@property (weak) IBOutlet NSImageView *bottomFade;
@property (weak) IBOutlet NSButton *doneButton;

- (IBAction)menuItemOpenSelected:(id)sender;
- (IBAction)menuItemPreferencesSelected:(id)sender;
- (IBAction)menuItemDeleteContactsSelected:(id)sender;

- (IBAction)showInsertPopover:(id)sender;
- (IBAction)showDetailsPopover:(id)sender;
- (IBAction)deleteContact:(id)sender;
- (IBAction)doneEditing:(id)sender;
- (IBAction)saveAction:(id)sender;

- (void)showEditPopoverWithContact:(Contact *)contact;
- (void)showDetailsPopoverWithContact:(Contact *)contact;
- (void)closePopover:(id)sender;

- (Contact *)newContact;
- (Address *)newAddress;
- (Email *)newEmail;
- (Phone *)newPhone;
- (Model *)newModel;
- (Usage *)newUsage;
- (void)deleteManagedObject:(NSManagedObject *)managedObject;

@end
