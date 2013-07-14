//
//  Contact.m
//  SmartContacts
//
//  Created by Tom Bell on 02/07/2013.
//  Copyright (c) 2013 Tom Bell. All rights reserved.
//

#import "Contact.h"
#import "Address.h"
#import "Email.h"
#import "Phone.h"
#import "Usage.h"

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
@dynamic facebookID;
@dynamic facebookStatus;

@dynamic hasEmail;
@dynamic hasPhone;
@dynamic hasAddress;
@dynamic accessedOn;

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

/* Compute the features describing the priority of the contact
 The features included are:
 0) 1 (constant used in models);
 1) total number of previous views;
 2) number of views in the last week;
 3) number of views in the last day;
 4) proximity to the nearest birthday;
 5) 1 if contact is the user, 0 otherwise;
 */
- (NSArray *)getFeatures
{
    NSMutableArray *features = [NSMutableArray new];
    
    // Create a sort descriptor to sort the view timestamps by date (most recent first)
    NSSortDescriptor *sortByDate = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:NO];
    
    // Fetch the previous view timestamps for this contact
    NSMutableArray *viewEntries = [NSMutableArray new];
    for (Usage *entry in [self.accessedOn sortedArrayUsingDescriptors:@[sortByDate]])
    {
        [viewEntries addObject:entry.date];
    }
    
    // Set the first feature to be 1 for convenience in logistic regression models
    [features addObject:[NSNumber numberWithInteger:1]];
    
    // Add the total number of previous views as a feature
    NSNumber *totalViews = [NSNumber numberWithUnsignedInteger:[viewEntries count]];
    [features addObject:totalViews];
    
    // Add the number of previous views in the last week as a feature
    NSDate *today = [NSDate date];
    NSDate *lastWeek = [today dateByAddingTimeInterval: -604800];
    NSArray *weekEntries = [viewEntries filteredArrayUsingPredicate:
                            [NSPredicate predicateWithFormat:@"SELF  >= %@", lastWeek]];
    NSNumber *weekViews = [NSNumber numberWithUnsignedInteger:[weekEntries count]];
    [features addObject:weekViews];
    
    // Add the number of previous views in the last day as a feature
    NSDate *lastDay = [today dateByAddingTimeInterval: -86400];
    NSArray *dayEntries = [viewEntries filteredArrayUsingPredicate:
                           [NSPredicate predicateWithFormat:@"SELF  >= %@", lastDay]];
    NSNumber *dayViews = [NSNumber numberWithUnsignedInteger:[dayEntries count]];
    [features addObject:dayViews];
    
    // Add the number of days to the most recent birthday as a feature
    NSDateComponents *todayComponents = [[NSCalendar currentCalendar]
                                         components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:today];
    NSDateComponents *birthdayComponents = [[NSCalendar currentCalendar]
                                            components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:self.birthday];
    [birthdayComponents setYear:todayComponents.year];
    NSDate *birthday = [[NSCalendar currentCalendar] dateFromComponents:birthdayComponents];
    NSNumber *daysToBirthday = [NSNumber numberWithInt:
                                (183 - abs([birthday timeIntervalSinceNow]) / (24 * 60 * 60))];
    [features addObject:daysToBirthday];
    
    // Add a feature indicating if the contact is the user themself (=10)
    if ([self.relation isEqualToString:@"Me"]) [features addObject:[NSNumber numberWithInteger:10]];
    else [features addObject:[NSNumber numberWithInteger:0]];
    
    // Return an immutable copy of the feature array
    return [features copy];
}

@end
