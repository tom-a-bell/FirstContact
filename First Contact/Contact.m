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
@dynamic normalButton;
@dynamic pushedButton;

@dynamic hasEmail;
@dynamic hasPhone;
@dynamic hasAddress;
@dynamic accessedOn;

@synthesize fullName = _fullName;
@synthesize tag = _tag;
@synthesize normalButtonImage = _normalButtonImage;
@synthesize pushedButtonImage = _pushedButtonImage;

- (NSString *)fullName
{
    if (_fullName) return _fullName;

    _fullName = [@[self.firstName, self.lastName] componentsJoinedByString:@" "];
    if ([_fullName isEqualToString:@" "])
    {
        _fullName = self.company;
    }

    return _fullName;
}

- (NSString *)tag
{
    if (_tag) return _tag;

    // Determine what to show as the tagline based on available information
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"UpcomingBirthdays"] &&
        [[self daysToNextBirthday:self.birthday] integerValue] == 0)
    {
        _tag = @"Birthday today!";
    }
    else if ([[NSUserDefaults standardUserDefaults] boolForKey:@"UpcomingBirthdays"] &&
             [[self daysToNextBirthday:self.birthday] integerValue] == 1)
    {
        _tag = @"Birthday tomorrow!";
    }
    else if ([[NSUserDefaults standardUserDefaults] boolForKey:@"UpcomingBirthdays"] &&
             [[self daysToNextBirthday:self.birthday] integerValue] < 15)
    {
        _tag = [NSString stringWithFormat:@"Birthday in %@ days!", [self daysToNextBirthday:self.birthday]];
    }
    else if ([[NSUserDefaults standardUserDefaults] boolForKey:@"FacebookStatus"] &&
             [self.facebookStatus length] != 0)
    {
        _tag = self.facebookStatus;
    }
    else if ([self.company length] != 0 && self.company != self.fullName)
    {
        _tag = self.company;
    }
    else if ([self.relation length] != 0)
    {
        _tag = self.relation;
    }
    
    return _tag;
}

- (NSImage *)normalButtonImage
{
    if (_normalButtonImage) return _normalButtonImage;

    if (!self.normalButton)
    {
        NSImage *image = [NSImage imageNamed:@"defaultProfile"];
        NSImage *bezel = [NSImage imageNamed:@"avatarBezel"];
        if (self.image) image = [[NSImage alloc] initWithData:self.image];
        self.normalButton = [[self createButtonImage:image withMask:nil withBezel:bezel] TIFFRepresentation];
    }

    _normalButtonImage = [[NSImage alloc] initWithData:self.normalButton];
    return _normalButtonImage;
}

- (NSImage *)pushedButtonImage
{
    if (_pushedButtonImage) return _pushedButtonImage;

    if (!self.pushedButton)
    {
        NSImage *image = [NSImage imageNamed:@"defaultProfile"];
        NSImage *mask  = [NSImage imageNamed:@"avatarMask"];
        NSImage *bezel = [NSImage imageNamed:@"avatarBezel"];
        if (self.image) image = [[NSImage alloc] initWithData:self.image];
        self.pushedButton = [[self createButtonImage:image withMask:mask withBezel:bezel] TIFFRepresentation];
    }

    _pushedButtonImage = [[NSImage alloc] initWithData:self.pushedButton];
    return _pushedButtonImage;
}

- (void)updateProperties
{
    self.normalButton = nil;
    _normalButtonImage = nil;
    [self normalButtonImage];

    self.pushedButton = nil;
    _pushedButtonImage = nil;
    [self pushedButtonImage];

    _fullName = nil;
    [self fullName];

    _tag = nil;
    [self tag];
}

- (BOOL)isValid
{
    return (([self.firstName length] > 0) ||
            ([self.lastName length] > 0) ||
            ([self.company length] > 0));
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
    NSNumber *daysToBirthday = [self daysToNearestBirthday:self.birthday];
    [features addObject:[NSNumber numberWithInteger:(183 - daysToBirthday.integerValue)]];

    // Add a feature indicating if the contact is the user themself
    if ([self.relation isEqualToString:@"Me"])
        [features addObject:[NSNumber numberWithInteger:1]];
    else
        [features addObject:[NSNumber numberWithInteger:0]];
    
    // Return an immutable copy of the feature array
    return [features copy];
}

- (NSNumber *)daysToNextBirthday:(NSDate *)dateOfBirth
{
    NSNumber *daysToBirthday;
    if (dateOfBirth)
    {
        NSDate *today;
        NSDate *nextBirthday;
        NSDate *now = [NSDate date];
        
        NSDateComponents *todayComponents = [[NSCalendar currentCalendar]
                                             components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:now];
        NSDateComponents *birthdayComponents = [[NSCalendar currentCalendar]
                                                components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:dateOfBirth];

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

- (NSNumber *)daysToNearestBirthday:(NSDate *)dateOfBirth
{
    NSNumber *daysToBirthday;
    if (dateOfBirth)
    {
        NSDate *today;
        NSDate *nearestBirthday;
        NSDate *now = [NSDate date];
        
        NSDateComponents *todayComponents = [[NSCalendar currentCalendar]
                                             components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:now];
        NSDateComponents *birthdayComponents = [[NSCalendar currentCalendar]
                                                components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:dateOfBirth];

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

    if (!image) return finalImage;

    // Create a CGImageRef from the NSImage in order to apply a circular mask
    CGImageRef imageRef = [image CGImageForProposedRect:NULL context:NULL hints:NULL];

    // Create the circular mask
    CGImageRef circularMask = [[NSImage imageNamed:@"circularMask"] CGImageForProposedRect:NULL context:NULL hints:NULL];
    CGImageRef maskRef = CGImageMaskCreate(CGImageGetWidth(circularMask),
                                           CGImageGetHeight(circularMask),
                                           CGImageGetBitsPerComponent(circularMask),
                                           CGImageGetBitsPerPixel(circularMask),
                                           CGImageGetBytesPerRow(circularMask),
                                           CGImageGetDataProvider(circularMask), NULL, YES);

    CGImageRef maskedRef = CGImageCreateWithMask(imageRef, maskRef);
    NSImage *base = [[NSImage alloc] initWithCGImage:maskedRef size:NSMakeSize(82, 82)];

    // Lock the image before drawing
    [finalImage lockFocus];

    // Draw the base image
    [base drawInRect:NSMakeRect(6, 6, 82, 82) fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];

    // Draw the mask overlay image
    if (mask)
    {
        float maskWidth = [mask size].width;
        float maskHeight = [mask size].height;
        [mask drawInRect:NSMakeRect((94-maskWidth)/2, (92-maskHeight)/2+1, maskWidth, maskHeight)
                fromRect:NSZeroRect
               operation:NSCompositeSourceOver fraction:0.2];
    }

    // Draw the bezel overlay image
    if (bezel)
    {
        [bezel drawInRect:NSMakeRect(0, 0, 94, 92)
                 fromRect:NSZeroRect
                operation:NSCompositeSourceOver fraction:1.0];
    }

    // Release the image
    [finalImage unlockFocus];

    // Release the Core Foundation objects
    CFRelease(maskRef);
    CFRelease(maskedRef);

    return finalImage;
}

// Crop and scale the supplied image to the standard portrait image dimensions
- (NSImage *)createPortraitImage:(NSImage *)image
{
    CGFloat portraitSize = 164;

    // Crop the image to a square around its centre
    NSImage *croppedImage = [self cropImage:image];

    // Resample the cropped image to the standard portrait size if it is larger
    NSImage *finalImage = nil;
    if ([croppedImage size].width > portraitSize)
    {
        finalImage = [self scaleImage:croppedImage toSize:NSMakeSize(portraitSize, portraitSize)];
    }
    else
    {
        finalImage = croppedImage;
    }

    return finalImage;
}

// Crop the supplied image to square format
- (NSImage *)cropImage:(NSImage *)image
{
    if (![image isValid]) return nil;

    // Determine the original pixel dimensions of the NSImage by finding the maximum size of its image representations
    NSInteger width  = 0;
    NSInteger height = 0;

    // Determine the correct image dimensions of the file
    for (NSImageRep *imageRep in [image representations])
    {
        if ([imageRep pixelsWide] > width)  width  = [imageRep pixelsWide];
        if ([imageRep pixelsHigh] > height) height = [imageRep pixelsHigh];
    }

    NSSize imageSize = NSMakeSize((CGFloat)width, (CGFloat)height);
    NSImage * originalImage = [[NSImage alloc] initWithSize:imageSize];

    [originalImage addRepresentations:[image representations]];

    if (imageSize.width == imageSize.height) return originalImage;

    // Determine the smaller of the two image dimensions to use for the square crop size
    CGFloat size = MIN(imageSize.width, imageSize.height);

    // Determine the appropriate origin for the centre of the square image
    CGFloat x = (imageSize.width  - size) * 0.5;
    CGFloat y = (imageSize.height - size) * 0.5;

    // Create a CGImageRef of the NSImage from which to produce the cropped version
    CGImageRef imageRef = [originalImage CGImageForProposedRect:NULL context:NULL hints:NULL];

    // Crop the image to the square region around its centre
    CGImageRef croppedImageRef = CGImageCreateWithImageInRect(imageRef, CGRectMake(x, y, size, size));

    NSImage *croppedImage = [[NSImage alloc] initWithCGImage:croppedImageRef size:NSMakeSize(size, size)];

    // Release the Core Foundation objects
    CFRelease(croppedImageRef);

    return croppedImage;
}

- (NSImage *)scaleImage:(NSImage *)image toSize:(NSSize)targetSize
{
    if (![image isValid]) return nil;

    NSSize imageSize = [image size];

    if (NSEqualSizes(imageSize, targetSize)) return image;

    CGFloat imageWidth  = imageSize.width;
    CGFloat imageHeight = imageSize.height;

    CGFloat targetWidth  = targetSize.width;
    CGFloat targetHeight = targetSize.height;

    CGFloat widthFactor  = targetWidth / imageWidth;
    CGFloat heightFactor = targetHeight / imageHeight;

    CGFloat scaleFactor  = 0.0;
    if (widthFactor < heightFactor)
    {
        scaleFactor = widthFactor;
    }
    else
    {
        scaleFactor = heightFactor;
    }

    CGFloat scaledWidth  = imageWidth  * scaleFactor;
    CGFloat scaledHeight = imageHeight * scaleFactor;

    NSPoint thumbnailPoint = NSZeroPoint;
    if (widthFactor > heightFactor)
    {
        thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
    }
    else if (widthFactor < heightFactor)
    {
        thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
    }

    NSImage *scaledImage = [[NSImage alloc] initWithSize:targetSize];

    // Lock the image before drawing
    [scaledImage lockFocus];

    NSRect thumbnailRect;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
            
    [image drawInRect:thumbnailRect fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];

    // Release the image
    [scaledImage unlockFocus];

    return scaledImage;
}

@end
