//
//  FacebookContent.m
//  SmartContacts
//
//  Created by Tom Bell on 06/07/2013.
//  Copyright (c) 2013 Tom Bell. All rights reserved.
//

#import "FacebookContent.h"

@implementation FacebookContent

+ (void)findMatchesForContacts:(NSArray *)contactList
{
    NSString *accessToken = @"CAACEdEose0cBAKzAeopdzgDXgWLuaTRkMmOt7F2bnBYqNZChEYFpp9vGwpoQw9IkCUMII7ZAHF2FWMjx1iU2f0JcXJDueJyNEK2X7Ni2uMgKaaK22D4ZBKOwuP6N7gzYTKEvaIGMZAdKjjCu9MZA6wLz7MBRg8EgN2L6FQls73ebB6sVhh6SHwUzPhLroEezZCqASQ84ZAIfwZDZD";
    
    NSString *queryString = [[NSString alloc] initWithFormat:@"https://graph.facebook.com/me/friends?access_token=%@", accessToken];
    
    NSURL *queryUrl = [NSURL URLWithString:queryString];
    
    NSData *data = [NSData dataWithContentsOfURL:queryUrl];
    
    if (data == nil)
    {
        NSLog(@"No data returned from Facebook friends query");
        return;
    }
    
    NSError *error = nil;
    id object = [NSJSONSerialization JSONObjectWithData:data
                                                options:NSJSONReadingMutableContainers
                                                  error:&error];
    
    if(error)
    {
        NSLog(@"Malformed JSON data returned by Facebook friends query");
    }
    
    if([object isKindOfClass:[NSDictionary class]])
    {
        NSDictionary *results = object;
        NSSet *friends = results[@"data"];
        for (NSDictionary *friend in friends)
        {
            queryString = [[NSString alloc] initWithFormat:@"https://graph.facebook.com/%@?access_token=%@", friend[@"id"], accessToken];
            queryUrl = [NSURL URLWithString:queryString];
            
            data = [NSData dataWithContentsOfURL:queryUrl];
            
            if (data == nil) continue;
            
            object = [NSJSONSerialization JSONObjectWithData:data
                                                     options:NSJSONReadingMutableContainers
                                                       error:&error];
            
            if(error)
            {
                NSLog(@"Malformed JSON data returned by Facebook friends query");
            }
            
            if([object isKindOfClass:[NSDictionary class]])
            {
                NSDictionary *details = object;
                for (Contact *contact in contactList)
                {
                    if ([details[@"first_name"] isEqualTo:contact.firstName] &&
                        [details[@"last_name"] isEqualTo:contact.lastName])
                    {
                        NSLog(@"Candidate Facebook ID found for %@: %@", contact.fullName, details[@"id"]);
                        NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
                        [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
                        NSNumber *facebookID = [numberFormatter numberFromString:details[@"id"]];
                        contact.facebookID = facebookID;
                    }
                }
            }
            else
            {
                NSLog(@"Unrecognised data type for returned JSON object:\n\n%@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
            }
        }
    }
    else
    {
        NSLog(@"Unrecognised data type for returned JSON object:\n\n%@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    }
}

+ (NSNumber *)idForContact:(Contact *)contact
{
     NSString *accessToken = @"CAACEdEose0cBAKzAeopdzgDXgWLuaTRkMmOt7F2bnBYqNZChEYFpp9vGwpoQw9IkCUMII7ZAHF2FWMjx1iU2f0JcXJDueJyNEK2X7Ni2uMgKaaK22D4ZBKOwuP6N7gzYTKEvaIGMZAdKjjCu9MZA6wLz7MBRg8EgN2L6FQls73ebB6sVhh6SHwUzPhLroEezZCqASQ84ZAIfwZDZD";
    
    NSString *queryString = [[NSString alloc] initWithFormat:@"https://graph.facebook.com/me/friends?access_token=%@", accessToken];
    
    NSURL *queryUrl = [NSURL URLWithString:queryString];
    
    NSData *data = [NSData dataWithContentsOfURL:queryUrl];
    
    if (data == nil)
    {
        NSLog(@"No data returned from Facebook friends query");
        return nil;
    }
    
    NSError *error = nil;
    id object = [NSJSONSerialization JSONObjectWithData:data
                                                options:NSJSONReadingMutableContainers
                                                  error:&error];
    
    if(error)
    {
        NSLog(@"Malformed JSON data returned by Facebook friends query");
    }
 
    if([object isKindOfClass:[NSDictionary class]])
    {
        NSDictionary *results = object;
        NSSet *friends = results[@"data"];
        for (NSDictionary *friend in friends)
        for (NSDictionary *friend in friends)
        {
            queryString = [[NSString alloc] initWithFormat:@"https://graph.facebook.com/%@?access_token=%@", friend[@"id"], accessToken];
            queryUrl = [NSURL URLWithString:queryString];
            
            data = [NSData dataWithContentsOfURL:queryUrl];
            
            if (data == nil) continue;
            
            object = [NSJSONSerialization JSONObjectWithData:data
                                                     options:NSJSONReadingMutableContainers
                                                       error:&error];
            
            if(error)
            {
                NSLog(@"Malformed JSON data returned by Facebook friends query");
            }
            
            if([object isKindOfClass:[NSDictionary class]])
            {
                NSDictionary *details = object;
                if ([details[@"first_name"] isEqualTo:contact.firstName] &&
                    [details[@"last_name"] isEqualTo:contact.lastName])
                {
                    NSLog(@"Candidate Facebook ID found for %@: %@", contact.fullName, details[@"id"]);
                    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
                    [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
                    NSNumber *facebookID = [numberFormatter numberFromString:details[@"id"]];
                    return facebookID;
                }
            }
            else
            {
                NSLog(@"Unrecognised data type for returned JSON object:\n\n%@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
            }
        }
    }
    else
    {
        NSLog(@"Unrecognised data type for returned JSON object:\n\n%@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    }

    return nil;
}

+ (NSString *)statusForContact:(Contact *)contact
{
    if (contact.facebookID == nil) return nil;

     NSString *accessToken = @"CAACEdEose0cBAKzAeopdzgDXgWLuaTRkMmOt7F2bnBYqNZChEYFpp9vGwpoQw9IkCUMII7ZAHF2FWMjx1iU2f0JcXJDueJyNEK2X7Ni2uMgKaaK22D4ZBKOwuP6N7gzYTKEvaIGMZAdKjjCu9MZA6wLz7MBRg8EgN2L6FQls73ebB6sVhh6SHwUzPhLroEezZCqASQ84ZAIfwZDZD";
    
    NSString *statusQuery = [[NSString alloc] initWithFormat:@"https://graph.facebook.com/%@/statuses?access_token=%@", contact.facebookID, accessToken];
    
    NSURL *queryUrl = [NSURL URLWithString:statusQuery];
    
    NSData *data = [NSData dataWithContentsOfURL:queryUrl];
    
    if (data == nil) return nil;
    
    NSError *error = nil;
    id object = [NSJSONSerialization JSONObjectWithData:data
                                                options:NSJSONReadingMutableContainers
                                                  error:&error];
    
    if(error)
    {
        NSLog(@"Malformed JSON data returned by Facebook status query");
    }
    
    if ([object isKindOfClass:[NSDictionary class]])
    {
        NSDictionary *results = object;
        NSArray *statuses = results[@"data"];
        if ([statuses count] > 0) {
            NSDictionary *latestStatus = statuses[0];
            return latestStatus[@"message"];
        }
    }
    else
    {
        NSLog(@"Unrecognised data type for returned JSON object:\n\n%@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    }
    return nil;
}

@end
