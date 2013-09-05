//
//  PreferencesWindowController.m
//  SmartContacts
//
//  Created by Tom Bell on 22/07/2013.
//  Copyright (c) 2013 Tom Bell. All rights reserved.
//

#import <AddressBook/AddressBook.h>
#import "PreferencesWindowController.h"
#import "Contact.h"

@implementation PreferencesWindowController

@synthesize managedObjectContext;

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self)
    {
        // Initialization code here.
    }
    
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

// Import all Address Book contacts
- (IBAction)copyAddressBook:(id)sender
{
    if (!managedObjectContext)
    {
        NSLog(@"Error: no managed object context passed to the Preferences window controller");
        return;
    }

    ABMultiValue *multiValue = nil;
    NSArray *addressBook = [[ABAddressBook addressBook] people];
    for (ABPerson *person in addressBook)
    {
        if ([person valueForProperty:kABFirstNameProperty] && [person valueForProperty:kABLastNameProperty])
        {
            Contact *newContact = [NSEntityDescription insertNewObjectForEntityForName:@"Contact"
                                                                inManagedObjectContext:managedObjectContext];
            
            newContact.firstName = [person valueForProperty:kABFirstNameProperty];
            newContact.lastName  = [person valueForProperty:kABLastNameProperty];

            newContact.company  = [person valueForProperty:kABOrganizationProperty];
            newContact.birthday = [person valueForProperty:kABBirthdayProperty];

            multiValue = [person valueForProperty:kABEmailProperty];
            newContact.email = [multiValue valueForIdentifier:[multiValue primaryIdentifier]];
            
            multiValue = [person valueForProperty:kABPhoneProperty];
            newContact.phone = [multiValue valueForIdentifier:[multiValue primaryIdentifier]];
            
            multiValue = [person valueForProperty:kABAddressProperty];
            NSDictionary *address = [multiValue valueForIdentifier:[multiValue primaryIdentifier]];
            if (address)
            {
                newContact.street = [address valueForKey:kABAddressStreetKey];
                newContact.city = [address valueForKey:kABAddressCityKey];
                newContact.postcode = [address valueForKey:kABAddressZIPKey];
                newContact.country = [address valueForKey:kABAddressCountryKey];
            }
        }
    }
}

@end
