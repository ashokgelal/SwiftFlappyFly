//
//  Goal.m
//  FloppyFly
//
//  Created by Ashok Gelal on 11/1/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Goal.h"

@implementation Goal

- (void) didLoadFromCCB {
    self.physicsBody.collisionType = @"goal";
    self.physicsBody.sensor = TRUE;
}

@end