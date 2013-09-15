//
//  FacebookContent.h
//  First Contact
//
//  Created by Tom Bell on 06/07/2013.
//  Copyright (c) 2013 Tom Bell. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <PhFacebook/PhFacebook.h>

@class Contact, PhFacebook;

@interface FacebookQuery : NSObject <PhFacebookDelegate>

- (void)getAccessToken;
- (void)idForContact:(Contact *)contact;
- (void)statusForContact:(Contact *)contact;
- (void)pictureForContact:(Contact *)contact;
- (void)findMatchesForContacts:(NSArray *)contactList;

@end
