//
//  EditContactViewController.h
//  First Contact
//
//  Created by Tom Bell on 13/09/2013.
//  Copyright (c) 2013 Tom Bell. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class AppDelegate, Contact, Email, Phone, Address;

@interface EditContactViewController : NSViewController <NSTableViewDataSource, NSTableViewDelegate>
{
@private
    // Add/edit mode status
    BOOL editMode;
    
    // Store the table entries in a mutable array
    NSMutableArray *_tableContents;
    
    // Store the selected row when a custom label is requested
    NSInteger _selectedRow;
    
    NSWindowController *_customLabelWindowController;
}

@property (weak) IBOutlet NSImageView *portraitImage;
@property (weak) IBOutlet NSTextField *firstName;
@property (weak) IBOutlet NSTextField *lastName;
@property (weak) IBOutlet NSTextField *relation;
@property (weak) IBOutlet NSTextField *company;
@property (weak) IBOutlet NSTableView *tableView;
@property (weak) IBOutlet NSDatePicker *birthday;
@property (weak) IBOutlet NSButton *saveButton;
@property (weak) IBOutlet NSButton *cancelButton;

@property (strong) IBOutlet NSWindow *customLabelWindow;
@property (weak) IBOutlet NSTextField *customLabel;

@property (retain) Contact *contact;
@property (weak) AppDelegate *delegate;
@property BOOL needsSaving;

- (IBAction)selectImage:(id)sender;
- (IBAction)addLabel:(id)sender;
- (IBAction)addEntry:(id)sender;
- (IBAction)save:(id)sender;
- (IBAction)cancel:(id)sender;

- (IBAction)insertLabel:(id)sender;
- (IBAction)cancelLabel:(id)sender;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil contact:(Contact*)contactOrNil delegate:(id)delegate;

@end
