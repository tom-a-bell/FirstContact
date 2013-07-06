//
//  FacebookContent.h
//  SmartContacts
//
//  Created by Tom Bell on 06/07/2013.
//  Copyright (c) 2013 Tom Bell. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Contact.h"

@interface FacebookContent : NSObject

@property NSString *accessToken;

+ (void)findMatchesForContacts:(NSArray *)contactList;
+ (NSNumber *)idForContact:(Contact *)contact;
+ (NSString *)statusForContact:(Contact *)contact;

@end
