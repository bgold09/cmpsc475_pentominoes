//
//  PlayingPiece.m
//  cmpsc475 Pentominoes
//
//  Created by BRIAN J GOLDEN on 9/18/13.
//  Copyright (c) 2013 BRIAN J GOLDEN. All rights reserved.
//

#import "PlayingPiece.h"

#define kAnimationDuration 1.0

@implementation PlayingPiece

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
// Drawing code
}
*/

- (id)initWithImage:(UIImage *)image andTileName:(NSString *)tileName {
    self = [super initWithImage:image];
    if (self) {
        _tileName = tileName;
    }
    return self;
}

- (void)rotateImage:(NSInteger)numberOfRotations {
    if (self.pieceIsFlipped) {
        [UIView animateWithDuration:kAnimationDuration animations:^{
            self.transform = CGAffineTransformRotate(self.transform, -1.0 * M_PI_2 * numberOfRotations);
        }];
    } else {
        [UIView animateWithDuration:kAnimationDuration animations:^{
            self.transform = CGAffineTransformRotate(self.transform, M_PI_2 * numberOfRotations);
        }];
    }
    
    self.currentRotations = (self.currentRotations + numberOfRotations) % 4;
}

- (void)flipImage {
    [UIView animateWithDuration:kAnimationDuration animations:^{
        self.transform = CGAffineTransformScale(self.transform, -1.0, 1.0);
    }];
    self.pieceIsFlipped = !self.pieceIsFlipped;
}

@end
