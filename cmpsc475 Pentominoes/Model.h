//
//  Model.h
//  cmpsc475 Pentominoes
//
//  Created by BRIAN J GOLDEN on 9/18/13.
//  Copyright (c) 2013 BRIAN J GOLDEN. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PlayingPiece.h"

@interface Model : NSObject

@property BOOL solutionFound;
- (CGPoint)solutionLocationForPiece:(PlayingPiece *)playingPiece;
- (NSInteger)numberOfRotationsForPiece:(PlayingPiece *)playingPiece;
- (NSInteger)numberOfFlipsForPiece:(PlayingPiece *)playingPiece;
- (UIImage *)switchToBoard:(NSInteger)boardNumber;
- (BOOL)solutionExists;
- (UIColor *)textColorForTheme:(NSInteger)themeNumber;
- (NSArray *)allBoardImages;
- (NSArray *)allPlayingPieces;
- (NSArray *)allTextColors;
@end
