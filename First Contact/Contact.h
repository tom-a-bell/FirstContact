//
//  Contact.h
//  First Contact
//
//  Created by Tom Bell on 02/07/2013.
//  Copyright (c) 2013 Tom Bell. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Address, Email, Phone, Model, Usage;

@interface Contact : NSManagedObject

@property (nonatomic, retain) NSData   * image;
@property (nonatomic, retain) NSString * firstName;
@property (nonatomic, retain) NSString * lastName;
@property (nonatomic, retain) NSString * relation;
@property (nonatomic, retain) NSString * company;
@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSString * phone;
@property (nonatomic, retain) NSString * street;
@property (nonatomic, retain) NSString * city;
@property (nonatomic, retain) NSString * postcode;
@property (nonatomic, retain) NSString * country;
@property (nonatomic, retain) NSDate   * birthday;
@property (nonatomic, retain) NSNumber * priority;
@property (nonatomic, retain) NSNumber * facebookID;
@property (nonatomic, retain) NSString * facebookStatus;
@property (nonatomic, retain) NSData   * normalButton;
@property (nonatomic, retain) NSData   * pushedButton;

@property (nonatomic, retain) NSSet    * hasEmail;
@property (nonatomic, retain) NSSet    * hasPhone;
@property (nonatomic, retain) NSSet    * hasAddress;
@property (nonatomic, retain) NSSet    * accessedOn;

@property (readonly, retain) NSString  * fullName;
@property (readonly, retain) NSString  * tag;
@property (readonly, retain) NSImage   * normalButtonImage;
@property (readonly, retain) NSImage   * pushedButtonImage;

- (void)updateProperties;
- (BOOL)isValid;

- (NSString *)fullAddress;

- (void)setPriorityForModel:(Model *)model;
- (NSArray *)getFeatures;

- (NSNumber *)daysToNextBirthday:(NSDate *)dateOfBirth;
- (NSNumber *)daysToNearestBirthday:(NSDate *)dateOfBirth;

- (NSImage *)createPortraitImage:(NSImage *)image;

@end

@interface Contact (CoreDataGeneratedAccessors)

- (void)addHasEmailObject:(Email *)value;
- (void)removeHasEmailObject:(Email *)value;
- (void)addHasEmail:(NSSet *)values;
- (void)removeHasEmail:(NSSet *)values;

- (void)addHasPhoneObject:(Phone *)value;
- (void)removeHasPhoneObject:(Phone *)value;
- (void)addHasPhone:(NSSet *)values;
- (void)removeHasPhone:(NSSet *)values;

- (void)addHasAddressObject:(Address *)value;
- (void)removeHasAddressObject:(Address *)value;
- (void)addHasAddress:(NSSet *)values;
- (void)removeHasAddress:(NSSet *)values;

- (void)addAccessedOnObject:(Usage *)value;
- (void)removeAccessedOnObject:(Usage *)value;
- (void)addAccessedOn:(NSSet *)values;
- (void)removeAccessedOn:(NSSet *)values;

@end
