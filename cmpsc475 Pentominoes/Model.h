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
- (CGPoint)nextPieceStartLocation:(CGPoint)currentOrigin forPieceWithSize:(CGSize)size usingRightBound:(CGFloat)rightBound;
- (CGPoint)pieceSolutionLocation:(NSString *)tileName;
- (CGFloat)numberOfRotationsForPiece:(NSString *)tileName;
- (CGFloat)numberOfFlipsForPiece:(NSString *)tileName;
- (UIImage *)switchToBoard:(NSInteger)boardNumber;
- (BOOL)solutionExists;
- (NSArray *)createBoardImages;
- (NSArray *)createPlayingPieceImageViews;
@end
