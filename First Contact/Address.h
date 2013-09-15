//
//  Address.h
//  First Contact
//
//  Created by Tom Bell on 15/07/2013.
//  Copyright (c) 2013 Tom Bell. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Contact;

@interface Address : NSManagedObject

@property (nonatomic, retain) NSString * city;
@property (nonatomic, retain) NSString * country;
@property (nonatomic, retain) NSString * postcode;
@property (nonatomic, retain) NSString * region;
@property (nonatomic, retain) NSString * street;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) Contact *contact;

- (NSString *)fullAddress;

@end
