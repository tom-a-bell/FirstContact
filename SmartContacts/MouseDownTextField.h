//
//  MouseDownTextField.h
//  SmartContacts
//
//  Created by Tom Bell on 26/06/2013.
//  Copyright (c) 2013 Tom Bell. All rights reserved.
//

#import <Appkit/Appkit.h>
@class MouseDownTextField;

@protocol MouseDownTextFieldDelegate <NSTextFieldDelegate>
-(void) mouseDownTextFieldClicked:(MouseDownTextField *)textField;
-(void) mouseUpTextFieldClicked:(MouseDownTextField *)textField;
@end

@interface MouseDownTextField : NSTextField

@property(assign) id<MouseDownTextFieldDelegate> delegate;

@end
