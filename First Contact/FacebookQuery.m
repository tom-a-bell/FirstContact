//
//  FacebookContent.m
//  First Contact
//
//  Created by Tom Bell on 06/07/2013.
//  Copyright (c) 2013 Tom Bell. All rights reserved.
//

#import "FacebookQuery.h"
#import "Contact.h"

@implementation FacebookQuery {
@private
    PhFacebook *_phFacebook;
    NSString *_accessToken;
    NSString *_applicationID;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        _applicationID = @"294739090671217";
        _phFacebook = [[PhFacebook alloc] initWithApplicationID:_applicationID delegate:self];
    }
    return self;
}

- (void)getAccessToken
{
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"FacebookStatus"] &&
        ![[NSUserDefaults standardUserDefaults] boolForKey:@"FacebookPicture"]) return;

    NSMutableArray *requestedPermissions = [[NSMutableArray alloc] init];
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"FacebookStatus"])
        [requestedPermissions addObject:@"friends_status"];
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"FacebookPicture"])
        [requestedPermissions addObject:@"friends_about_me"];

    [_phFacebook getAccessTokenForPermissions:requestedPermissions cached:YES];
}

- (void)idForContact:(Contact *)contact
{
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"FacebookStatus"] &&
        ![[NSUserDefaults standardUserDefaults] boolForKey:@"FacebookPicture"]) return;

    if (!_accessToken) return;
    if (contact.facebookID.longValue != 0) return;
   
    // First check if the contact is the Facebook user
    NSString *queryString = [NSString stringWithFormat:@"https://graph.facebook.com/me?access_token=%@", _accessToken];
    NSDictionary *details = [self facebookRequestWithQuery:queryString];
    
    if (!details) return;
    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    
    if ([details[@"first_name"] isCaseInsensitiveLike:contact.firstName] &&
        [details[@"last_name"] isCaseInsensitiveLike:contact.lastName])
    {
        contact.facebookID = [numberFormatter numberFromString:details[@"id"]];
        NSLog(@"Candidate Facebook ID found for %@: %@", contact.fullName, contact.facebookID);
        return;
    }

    queryString = [NSString stringWithFormat:@"https://graph.facebook.com/me/friends?access_token=%@", _accessToken];
    NSDictionary *result = [self facebookRequestWithQuery:queryString];
    
    if (!result) return;

    NSSet *friends = result[@"data"];
    for (NSDictionary *friend in friends)
    {
        queryString = [NSString stringWithFormat:@"https://graph.facebook.com/%@?access_token=%@", friend[@"id"], _accessToken];
        NSDictionary *details = [self facebookRequestWithQuery:queryString];
        
        if (!details) continue;
        
        NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
        [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];

        if ([details[@"first_name"] isCaseInsensitiveLike:contact.firstName] &&
            [details[@"last_name"] isCaseInsensitiveLike:contact.lastName])
        {
            contact.facebookID = [numberFormatter numberFromString:details[@"id"]];
            NSLog(@"Candidate Facebook ID found for %@: %@", contact.fullName, contact.facebookID);
            return;
        }
    }
}

- (void)statusForContact:(Contact *)contact
{
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"FacebookStatus"]) return;

    if (!_accessToken) return;
    if (contact.facebookID.longValue == 0) return;

    NSString *queryString = [NSString stringWithFormat:@"https://graph.facebook.com/%@/statuses?access_token=%@",
                             contact.facebookID, _accessToken];
    NSDictionary *result = [self facebookRequestWithQuery:queryString];

    if (!result) return;
    
    NSArray *status = result[@"data"];
    if ([status count] > 0)
    {
        NSDictionary *latestUpdate = status[0];
        contact.facebookStatus = latestUpdate[@"message"];
    }
}

- (void)pictureForContact:(Contact *)contact
{
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"FacebookPicture"]) return;
    
    if (!_accessToken) return;
    if (contact.image) return;
    if (contact.facebookID.longValue == 0) return;
    
    NSString *queryString = [NSString stringWithFormat:
                             @"https://graph.facebook.com/%@/picture?width=164&height=164&redirect=false&access_token=%@",
                             contact.facebookID, _accessToken];
    NSDictionary *result = [self facebookRequestWithQuery:queryString];

    if (!result) return;

    NSDictionary *picture = result[@"data"];
    if (!picture) return;
    
    NSError *error = nil;
    NSURL *url = [NSURL URLWithString:picture[@"url"]];
    NSData *facebookPicture = [NSData dataWithContentsOfURL:url options:NSDataReadingUncached error:&error];
    if (error)
    {
        NSLog(@"Error fetching Facebook profile image from URL: %@", url);
        return;
    }
    
    // Check that the fetched data is a valid image before using it
    NSImage *image = [[NSImage alloc] initWithData:facebookPicture];
    if (image) contact.image = facebookPicture;
}


- (void)findMatchesForContacts:(NSArray *)contactList
{
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"FacebookStatus"] &&
        ![[NSUserDefaults standardUserDefaults] boolForKey:@"FacebookPicture"]) return;

    if (!_accessToken) return;
    
    NSString *queryString = [NSString stringWithFormat:@"https://graph.facebook.com/me/friends?access_token=%@", _accessToken];
    NSDictionary *result = [self facebookRequestWithQuery:queryString];

    if (!result) return;
    
    NSSet *friends = result[@"data"];
    for (NSDictionary *friend in friends)
    {
        queryString = [NSString stringWithFormat:@"https://graph.facebook.com/%@?access_token=%@", friend[@"id"], _accessToken];
        NSDictionary *details = [self facebookRequestWithQuery:queryString];

        if (!details) continue;
        
        NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
        [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];

        for (Contact *contact in contactList)
        {
            if ([details[@"first_name"] isCaseInsensitiveLike:contact.firstName] &&
                [details[@"last_name"] isCaseInsensitiveLike:contact.lastName])
            {
                contact.facebookID = [numberFormatter numberFromString:details[@"id"]];
                NSLog(@"Candidate Facebook ID found for %@: %@", contact.fullName, contact.facebookID);
                break;
            }
        }
    }
}

- (NSDictionary *)facebookRequestWithQuery:(NSString *)queryString
{
    NSURL *queryUrl = [NSURL URLWithString:queryString];
    NSData *data = [NSData dataWithContentsOfURL:queryUrl];
    
    if (!data) return nil;
    
    NSError *error = nil;
    id object = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    if(error)
    {
        NSLog(@"Malformed JSON data returned by Facebook query: %@", queryString);
        return nil;
    }
    
    if(![object isKindOfClass:[NSDictionary class]])
    {
        NSLog(@"Unrecognised data type for returned JSON object:\n\n%@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
        return nil;
    }

    NSDictionary *result = object;
    return result;
}

#pragma mark PhFacebookDelegate methods

- (void)tokenResult:(NSDictionary*)result
{
    if ([[result valueForKey:@"valid"] boolValue])
    {
        _accessToken = _phFacebook.accessToken;
        if (!_accessToken) NSLog(@"Failed to retrieve Facebook access token");
    }
    else
    {
        NSLog(@"Error retrieving Facebook access token: %@", [result valueForKey:@"error"]);
    }
}

- (void)requestResult:(NSDictionary*)result
{
}

- (void)willShowUINotification:(PhFacebook*)sender
{
    NSLog(@"Creating Facebook login window...");
    [NSApp requestUserAttention:NSInformationalRequest];
}

@end
