//
//  Contact.m
//  SmartContacts
//
//  Created by Tom Bell on 22/06/2013.
//  Copyright (c) 2013 Tom Bell. All rights reserved.
//

#import "Contact.h"


@implementation Contact

@dynamic city;
@dynamic image;
@dynamic name;
@dynamic phone;
@dynamic postcode;
@dynamic street;

-(NSDictionary *)getContactList
{
    NSDictionary *contactList = [NSDictionary dictionaryWithObjectsAndKeys:
                            @"Tom Bell", @"Name",
                            @"Me", @"Relation",
                            @"tom.bell.main@gmail.com", @"Email",
                            @"+34 662 557 811", @"Phone",
                            @"Calle de los Cañizares, 1, 2D\
                            28012 Madrid", @"Address",
                            [NSImage imageNamed:@"TomFace"], @"Image",
                            [NSDate dateWithString:@"1980-10-18 00:00:00 +0000"], @"Birthday",
                            nil];
    return contactList;
}
@end
