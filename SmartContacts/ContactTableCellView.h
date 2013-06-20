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
    IBOutlet NSTextField *subTitleTextField;
    IBOutlet NSProgressIndicator *progessIndicator;
    BOOL _isSmallSize;
}

@property(assign) NSButton *detailsButton;
@property(assign) NSTextField *subTitleTextField;
@property(assign) NSProgressIndicator *progessIndicator;

- (void)layoutViewsForSmallSize:(BOOL)smallSize animated:(BOOL)animated;

@end
