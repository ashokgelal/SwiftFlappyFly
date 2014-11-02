//
//  Obstacle.m
//  FloppyFly
//
//  Created by Ashok Gelal on 11/1/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Obstacle.h"

#define ARC4RANDOM_MAX 0x100000000

static const CGFloat minimumYPositionTopPipe = 128.f;
static const CGFloat maximumYPositionBottomPipe = 440.f;
static const CGFloat pipeDistance = 142.f;
static const CGFloat maximumYPositionTopPipe = maximumYPositionBottomPipe - pipeDistance;

@implementation Obstacle {
    CCNode *_topPipe;
    CCNode *_bottomPipe;
}

- (void) didLoadFromCCB {
    _topPipe.physicsBody.collisionType = @"level";
    _topPipe.physicsBody.sensor = TRUE;
    _bottomPipe.physicsBody.collisionType = @"level";
    _bottomPipe.physicsBody.sensor = TRUE;
}

-(void)setupRandomPosition {
    CGFloat random = ((double)arc4random() / ARC4RANDOM_MAX);
    CGFloat range = maximumYPositionTopPipe - minimumYPositionTopPipe;
    _topPipe.position = ccp(_topPipe.position.x, minimumYPositionTopPipe + (random * range));
    _bottomPipe.position = ccp(_bottomPipe.position.x, _topPipe.position.y + pipeDistance);
}

@end