//
//  ContactDetails.h
//  SmartContacts
//
//  Created by Tom Bell on 19/06/2013.
//  Copyright (c) 2013 Tom Bell. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Contact.h"
#import "MouseDownTextField.h"

@interface ContactDetailsViewController : NSViewController <MouseDownTextFieldDelegate>
{
    Contact *contact;
}

@property (weak) IBOutlet MouseDownTextField *name;
@property (weak) IBOutlet MouseDownTextField *email;
@property (weak) IBOutlet MouseDownTextField *phone;
@property (weak) IBOutlet MouseDownTextField *address;
@property (weak) IBOutlet MouseDownTextField *birthday;

- (IBAction)editContact:(id)sender;

- (void)setContact:(Contact *)contact;

- (void)mouseDownTextFieldClicked:(MouseDownTextField *)textField;
- (void)mouseUpTextFieldClicked:(MouseDownTextField *)textField;

@end
