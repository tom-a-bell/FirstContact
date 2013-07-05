//
//  Contact.h
//  SmartContacts
//
//  Created by Tom Bell on 02/07/2013.
//  Copyright (c) 2013 Tom Bell. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

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
@property (nonatomic, retain) NSSet *accessedOn;

- (NSString *)fullName;
- (NSString *)fullAddress;
- (NSArray *)getFeatures;

@end

@interface Contact (CoreDataGeneratedAccessors)

- (void)addAccessedOnObject:(NSManagedObject *)value;
- (void)removeAccessedOnObject:(NSManagedObject *)value;
- (void)addAccessedOn:(NSSet *)values;
- (void)removeAccessedOn:(NSSet *)values;

@end
