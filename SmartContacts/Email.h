//
//  Email.h
//  SmartContacts
//
//  Created by Tom Bell on 15/07/2013.
//  Copyright (c) 2013 Tom Bell. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Contact;

@interface Email : NSManagedObject

@property (nonatomic, retain) NSString * address;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) Contact *contact;

@end
