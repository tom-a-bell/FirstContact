//
//  PreferencesWindowController.m
//  First Contact
//
//  Created by Tom Bell on 22/07/2013.
//  Copyright (c) 2013 Tom Bell. All rights reserved.
//

#import <AddressBook/AddressBook.h>
#import "PreferencesWindowController.h"

#import "Contact.h"
#import "Email.h"
#import "Phone.h"
#import "Address.h"

#import "FacebookQuery.h"

@implementation PreferencesWindowController

@synthesize managedObjectContext;

- (void)windowDidLoad
{
    [super windowDidLoad];
    facebookQuery = [[FacebookQuery alloc] init];
}

- (IBAction)getFacebookToken:(id)sender
{
    if ([sender state] == NSOnState)
    {
        [facebookQuery getAccessToken];
    }
}

// Import all Address Book contacts
- (IBAction)copyAddressBook:(id)sender
{
    if (!managedObjectContext)
    {
        NSLog(@"Error: no managed object context passed to the Preferences window controller");
        return;
    }

    _progressBar.hidden = NO;
    importProgress = 0.0;
    [self startProgressBar];
    
    ABMultiValue *multiValue = nil;
    NSArray *addressBook = [[ABAddressBook addressBook] people];
    for (ABPerson *person in addressBook)
    {
        if ([person valueForProperty:kABFirstNameProperty] && [person valueForProperty:kABLastNameProperty])
        {
            Contact *contact = [NSEntityDescription insertNewObjectForEntityForName:@"Contact"
                                                             inManagedObjectContext:managedObjectContext];
            
            contact.firstName = [person valueForProperty:kABFirstNameProperty];
            contact.lastName  = [person valueForProperty:kABLastNameProperty];

            contact.company  = [person valueForProperty:kABOrganizationProperty];
            contact.birthday = [person valueForProperty:kABBirthdayProperty];

            multiValue = [person valueForProperty:kABEmailProperty];
            for (int index = 0; index < multiValue.count; index++)
            {
                Email *email = [NSEntityDescription insertNewObjectForEntityForName:@"Email"
                                                             inManagedObjectContext:managedObjectContext];
                email.contact = contact;
                email.address = [multiValue valueAtIndex:index];
                email.type = [[[multiValue labelAtIndex:index]
                              stringByReplacingOccurrencesOfString:@"_$!<" withString:@""]
                              stringByReplacingOccurrencesOfString:@">!$_" withString:@""];
            }
            contact.email = [multiValue valueForIdentifier:[multiValue primaryIdentifier]];
            
            multiValue = [person valueForProperty:kABPhoneProperty];
            for (int index = 0; index < multiValue.count; index++)
            {
                Phone *phone = [NSEntityDescription insertNewObjectForEntityForName:@"Phone"
                                                             inManagedObjectContext:managedObjectContext];
                phone.contact = contact;
                phone.number = [multiValue valueAtIndex:index];
                phone.type = [[[multiValue labelAtIndex:index]
                              stringByReplacingOccurrencesOfString:@"_$!<" withString:@""]
                              stringByReplacingOccurrencesOfString:@">!$_" withString:@""];
            }
            contact.phone = [multiValue valueForIdentifier:[multiValue primaryIdentifier]];
            
            multiValue = [person valueForProperty:kABAddressProperty];
            for (int index = 0; index < multiValue.count; index++)
            {
                NSDictionary *addressEntry = [multiValue valueAtIndex:index];
                if (addressEntry)
                {
                    Address *address = [NSEntityDescription insertNewObjectForEntityForName:@"Address"
                                                                     inManagedObjectContext:managedObjectContext];
                    address.contact = contact;
                    address.street = [addressEntry valueForKey:kABAddressStreetKey];
                    address.city = [addressEntry valueForKey:kABAddressCityKey];
                    address.region = [addressEntry valueForKey:kABAddressStateKey];
                    address.postcode = [addressEntry valueForKey:kABAddressZIPKey];
                    address.country = [addressEntry valueForKey:kABAddressCountryKey];
                    address.type = [[[multiValue labelAtIndex:index]
                                    stringByReplacingOccurrencesOfString:@"_$!<" withString:@""]
                                    stringByReplacingOccurrencesOfString:@">!$_" withString:@""];
                }
            }
            NSDictionary *addressEntry = [multiValue valueForIdentifier:[multiValue primaryIdentifier]];
            if (addressEntry)
            {
                contact.street = [addressEntry valueForKey:kABAddressStreetKey];
                contact.city = [addressEntry valueForKey:kABAddressCityKey];
                contact.postcode = [addressEntry valueForKey:kABAddressZIPKey];
                contact.country = [addressEntry valueForKey:kABAddressCountryKey];
            }
        }
        
        importProgress += 100.0 / (double) addressBook.count;
    }
    importProgress = 100.0;
}
- (void)startProgressBar
{
    // Initialize the progress bar to go from 0 to 100
    [self.progressBar setMinValue:0.0];
    [self.progressBar setMaxValue:100.0];
    [self.progressBar setDoubleValue:0.0];
    
    // Start the auto-update calls
    [self updateProgressBar];
}

- (void)updateProgressBar
{
    [self.progressBar setDoubleValue:importProgress];
    
    // If the progress bar hasn't reached 100 yet, then wait a second and call again
    if([self.progressBar doubleValue] < 100.0)
        [self performSelector:@selector(updateProgressBar) withObject:nil afterDelay:1];
    else
        [self.progressBar setHidden:YES];
}

@end
