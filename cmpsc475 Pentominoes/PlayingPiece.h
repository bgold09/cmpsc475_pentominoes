//
//  PlayingPiece.h
//  cmpsc475 Pentominoes
//
//  Created by BRIAN J GOLDEN on 9/18/13.
//  Copyright (c) 2013 BRIAN J GOLDEN. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PlayingPiece : UIImageView
@property NSString *tileName;
@property NSInteger currentRotations;
@property BOOL pieceIsFlipped;
- (id)initWithImage:(UIImage *)image andTileName:(NSString *)tileName;
- (void)rotateImage:(NSInteger)numberOfRotations;
- (void)flipImage;
- (void)registerGestureRecognizers;

@end
