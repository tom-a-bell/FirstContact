//
//  Model.m
//  SmartContacts
//
//  Created by Tom Bell on 04/07/2013.
//  Copyright (c) 2013 Tom Bell. All rights reserved.
//

#import "Model.h"
#import "Contact.h"
#import <math.h>

@implementation Model

@dynamic date, alpha, theta0, theta1, theta2, theta3, theta4, theta5, theta6;

- (NSNumber *)priorityForContact:(Contact *)contact
{
    double hypothesis = [self hypothesisForContact:contact].doubleValue;
    if (hypothesis < 1.0e-8) hypothesis = 0;
    return [NSNumber numberWithDouble:hypothesis];
}

// Compute the logistic regression hypothesis for the given contact using the sigmoid function
- (NSNumber *)hypothesisForContact:(Contact *)contact
{
    // Create the feature and parameter vectors
    NSArray *featureVector = [contact getFeatures];
    NSArray *parameterVector = @[self.theta0, self.theta1, self.theta2, self.theta3,
                                 self.theta4, self.theta5, self.theta6];
    
    long n = MIN([featureVector count], [parameterVector count]);
    
    // Compute the product of the feature and parameter vectors
    double product = 0;
    for (int i = 0; i < n; i++)
    {
        product += [parameterVector[i] doubleValue] * [featureVector[i] doubleValue];
    }
    return [NSNumber numberWithDouble:(1.0 / (1.0 + exp(-product)))];
}

// Compute the logistic regression cost function for the given contact and selected state
- (NSNumber *)costForContact:(Contact *)contact wasSelected:(BOOL)selected;
{
    double y = (double)selected;
    double h = [self hypothesisForContact:contact].doubleValue;
    double J = -y * log(h) - (1 - y) * log(1 - h);
    return [NSNumber numberWithDouble:J];
}

- (void)updateParametersUsingModel:(Model *)model forContact:(Contact *)contact wasSelected:(BOOL)selected
{
    // Set the initial parameter values to those of the supplied model
    self.alpha  = [model.alpha copy];
    self.theta0 = [model.theta0 copy];
    self.theta1 = [model.theta1 copy];
    self.theta2 = [model.theta2 copy];
    self.theta3 = [model.theta3 copy];
    self.theta4 = [model.theta4 copy];
    self.theta5 = [model.theta5 copy];
    self.theta6 = [model.theta6 copy];
    
    // Create the feature and parameter vectors
    NSArray *featureVector = [contact getFeatures];
    NSArray *parameterVector = @[model.theta0, model.theta1, model.theta2, model.theta3,
                                 model.theta4, model.theta5, model.theta6];
    
    long n = MIN([featureVector count], [parameterVector count]);
    
    double y = (double)selected;
    double h = [self hypothesisForContact:contact].doubleValue;
    double alpha = model.alpha.doubleValue;
    
    NSMutableArray *theta = [parameterVector mutableCopy];

    for (int i = 0; i < n; i++)
    {
        double gradient = (h - y) * [featureVector[i] doubleValue];
        theta[i] = [NSNumber numberWithDouble:([theta[i] doubleValue] - alpha * gradient)];
    }
    
    // Store the updated parameter values
    self.date = [NSDate date];
    self.alpha = [model.alpha copy];
    self.theta0 = theta[0];
    self.theta1 = theta[1];
    self.theta2 = theta[2];
    self.theta3 = theta[3];
    self.theta4 = theta[4];
    self.theta5 = theta[5];
    self.theta6 = theta[6];
}

@end
