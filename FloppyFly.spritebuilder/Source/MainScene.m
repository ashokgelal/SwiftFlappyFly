#import "MainScene.h"
#import "Obstacle.h"

static const CGFloat firstObstaclePosition = 280.f;
static const CGFloat distanceBetweenObstacles = 160.f;

typedef NS_ENUM(NSInteger, DrawingOrder) {
    DrawingOrderPipes,
    DrawingOrderGround,
    DrawingOrdeHero
};

@implementation MainScene {
    CCSprite *_hero;
    CCPhysicsNode *_physicsNode;
    CCNode *_ground1;
    CCNode *_ground2;
    NSArray *_grounds;
    NSTimeInterval _sinceTouch;
    NSMutableArray *_obstacles;
    CCButton *_restartButton;
    BOOL _gameOver;
    CGFloat _scrollSpeed;
    NSInteger _points;
    CCLabelTTF *_scoreLabel;
}

- (void) didLoadFromCCB {
    self.userInteractionEnabled = TRUE;
    _grounds = @[_ground1, _ground2];
    
    for (CCNode *ground in _grounds) {
        ground.physicsBody.collisionType = @"level";
        ground.zOrder = DrawingOrderGround;
    }
    _scrollSpeed = 80.f;
    
    _physicsNode.collisionDelegate = self;
    _hero.physicsBody.collisionType = @"hero";
    _hero.zOrder = DrawingOrdeHero;
    
    _obstacles = [NSMutableArray array];
    [self spawnNewObstacle];
    [self spawnNewObstacle];
    [self spawnNewObstacle];
}

- (void) update:(CCTime)delta {
    float yVelocity = clampf(_hero.physicsBody.velocity.y, -1 * MAXFLOAT, 200.f);
    _hero.physicsBody.velocity = ccp(0, yVelocity);
    _hero.position = ccp(_hero.position.x + delta * _scrollSpeed, _hero.position.y);
    
    _sinceTouch += delta;
    _hero.rotation = clampf(_hero.rotation, -30.f, 90.f);
    
    if (_hero.physicsBody.allowsRotation) {
        float angularVelocity = clampf(_hero.physicsBody.angularVelocity, -2.f, 1.f);
        _hero.physicsBody.angularVelocity = angularVelocity;
    }
    
    if (_sinceTouch > 0.5f) {
        [_hero.physicsBody applyAngularImpulse:-40000.f * delta];
    }
    
    _physicsNode.position = ccp(_physicsNode.position.x - (_scrollSpeed * delta), _physicsNode.position.y);
    
    for (CCNode *ground in _grounds) {
        CGPoint groundWorldPosition = [_physicsNode convertToWorldSpace:ground.position];
        CGPoint groundScreenPosition = [self convertToNodeSpace:groundWorldPosition];
        
        if (groundScreenPosition.x <= (-1 * ground.contentSize.width)) {
            ground.position = ccp(ground.position.x + 2 * ground.contentSize.width, ground.position.y);
        }
    }
    
    NSMutableArray *offScreenObstacles = nil;
    for (CCNode *obstacle in _obstacles) {
        CGPoint obstacleWorldPosition = [_physicsNode convertToWorldSpace:obstacle.position];
        CGPoint obstacleScreenPosition = [self convertToNodeSpace:obstacleWorldPosition];
        
        if (obstacleScreenPosition.x < -obstacle.contentSize.width) {
            if (!offScreenObstacles) {
                offScreenObstacles = [NSMutableArray array];
            }
            [offScreenObstacles addObject:obstacle];
        }
    }
    
    for (CCNode *obstacleToRemove in offScreenObstacles) {
        [obstacleToRemove removeFromParent];
        [_obstacles removeObject:obstacleToRemove];
        [self spawnNewObstacle];
    }
}

- (void)touchBegan:(CCTouch *)touch withEvent:(CCTouchEvent *)event {
    if (!_gameOver) {
        [_hero.physicsBody applyImpulse:ccp(0, 400.f)];
        [_hero.physicsBody applyAngularImpulse:10000.f];
        _sinceTouch = 0.f;
    }
}

- (void) spawnNewObstacle {
    CCNode *previousObstacle = [_obstacles lastObject];
    CGFloat previousObstacleXPosition = previousObstacle.position.x;
    if(!previousObstacle) {
        previousObstacleXPosition = firstObstaclePosition;
    }
    
    Obstacle *obstacle = (Obstacle *)[CCBReader load:@"Obstacle"];
    obstacle.position = ccp(previousObstacleXPosition + distanceBetweenObstacles, 0);
    obstacle.zOrder = DrawingOrderPipes;
    [obstacle setupRandomPosition];
    [_physicsNode addChild:obstacle];
    [_obstacles addObject:obstacle];
}

- (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair hero:(CCNode *)hero level:(CCNode *)level {
    [self gameOver];
    return TRUE;
}

- (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair hero:(CCNode *)hero goal:(CCNode *)goal {
    [goal removeFromParent];
    _points++;
    _scoreLabel.string = [NSString stringWithFormat:@"%ld", (long)_points];
    return TRUE;
}

- (void)restart {
    CCScene *scene = [CCBReader loadAsScene:@"MainScene"];
    [[CCDirector sharedDirector] replaceScene:scene];
}

- (void)gameOver {
    if (!_gameOver) {
        _scrollSpeed = 0.f;
        _gameOver = TRUE;
        
        _restartButton.visible = TRUE;
        _hero.rotation = 90.f;
        _hero.physicsBody.allowsRotation = FALSE;
        [_hero stopAllActions];
        
        CCActionMoveBy *moveBy = [CCActionMoveBy actionWithDuration:0.2f position:ccp(-2, 2)];
        CCActionInterval *reverseMovement = [moveBy reverse];
        CCActionSequence *shakeSequence = [CCActionSequence actionWithArray:@[moveBy, reverseMovement]];
        CCActionEaseBounce *bounce = [CCActionEaseBounce actionWithAction:shakeSequence];
        [self runAction:bounce];
    }
}

@end
