//
//  ContactTableCellView.h
//  SmartContacts
//
//  Created by Tom Bell on 19/06/2013.
//  Copyright (c) 2013 Tom Bell. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ContactTableCellView : NSTableCellView
{
@private
    IBOutlet NSButton *detailsButton;
    IBOutlet NSButton *deleteButton;
    IBOutlet NSTextField *tagLine;
    BOOL _isSmallSize;
}

@property (assign) IBOutlet NSButton *detailsButton;
@property (assign) IBOutlet NSButton *deleteButton;
@property (assign) IBOutlet NSTextField *tagLine;

- (void)layoutViewsForDeleteMode:(BOOL)deleteMode animated:(BOOL)animated;
- (void)layoutViewsForSmallSize:(BOOL)smallSize animated:(BOOL)animated;

@end
