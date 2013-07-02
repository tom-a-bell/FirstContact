//
//  AddContactViewController.h
//  SmartContacts
//
//  Created by Tom Bell on 24/06/2013.
//  Copyright (c) 2013 Tom Bell. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AddContactViewController : NSViewController
{
    NSManagedObjectContext *managedObjectContext;
}

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

// Contact detail entry fields
@property (weak) IBOutlet NSImageView *image;
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

- (IBAction)addNewContact:(id)sender;

@end
