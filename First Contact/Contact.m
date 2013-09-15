//
//  Contact.m
//  First Contact
//
//  Created by Tom Bell on 02/07/2013.
//  Copyright (c) 2013 Tom Bell. All rights reserved.
//

#import "Contact.h"
#import "Address.h"
#import "Email.h"
#import "Phone.h"
#import "Model.h"
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
@dynamic priority;
@dynamic facebookID;
@dynamic facebookStatus;

@dynamic hasEmail;
@dynamic hasPhone;
@dynamic hasAddress;
@dynamic accessedOn;

@synthesize name = _name;
@synthesize tag = _tag;
//@synthesize priority = _priority;
@synthesize normalButton = _normalButton;
@synthesize pushedButton = _pushedButton;

- (NSString *)name
{
//    if (_name) return _name;
    _name = self.fullName;
    return _name;
}

- (void)setName:(NSString *)name
{
    _name = name;
}

- (NSString *)tag
{
//    if (_tag) return _tag;
    
    _tag = @"";
    
    // Determine what to show as the tagline based on available information
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"UpcomingBirthdays"] &&
        [[self daysToNextBirthday] integerValue] == 0)
    {
        _tag = @"Birthday today!";
    }
    else if ([[NSUserDefaults standardUserDefaults] boolForKey:@"UpcomingBirthdays"] &&
        [[self daysToNextBirthday] integerValue] == 1)
    {
        _tag = @"Birthday tomorrow!";
    }
    else if ([[NSUserDefaults standardUserDefaults] boolForKey:@"UpcomingBirthdays"] &&
        [[self daysToNextBirthday] integerValue] < 15)
    {
        _tag = [NSString stringWithFormat:@"Birthday in %@ days!", [self daysToNextBirthday]];
    }
    else if ([[NSUserDefaults standardUserDefaults] boolForKey:@"FacebookStatus"] &&
             self.facebookStatus != nil && ![self.facebookStatus isEqualToString:@""])
    {
        _tag = self.facebookStatus;
    }
    else if (self.company != nil && ![self.company isEqualToString:@""])
    {
        _tag = self.company;
    }
    else if (self.relation != nil && ![self.relation isEqualToString:@""])
    {
        _tag = self.relation;
    }
    
    return _tag;
}

- (void)setTag:(NSString *)tag
{
    _tag = tag;
}

- (NSImage *)normalButton
{
    if (_normalButton) return _normalButton;
    
    NSImage *image = [NSImage imageNamed:@"defaultProfile"];
    NSImage *bezel = [NSImage imageNamed:@"avatarBezel"];
    if (self.image) image = [[NSImage alloc] initWithData:self.image];
    _normalButton = [self createButtonImage:image withMask:nil withBezel:bezel];
    
    return _normalButton;
}

- (void)setNormalButton:(NSImage *)image
{
    NSImage *bezel = [NSImage imageNamed:@"avatarBezel"];
    _normalButton = [self createButtonImage:image withMask:nil withBezel:bezel];
}

- (NSImage *)pushedButton
{
    if (_pushedButton) return _pushedButton;
    
    NSImage *image = [NSImage imageNamed:@"defaultProfile"];
    NSImage *mask  = [NSImage imageNamed:@"avatarMask"];
    NSImage *bezel = [NSImage imageNamed:@"avatarBezel"];
    if (self.image) image = [[NSImage alloc] initWithData:self.image];
    _pushedButton = [self createButtonImage:image withMask:mask withBezel:bezel];
    
    return _pushedButton;
}

- (void)setPushedButton:(NSImage *)image
{
    NSImage *mask  = [NSImage imageNamed:@"avatarMask"];
    NSImage *bezel = [NSImage imageNamed:@"avatarBezel"];
    _pushedButton = [self createButtonImage:image withMask:mask withBezel:bezel];
}

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

- (void)setPriorityForModel:(Model *)model
{
    self.priority = [model priorityForContact:self];
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
    NSNumber *weekViews = [NSNumber numberWithInteger:[weekEntries count]];
    [features addObject:weekViews];
    
    // Add the number of previous views in the last day as a feature
    NSDate *lastDay = [today dateByAddingTimeInterval: -86400];
    NSArray *dayEntries = [viewEntries filteredArrayUsingPredicate:
                           [NSPredicate predicateWithFormat:@"SELF  >= %@", lastDay]];
    NSNumber *dayViews = [NSNumber numberWithInteger:[dayEntries count]];
    [features addObject:dayViews];
    
    // Add the number of days to the most recent birthday as a feature
    NSNumber *daysToBirthday = [self daysToNearestBirthday];
    [features addObject:[NSNumber numberWithInteger:(183 - daysToBirthday.integerValue)]];

    // Add a feature indicating if the contact is the user themself
    if ([self.relation isEqualToString:@"Me"])
        [features addObject:[NSNumber numberWithInteger:1]];
    else
        [features addObject:[NSNumber numberWithInteger:0]];
    
    // Return an immutable copy of the feature array
    return [features copy];
}

- (NSNumber *)daysToNextBirthday
{
    NSNumber *daysToBirthday;
    if (self.birthday)
    {
        NSDate *today;
        NSDate *nextBirthday;
        NSDate *now = [NSDate date];
        
        NSDateComponents *todayComponents = [[NSCalendar currentCalendar]
                                             components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:now];
        NSDateComponents *birthdayComponents = [[NSCalendar currentCalendar]
                                                components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:self.birthday];

        [birthdayComponents setYear:todayComponents.year];
        today = [[NSCalendar currentCalendar] dateFromComponents:todayComponents];
        nextBirthday = [[NSCalendar currentCalendar] dateFromComponents:birthdayComponents];

        // Use next year's birthday if this year's has already passed
        if ([nextBirthday timeIntervalSinceDate:today] < 0)
        {
            [birthdayComponents setYear:todayComponents.year + 1];
            nextBirthday = [[NSCalendar currentCalendar] dateFromComponents:birthdayComponents];
        }
        
        daysToBirthday = [NSNumber numberWithInteger:([nextBirthday timeIntervalSinceDate:today] / (24 * 60 * 60))];
    }
    else
    {
        daysToBirthday = [NSNumber numberWithInteger:365];
    }
    return daysToBirthday;
}

- (NSNumber *)daysToNearestBirthday
{
    NSNumber *daysToBirthday;
    if (self.birthday)
    {
        NSDate *today;
        NSDate *nearestBirthday;
        NSDate *now = [NSDate date];
        
        NSDateComponents *todayComponents = [[NSCalendar currentCalendar]
                                             components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:now];
        NSDateComponents *birthdayComponents = [[NSCalendar currentCalendar]
                                                components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:self.birthday];

        [birthdayComponents setYear:todayComponents.year];
        today = [[NSCalendar currentCalendar] dateFromComponents:todayComponents];
        nearestBirthday = [[NSCalendar currentCalendar] dateFromComponents:birthdayComponents];

        daysToBirthday = [NSNumber numberWithInteger:abs([nearestBirthday timeIntervalSinceDate:today] / (24 * 60 * 60))];
        if (daysToBirthday.integerValue > 183) daysToBirthday = [NSNumber numberWithInteger:(365 - daysToBirthday.integerValue)];
    }
    else
    {
        daysToBirthday = [NSNumber numberWithInt:183];
    }
    return daysToBirthday;
}

- (NSImage *)createButtonImage:(NSImage *)image withMask:(NSImage *)mask withBezel:(NSImage *)bezel
{
    NSImage *finalImage = [[NSImage alloc] initWithSize:NSMakeSize(94, 92)];
    
    if (image == nil)
    {
        return finalImage;
    }
    
    // Create a CGImageRef from the NSImage in order to apply a circular mask
    CGImageRef imageRef = [image CGImageForProposedRect:NULL context:NULL hints:NULL];
    
    // Create the mask
    CGImageRef circularMask = [[NSImage imageNamed:@"circularMask"] CGImageForProposedRect:NULL context:NULL hints:NULL];
    CGImageRef maskRef = CGImageMaskCreate(CGImageGetWidth(circularMask),
                                           CGImageGetHeight(circularMask),
                                           CGImageGetBitsPerComponent(circularMask),
                                           CGImageGetBitsPerPixel(circularMask),
                                           CGImageGetBytesPerRow(circularMask),
                                           CGImageGetDataProvider(circularMask), NULL, YES);
    
    NSImage *base = [[NSImage alloc] initWithCGImage:CGImageCreateWithMask(imageRef, maskRef)
                                                size:NSMakeSize(82, 82)];
    
    [finalImage lockFocus];
    
    // Draw the base image
    [base drawInRect:NSMakeRect(6, 6, 82, 82)
            fromRect:NSZeroRect
           operation:NSCompositeSourceOver fraction:1.0];
    
    // Draw the mask overlay image
    if (mask != nil)
    {
        float maskWidth = [mask size].width;
        float maskHeight = [mask size].height;
        [mask drawInRect:NSMakeRect((94-maskWidth)/2, (92-maskHeight)/2+1, maskWidth, maskHeight)
                fromRect:NSZeroRect
               operation:NSCompositeSourceOver fraction:0.2];
    }
    
    // Draw the bezel overlay image
    if (bezel != nil)
    {
        [bezel drawInRect:NSMakeRect(0, 0, 94, 92)
                 fromRect:NSZeroRect
                operation:NSCompositeSourceOver fraction:1.0];
    }
    
    [finalImage unlockFocus];
    
    return finalImage;
}

@end
