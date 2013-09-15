//
//  Phone.h
//  First Contact
//
//  Created by Tom Bell on 15/07/2013.
//  Copyright (c) 2013 Tom Bell. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Contact;

@interface Phone : NSManagedObject

@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSString * number;
@property (nonatomic, retain) Contact *contact;

@end
