//
//  EditContactViewController.m
//  SmartContacts
//
//  Created by Tom Bell on 26/06/2013.
//  Copyright (c) 2013 Tom Bell. All rights reserved.
//

#import "AppDelegate.h"
#import "EditContactViewController.h"

@interface EditContactViewController ()

@end

@implementation EditContactViewController

- (IBAction)saveChanges:(id)sender
{
    contact.firstName = self.firstName.stringValue;
    contact.lastName = self.lastName.stringValue;
    contact.relation = self.relation.stringValue;
    contact.company = self.company.stringValue;
    contact.email = self.email.stringValue;
    contact.phone = self.phone.stringValue;
    contact.street = self.street.stringValue;
    contact.city = self.city.stringValue;
    contact.postcode = self.postcode.stringValue;
    contact.country = self.country.stringValue;
    contact.birthday = self.birthday.dateValue;

    AppDelegate *appDelegate = (AppDelegate *)[[NSApplication sharedApplication] delegate];
    [appDelegate showDetailsPopoverWithContact:contact];
}


- (void)setContact:(Contact *)aContact
{
    contact = aContact;
    
    if (contact.firstName != nil)
        [self.firstName setStringValue:contact.firstName];
    if (contact.lastName != nil)
        [self.lastName setStringValue:contact.lastName];
    if (contact.relation != nil)
        [self.relation setStringValue:contact.relation];
    if (contact.company != nil)
        [self.company setStringValue:contact.company];
    if (contact.email != nil)
        [self.email setStringValue:contact.email];
    if (contact.phone != nil)
        [self.phone setStringValue:contact.phone];
    if (contact.street != nil)
        [self.street setStringValue:contact.street];
    if (contact.city != nil)
        [self.city setStringValue:contact.city];
    if (contact.postcode != nil)
        [self.postcode setStringValue:contact.postcode];
    if (contact.country != nil)
        [self.country setStringValue:contact.country];
    if (contact.birthday != nil)
        [self.birthday setObjectValue:contact.birthday];
}

@end
