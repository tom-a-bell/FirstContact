//
//  ContactTableCellView.h
//  SmartContacts
//
//  Created by Tom Bell on 19/06/2013.
//  Copyright (c) 2013 Tom Bell. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ContactTableCellView : NSTableCellView {
@private
    IBOutlet NSButton *detailsButton;
    IBOutlet NSButton *deleteButton;
    IBOutlet NSTextField *subTitleTextField;
    BOOL _isSmallSize;
}

@property(assign) NSButton *detailsButton;
@property(assign) NSButton *deleteButton;
@property(assign) NSTextField *subTitleTextField;

- (void)layoutViewsForSmallSize:(BOOL)smallSize animated:(BOOL)animated;

@end
