//
//  EditContactViewController.h
//  SmartContacts
//
//  Created by Tom Bell on 26/06/2013.
//  Copyright (c) 2013 Tom Bell. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Contact.h"

@interface EditContactViewController : NSViewController
{
    Contact *contact;
}

@property (weak) IBOutlet NSTextField *firstName;
@property (weak) IBOutlet NSTextField *lastName;
@property (weak) IBOutlet NSTextField *relation;
@property (weak) IBOutlet NSTextField *company;
@property (weak) IBOutlet NSTextField *email;
@property (weak) IBOutlet NSTextField *phone;
@property (weak) IBOutlet NSTextField *street;
@property (weak) IBOutlet NSTextField *city;
@property (weak) IBOutlet NSTextField *postcode;
@property (weak) IBOutlet NSTextField *country;
@property (weak) IBOutlet NSDatePicker *birthday;

- (IBAction)saveChanges:(id)sender;

- (void)setContact:(Contact *)contact;

@end
