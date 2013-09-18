//
//  Model.h
//  cmpsc475 Pentominoes
//
//  Created by BRIAN J GOLDEN on 9/18/13.
//  Copyright (c) 2013 BRIAN J GOLDEN. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Model : NSObject

@property BOOL solutionFound;
- (void) solveBoard:(UIView *)boardView forPieces:(NSArray *)playingPieces usingSuperView:(UIView *)view;
- (void) placePlayingPiecesInStartPositions:(NSArray *)playingPieces onView:(UIView *)view usingBoard:(UIView *)board;
- (void) switchBoards:(UIImageView *)board toBoardNumber:(NSInteger)boardNumber usingBoardImages:(NSArray *)boardImages andResetPieces:(NSArray *)playingPieces toView:(UIView *)view;
@end
