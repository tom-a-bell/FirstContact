//
//  PreferencesWindowController.h
//  SmartContacts
//
//  Created by Tom Bell on 22/07/2013.
//  Copyright (c) 2013 Tom Bell. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface PreferencesWindowController : NSWindowController
{
    NSManagedObjectContext *managedObjectContext;

@private
    double importProgress;
}

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

@property (weak) IBOutlet NSProgressIndicator *progressBar;

- (IBAction)copyAddressBook:(id)sender;

@end
