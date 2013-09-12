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

- (NSNumber *)priorityForContact:(Contact *)contact;
- (NSNumber *)costForContact:(Contact *)contact wasSelected:(BOOL)selected;
- (void)updateParametersUsingModel:(Model *)model forContact:(Contact *)contact wasSelected:(BOOL)selected;

@end
