//
//  ContactDetails.m
//  SmartContacts
//
//  Created by Tom Bell on 19/06/2013.
//  Copyright (c) 2013 Tom Bell. All rights reserved.
//

#import "AppDelegate.h"
#import "Contact.h"
#import "ContactDetailsViewController.h"

@implementation ContactDetailsViewController

- (IBAction)editContact:(id)sender
{
    AppDelegate *appDelegate = (AppDelegate *)[[NSApplication sharedApplication] delegate];
    [appDelegate showEditPopoverWithContact:contact];
}

- (void)setContact:(Contact *)aContact
{
    contact = aContact;
    
    [self.name setStringValue:contact.fullName];
    [self.email setStringValue:contact.email];
    [self.phone setStringValue:contact.phone];
    [self.address setStringValue:contact.fullAddress];
    [self.birthday setObjectValue:contact.birthday];

    // Set the view controller to be the text field delegate.
    self.name.delegate = self;
    self.email.delegate = self;
    self.phone.delegate = self;
    self.address.delegate = self;
    self.birthday.delegate = self;
}

- (void)mouseDownTextFieldClicked:(MouseDownTextField *)textField
{
    // Change the text color to grey
    [textField setTextColor:[NSColor grayColor]];

    // Copy the text to the pasteboard
    NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
    [pasteboard declareTypes:[NSArray arrayWithObject:NSStringPboardType] owner:self];
    [pasteboard setString:textField.stringValue forType:NSStringPboardType];
}

- (void)mouseUpTextFieldClicked:(MouseDownTextField *)textField
{
    // Change the text color back to black
    [textField setTextColor:[NSColor blackColor]];
}

@end
