//
//  ContactLogicTests.m
//  First Contact
//
//  Created by Tom Bell on 17/09/2013.
//  Copyright (c) 2013 Tom Bell. All rights reserved.
//

#import "ContactLogicTests.h"

#import "Contact.h"

@implementation ContactLogicTests

// The setUp method is called automatically before each test-case method (methods whose name starts with 'test').
- (void) setUp {
    NSLog(@"%@ setUp", self.name);
    contact = [[Contact alloc] init];
    STAssertNotNil(contact, @"Cannot create Contact instance");
}

// The tearDown method is called automatically after each test-case method (methods whose name starts with 'test').
- (void) tearDown {
    NSLog(@"%@ tearDown", self.name);
}

// Tests the daysToNearestBirthday: method for a birthday today.
- (void) testDaysToNearestBirthdayToday {
    NSLog(@"%@ start", self.name);

    NSDate *birthday = [NSDate date];

    STAssertTrue([[contact daysToNearestBirthday:birthday] isEqualTo:[NSNumber numberWithInteger:0]], @"");
    NSLog(@"%@ end", self.name);
}

// Tests the daysToNearestBirthday: method for a birthday 30 days in the past.
- (void) testDaysToNearestBirthday30daysInPast {
    NSLog(@"%@ start", self.name);

    NSDate *birthday = [NSDate dateWithTimeIntervalSinceNow:(-30 * 24 * 60 * 60)];

    STAssertTrue([[contact daysToNearestBirthday:birthday] isEqualTo:[NSNumber numberWithInteger:30]], @"");
    NSLog(@"%@ end", self.name);
}

// Tests the daysToNearestBirthday: method for a birthday 30 days in the future.
- (void) testDaysToNearestBirthday30daysInFuture {
    NSLog(@"%@ start", self.name);

    NSDate *birthday = [NSDate dateWithTimeIntervalSinceNow:(+30 * 24 * 60 * 60)];

    STAssertTrue([[contact daysToNearestBirthday:birthday] isEqualTo:[NSNumber numberWithInteger:30]], @"");
    NSLog(@"%@ end", self.name);
}

// Tests the daysToNearestBirthday: method for a birthday 183 days in the past.
- (void) testDaysToNearestBirthday183daysInPast {
    NSLog(@"%@ start", self.name);

    NSDate *birthday = [NSDate dateWithTimeIntervalSinceNow:(-183 * 24 * 60 * 60)];

    STAssertTrue([[contact daysToNearestBirthday:birthday] isEqualTo:[NSNumber numberWithInteger:182]], @"");
    NSLog(@"%@ end", self.name);
}

// Tests the daysToNearestBirthday: method for a birthday 10 years in the past.
- (void) testDaysToNearestBirthday10yearsInPast {
    NSLog(@"%@ start", self.name);

    NSDate *birthday = [NSDate date];
    NSDateComponents *birthdayComponents = [[NSCalendar currentCalendar]
                                            components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:birthday];
    [birthdayComponents setYear:birthdayComponents.year - 10];
    birthday = [[NSCalendar currentCalendar] dateFromComponents:birthdayComponents];

    STAssertTrue([[contact daysToNearestBirthday:birthday] isEqualTo:[NSNumber numberWithInteger:0]], @"");
    NSLog(@"%@ end", self.name);
}

// Tests the daysToNearestBirthday: method for a birthday 10 years in the future.
- (void) testDaysToNearestBirthday10yearsInFuture {
    NSLog(@"%@ start", self.name);

    NSDate *birthday = [NSDate date];
    NSDateComponents *birthdayComponents = [[NSCalendar currentCalendar]
                                            components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:birthday];
    [birthdayComponents setYear:birthdayComponents.year + 10];
    birthday = [[NSCalendar currentCalendar] dateFromComponents:birthdayComponents];

    STAssertTrue([[contact daysToNearestBirthday:birthday] isEqualTo:[NSNumber numberWithInteger:0]], @"");
    NSLog(@"%@ end", self.name);
}

// Tests the daysToNearestBirthday: method for a birthday 10 years and 50 days in the past.
- (void) testDaysToNearestBirthday10years50daysInPast {
    NSLog(@"%@ start", self.name);

    NSDate *birthday = [NSDate date];
    NSDateComponents *birthdayComponents = [[NSCalendar currentCalendar]
                                            components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:birthday];
    [birthdayComponents setYear:birthdayComponents.year - 10];
    [birthdayComponents setDay:birthdayComponents.day - 50];
    birthday = [[NSCalendar currentCalendar] dateFromComponents:birthdayComponents];
    NSLog(@"Test birthday is %@", birthday);

    STAssertTrue([[contact daysToNearestBirthday:birthday] isEqualTo:[NSNumber numberWithInteger:50]], @"");
    NSLog(@"%@ end", self.name);
}

// Tests the daysToNearestBirthday: method for a birthday 10 years ago and 50 days ahead.
- (void) testDaysToNearestBirthday10yearsInPast50daysAhead {
    NSLog(@"%@ start", self.name);

    NSDate *birthday = [NSDate date];
    NSDateComponents *birthdayComponents = [[NSCalendar currentCalendar]
                                            components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:birthday];
    [birthdayComponents setYear:birthdayComponents.year - 10];
    [birthdayComponents setDay:birthdayComponents.day + 50];
    birthday = [[NSCalendar currentCalendar] dateFromComponents:birthdayComponents];
    NSLog(@"Test birthday is %@", birthday);

    STAssertTrue([[contact daysToNearestBirthday:birthday] isEqualTo:[NSNumber numberWithInteger:50]], @"");
    NSLog(@"%@ end", self.name);
}

@end
