//
//  ContactTableCellView.m
//  SmartContacts
//
//  Created by Tom Bell on 19/06/2013.
//  Copyright (c) 2013 Tom Bell. All rights reserved.
//

#import "ContactTableCellView.h"

@implementation ContactTableCellView

@synthesize detailsButton = _detailsButton;
@synthesize subTitleTextField = _subTitleTextField;

- (void)layoutViewsForSmallSize:(BOOL)smallSize animated:(BOOL)animated {
    if (_isSmallSize != smallSize) {
        _isSmallSize = smallSize;
        CGFloat targetAlpha = _isSmallSize ? 0 : 1;
        if (animated) {
            [[detailsButton animator] setAlphaValue:targetAlpha];
            [[subTitleTextField animator] setAlphaValue:targetAlpha];
        } else {
            [detailsButton setAlphaValue:targetAlpha];
            [subTitleTextField setAlphaValue:targetAlpha];
        }
    }
}

@end
