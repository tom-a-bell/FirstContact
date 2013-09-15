//
//  ContactTableCellView.m
//  First Contact
//
//  Created by Tom Bell on 19/06/2013.
//  Copyright (c) 2013 Tom Bell. All rights reserved.
//

#import "ContactTableCellView.h"

@implementation ContactTableCellView

@synthesize detailsButton = _detailsButton;
@synthesize deleteButton = _deleteButton;
@synthesize tagLine = _tagLine;

- (void)layoutViewsForDeleteMode:(BOOL)deleteMode animated:(BOOL)animated {
    if (_isDeleteMode != deleteMode) {
        _isDeleteMode = deleteMode;
        CGFloat targetAlpha = _isDeleteMode ? 1 : 0;
        if (animated) {
            [[_deleteButton animator] setAlphaValue:targetAlpha];
        } else {
            [_deleteButton setAlphaValue:targetAlpha];
        }
        NSString *toolTip = _isDeleteMode ? @"Delete contact" : @"";
        [_deleteButton setToolTip:toolTip];
    }
}

- (void)layoutViewsForSmallSize:(BOOL)smallSize animated:(BOOL)animated {
    if (_isSmallSize != smallSize) {
        _isSmallSize = smallSize;
        CGFloat targetAlpha = _isSmallSize ? 0 : 1;
        if (animated) {
            [[_detailsButton animator] setAlphaValue:targetAlpha];
            [[_tagLine animator] setAlphaValue:targetAlpha];
        } else {
            [_detailsButton setAlphaValue:targetAlpha];
            [_tagLine setAlphaValue:targetAlpha];
        }
    }
}

@end
