//
//  Model.h
//  SmartContacts
//
//  Created by Tom Bell on 04/07/2013.
//  Copyright (c) 2013 Tom Bell. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Contact.h"

@interface Model : NSManagedObject

@property (nonatomic, retain) NSDate   * date;
@property (nonatomic, retain) NSNumber * alpha;
@property (nonatomic, retain) NSArray  * theta;
@property (nonatomic, retain) NSNumber * theta0;
@property (nonatomic, retain) NSNumber * theta1;
@property (nonatomic, retain) NSNumber * theta2;
@property (nonatomic, retain) NSNumber * theta3;
@property (nonatomic, retain) NSNumber * theta4;
@property (nonatomic, retain) NSNumber * theta5;
@property (nonatomic, retain) NSNumber * theta6;

- (NSNumber *)priorityForContact:(Contact *)contact;
- (NSNumber *)costForContact:(Contact *)contact wasSelected:(BOOL)selected;
- (void)updateParametersUsingModel:(Model *)model forContact:(Contact *)contact wasSelected:(BOOL)selected;

@end
