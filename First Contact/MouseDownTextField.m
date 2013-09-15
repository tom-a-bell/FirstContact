//
//  MouseDownTextField.m
//  First Contact
//
//  Created by Tom Bell on 26/06/2013.
//  Copyright (c) 2013 Tom Bell. All rights reserved.
//

#import "MouseDownTextField.h"

@implementation MouseDownTextField

-(void)mouseDown:(NSEvent *)event
{
    [self.delegate mouseDownTextFieldClicked:self];
}

-(void)mouseUp:(NSEvent *)event
{
    [self.delegate mouseUpTextFieldClicked:self];
}

-(void)setDelegate:(id<MouseDownTextFieldDelegate>)delegate
{
    [super setDelegate:delegate];
}

-(id)delegate
{
    return [super delegate];
}

@end
