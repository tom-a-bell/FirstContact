//
//  Address.m
//  SmartContacts
//
//  Created by Tom Bell on 15/07/2013.
//  Copyright (c) 2013 Tom Bell. All rights reserved.
//

#import "Address.h"
#import "Contact.h"

@implementation Address

@dynamic city;
@dynamic country;
@dynamic postcode;
@dynamic region;
@dynamic street;
@dynamic type;
@dynamic contact;

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
