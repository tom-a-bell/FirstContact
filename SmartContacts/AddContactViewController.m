//
//  AddContactViewController.m
//  SmartContacts
//
//  Created by Tom Bell on 24/06/2013.
//  Copyright (c) 2013 Tom Bell. All rights reserved.
//

#import "AddContactViewController.h"
#import "AppDelegate.h"
#import "Contact.h"

@implementation AddContactViewController

@synthesize managedObjectContext;

- (IBAction)addNewContact:(id)sender
{
    Contact *newContact = [NSEntityDescription insertNewObjectForEntityForName:@"Contact"
                                                                inManagedObjectContext:managedObjectContext];
    
    newContact.firstName = self.firstName.stringValue;
    newContact.lastName = self.lastName.stringValue;
    newContact.relation = self.relation.stringValue;
    newContact.email = self.email.stringValue;
    newContact.phone = self.phone.stringValue;
    newContact.street = self.street.stringValue;
    newContact.city = self.city.stringValue;
    newContact.postcode = self.postcode.stringValue;
    newContact.country = self.country.stringValue;
    newContact.birthday = self.birthday.dateValue;
    newContact.image = [self.image.image TIFFRepresentation];

    AppDelegate *appDelegate = (AppDelegate *)[[NSApplication sharedApplication] delegate];
    [appDelegate closePopover:self];
}

@end
