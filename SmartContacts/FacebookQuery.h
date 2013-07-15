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

@interface FacebookQuery : NSObject <PhFacebookDelegate>
{
    PhFacebook *fb;
}

@property NSString *accessToken;

- (void)getAccessToken;
- (void)idForContact:(Contact *)contact;
- (void)statusForContact:(Contact *)contact;
- (void)findMatchesForContacts:(NSArray *)contactList;

@end
