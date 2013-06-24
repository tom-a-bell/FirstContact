//
//  Contact.h
//  SmartContacts
//
//  Created by Tom Bell on 22/06/2013.
//  Copyright (c) 2013 Tom Bell. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Contact : NSManagedObject

@property (nonatomic, retain) NSString * city;
@property (nonatomic, retain) NSData   * image;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * phone;
@property (nonatomic, retain) NSString * postcode;
@property (nonatomic, retain) NSString * street;

-(NSDictionary *)getContactList;

@end
