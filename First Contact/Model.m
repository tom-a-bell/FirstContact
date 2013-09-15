//
//  Model.m
//  First Contact
//
//  Created by Tom Bell on 04/07/2013.
//  Copyright (c) 2013 Tom Bell. All rights reserved.
//

#import "Model.h"
#import "Contact.h"
#import <math.h>

@implementation Model

@dynamic date;
@dynamic alpha;
@dynamic theta;

- (NSNumber *)priorityForContact:(Contact *)contact
{
    NSNumber *hypothesis = [self hypothesisForContact:contact];
    if (hypothesis.doubleValue < 1.0e-6) hypothesis = [NSNumber numberWithDouble:0];
    return hypothesis;
}

// Compute the logistic regression hypothesis for the given contact using the sigmoid function
- (NSNumber *)hypothesisForContact:(Contact *)contact
{
    // Create the feature and parameter vectors
    NSArray *featureVector = [contact getFeatures];
    NSArray *parameterVector = self.theta;
    
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
    self.alpha = [model.alpha copy];
    self.theta = [model.theta copy];
    
    // Create the feature and parameter vectors
    NSArray *featureVector = [contact getFeatures];
    NSMutableArray *theta  = [NSMutableArray new];
    
    long n = [featureVector count];
    double y = (double)selected;
    double h = [self hypothesisForContact:contact].doubleValue;
    double alpha = model.alpha.doubleValue;
    
    for (int i = 0; i < n; i++)
    {
        // Compute the gradient of the cost function, dJ/dtheta_i
        double gradient = (h - y) * [featureVector[i] doubleValue];
        
        // Use stochastic gradient descent to update or add the value for theta_i
        if (i < [model.theta count])
            [theta addObject:[NSNumber numberWithDouble:([model.theta[i] doubleValue] - alpha * gradient)]];
        else
            [theta addObject:[NSNumber numberWithDouble:(-alpha * gradient)]];
    }
    
    // Store the updated parameter values
    self.date = [NSDate date];
    self.theta = [theta copy];
}

@end
