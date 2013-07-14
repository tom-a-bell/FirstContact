//
//  FacebookContent.h
//  SmartContacts
//
//  Created by Tom Bell on 06/07/2013.
//  Copyright (c) 2013 Tom Bell. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <PhFacebook/PhFacebook.h>
#import "Contact.h"

@interface FacebookContent : NSObject <PhFacebookDelegate>
{
    PhFacebook *fb;
}

@property NSString *accessToken;

- (void)getAccessToken;
- (void)findMatchesForContacts:(NSArray *)contactList;
- (NSNumber *)idForContact:(Contact *)contact;
- (NSString *)statusForContact:(Contact *)contact;

@end
