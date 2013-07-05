//
//  Usage.h
//  SmartContacts
//
//  Created by Tom Bell on 02/07/2013.
//  Copyright (c) 2013 Tom Bell. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Contact;

@interface Usage : NSManagedObject

@property (nonatomic, retain) NSDate  *date;
@property (nonatomic, retain) Contact *contact;

@end
