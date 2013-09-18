//
//  Model.m
//  cmpsc475 Pentominoes
//
//  Created by BRIAN J GOLDEN on 9/18/13.
//  Copyright (c) 2013 BRIAN J GOLDEN. All rights reserved.
//

#import "Model.h"

#define kNumberBoardImages                     6
#define kPlayingPieceInitialHorizontalPosition 80
#define kPlayingPieceInitialVerticalPadding    90
#define kPlayingPieceVerticalPadding           120
#define kPlayingPieceHorizontalPadding         20
#define kPlayingPieceRightBoundPadding         75
#define kBoardSquareSideLength                 30.0
#define kAnimationDuration                     1.0

@interface Model ()
@property (strong, nonatomic) NSArray *solutions;
@property NSInteger currentBoardNumber;

@end

@implementation Model

static NSString *kSolutionsFileName = @"Solutions";
static NSString *kSolutionsFileExtention = @"plist";

- (id)init {
    self = [super init];
    if (self) {
        _solutions = [self loadSolutions];
    }
    return self;
}

- (void) solveBoard:(UIView *)boardView forPieces:(NSArray *)playingPieces usingSuperView:(UIView *)view {
    NSInteger solutionIndex = self.currentBoardNumber - 1;
    
    if (solutionIndex < 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Solution"
                                                        message:@"The blank board has no solution!"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    if (self.solutionFound == YES) {
        return;
    }
    
    NSArray *tileNames = @[@"F", @"I", @"L", @"N", @"P", @"T", @"U", @"V", @"W", @"X", @"Y", @"Z"];
    NSDictionary *solutionDictionary = self.solutions[solutionIndex];
    
    for (NSInteger i = 0; i < [tileNames count]; i++) {
        NSString *tileName = tileNames[i];
        NSDictionary *pieceSolution = [solutionDictionary objectForKey:tileName];
        NSNumber *piecePositionX = (NSNumber *) [pieceSolution objectForKey:@"x"];
        NSNumber *piecePositionY = (NSNumber *) [pieceSolution objectForKey:@"y"];
        NSNumber *pieceRotations = (NSNumber *) [pieceSolution objectForKey:@"rotations"];
        NSNumber *pieceFlips = (NSNumber *) [pieceSolution objectForKey:@"flips"];
        
        CGPoint solutionRelativeOrigin =
        CGPointMake([piecePositionX floatValue] * kBoardSquareSideLength,
                    [piecePositionY floatValue] * kBoardSquareSideLength);
        
        UIView *playingPieceView = playingPieces[i];
        CGPoint newOrigin = [view convertPoint:playingPieceView.frame.origin toView:boardView];
        CGRect newFrame = CGRectMake(newOrigin.x, newOrigin.y, playingPieceView.frame.size.width, playingPieceView.frame.size.height);
        
        [UIView animateWithDuration:kAnimationDuration
                         animations:^{
                             playingPieceView.frame = newFrame;
                             [boardView addSubview:playingPieceView];
                             
                             playingPieceView.transform =
                             [self rotatePlayingPiece:playingPieceView.transform numberOfRotations:[pieceRotations floatValue]];
                             playingPieceView.transform =
                             [self flipPlayingPiece:playingPieceView.transform numberOfFlips:[pieceFlips integerValue]];
                             
                             playingPieceView.frame =
                             CGRectMake(solutionRelativeOrigin.x, solutionRelativeOrigin.y, playingPieceView.frame.size.width, playingPieceView.frame.size.height);
                         }
         ];
    }
}

- (void) placePlayingPiecesInStartPositions:(NSArray *)playingPieces onView:(UIView *)view usingBoard:(UIView *)board {
    CGRect viewFrame = view.frame;
    CGFloat rightBound = viewFrame.origin.x + viewFrame.size.width - kPlayingPieceRightBoundPadding;
    CGFloat lowerBound = board.frame.origin.y + board.frame.size.height;
    
    CGPoint currentOrigin =
    CGPointMake(kPlayingPieceInitialHorizontalPosition,
                lowerBound + kPlayingPieceInitialVerticalPadding);
    
    for (UIImageView *playingPiece in playingPieces) {
        // check if there is enough horizontal room to place the piece
        if (currentOrigin.x + playingPiece.frame.size.width > rightBound) {
            currentOrigin.x = kPlayingPieceInitialHorizontalPosition;
            currentOrigin.y += kPlayingPieceVerticalPadding;
        }
        
        [UIView animateWithDuration:kAnimationDuration
                         animations:^{
                             playingPiece.transform = CGAffineTransformIdentity;
                             CGPoint origin = [playingPiece.superview convertPoint:playingPiece.frame.origin toView:view];
                             CGRect currentFrame = CGRectMake(origin.x, origin.y, playingPiece.frame.size.width, playingPiece.frame.size.height);
                             playingPiece.frame = currentFrame;
                             playingPiece.frame =
                             CGRectMake(currentOrigin.x, currentOrigin.y, playingPiece.frame.size.width, playingPiece.frame.size.height);
                             [view addSubview:playingPiece];
                         }];
        
        currentOrigin.x += playingPiece.frame.size.width + kPlayingPieceHorizontalPadding;
    }
    
    self.solutionFound = NO;
}

- (void) switchBoards:(UIImageView *)board toBoardNumber:(NSInteger)boardNumber usingBoardImages:(NSArray *)boardImages andResetPieces:(NSArray *)playingPieces toView:(UIView *)view {
    UIImage *newBoard = boardImages[boardNumber];
    [board setImage:newBoard];
    [self placePlayingPiecesInStartPositions:playingPieces onView:view usingBoard:board];
    self.solutionFound = NO;
    self.currentBoardNumber = boardNumber;
}

- (CGAffineTransform) rotatePlayingPiece:(CGAffineTransform)transform numberOfRotations:(CGFloat)numberOfRotations {
    return CGAffineTransformRotate(transform, M_PI_2 * numberOfRotations);
}

- (CGAffineTransform) flipPlayingPiece:(CGAffineTransform)transform numberOfFlips:(NSInteger)numberOfFlips {
    if (numberOfFlips == 1) {
        return CGAffineTransformScale(transform, -1.0, 1.0);
    }
    return transform;
}

- (NSArray *) loadSolutions {
    NSString *solutionsFilePath = [[NSBundle mainBundle] pathForResource:kSolutionsFileName ofType:kSolutionsFileExtention];
    NSMutableArray *array = [[NSMutableArray alloc] initWithContentsOfFile:solutionsFilePath];
    return array;
}

@end
