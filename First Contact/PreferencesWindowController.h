//
//  PreferencesWindowController.h
//  First Contact
//
//  Created by Tom Bell on 22/07/2013.
//  Copyright (c) 2013 Tom Bell. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class FacebookQuery;
@class OAuthLoginWindowController;

@interface PreferencesWindowController : NSWindowController
{
    NSManagedObjectContext *managedObjectContext;

@private

    // The Facebook graph API handler
    FacebookQuery *facebookQuery;

    // Address Book import progress
    double importProgress;

    // LinkedIn query API handler
    OAuthLoginWindowController *loginWindowController;
}

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

@property (weak) IBOutlet NSProgressIndicator *progressBar;

- (IBAction)getFacebookToken:(id)sender;
- (IBAction)getLinkedInToken:(id)sender;
- (IBAction)getTwitterToken:(id)sender;

- (IBAction)copyAddressBook:(id)sender;

@end
