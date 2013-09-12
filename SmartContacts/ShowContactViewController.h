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

@interface ShowContactViewController : NSViewController <MouseDownTextFieldDelegate>
{
@private
    Contact *contact;

    CGFloat fieldWidth, fieldHeight, fieldIndent;
    CGFloat labelWidth, labelHeight, labelIndent;
    CGFloat sectionSize;
}

- (IBAction)editContact:(id)sender;

- (void)setContact:(Contact *)contact;
- (void)mouseDownTextFieldClicked:(MouseDownTextField *)textField;
- (void)mouseUpTextFieldClicked:(MouseDownTextField *)textField;

@end
