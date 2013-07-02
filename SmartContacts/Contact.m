//
//  Contact.m
//  SmartContacts
//
//  Created by Tom Bell on 22/06/2013.
//  Copyright (c) 2013 Tom Bell. All rights reserved.
//

#import "Contact.h"


@implementation Contact

@dynamic image;
@dynamic firstName;
@dynamic lastName;
@dynamic relation;
@dynamic company;
@dynamic email;
@dynamic phone;
@dynamic street;
@dynamic city;
@dynamic postcode;
@dynamic country;
@dynamic birthday;

- (NSString *)fullName
{
    return [self.firstName stringByAppendingFormat:@" %@", self.lastName];
}

- (NSString *)fullAddress
{
    NSString *fullAddress = self.street;
    if ([self.city isNotEqualTo:@""])
        fullAddress = [fullAddress stringByAppendingFormat:@"\n%@", self.city];
    if ([self.postcode isNotEqualTo:@""])
        fullAddress = [fullAddress stringByAppendingFormat:@"\n%@", self.postcode];
    if ([self.country isNotEqualTo:@""])
        fullAddress = [fullAddress stringByAppendingFormat:@"\n%@", self.country];
    return fullAddress;
}

@end
