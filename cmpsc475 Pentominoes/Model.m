//
//  Model.m
//  cmpsc475 Pentominoes
//
//  Created by BRIAN J GOLDEN on 9/18/13.
//  Copyright (c) 2013 BRIAN J GOLDEN. All rights reserved.
//

#import "Model.h"
#import "PlayingPiece.h"

#define kNumberBoardImages                     6
#define kPlayingPieceInitialHorizontalPosition 80
#define kPlayingPieceInitialVerticalPadding    90
#define kPlayingPieceVerticalPadding           120
#define kPlayingPieceHorizontalPadding         20
#define kPlayingPieceRightBoundPadding         75
#define kBoardSquareSideLength                 30.0
#define kAnimationDuration                     1.0

@interface Model ()
@property (strong, nonatomic) NSArray *boardImages;
@property (strong, nonatomic) NSArray *solutions;
@property NSInteger currentBoardNumber;

@end

@implementation Model

static NSString *kBoardImagePrefix = @"Board";
static NSString *kBoardImageFileExtension = @"png";
static NSString *kPlayingPieceImagePrefix = @"tile";
static NSString *kPlayingPieceImageFileExtension = @"png";
static NSString *kSolutionsFileName = @"Solutions";
static NSString *kSolutionsFileExtention = @"plist";

- (id)init {
    self = [super init];
    if (self) {
        _solutions = [self loadSolutions];
        _boardImages = [self createBoardImages];
    }
    return self;
}

- (BOOL)solutionExists {
    if (self.currentBoardNumber < 1) {
        return NO;
    }
    return YES;
}

- (CGPoint)pieceSolutionLocation:(NSString *)tileName {
    NSDictionary *solutionDictionary = self.solutions[self.currentBoardNumber - 1];
    NSDictionary *pieceSolution = [solutionDictionary objectForKey:tileName];
    NSNumber *piecePositionX = (NSNumber *) [pieceSolution objectForKey:@"x"];
    NSNumber *piecePositionY = (NSNumber *) [pieceSolution objectForKey:@"y"];
    
    CGPoint solutionRelativeOrigin =
        CGPointMake([piecePositionX floatValue] * kBoardSquareSideLength,
                    [piecePositionY floatValue] * kBoardSquareSideLength);
    
    return solutionRelativeOrigin;
}

- (NSInteger)numberOfRotationsForPiece:(NSString *)tileName {
    NSDictionary *solutionDictionary = self.solutions[self.currentBoardNumber - 1];
    NSDictionary *pieceSolution = [solutionDictionary objectForKey:tileName];
    NSNumber *pieceRotations = (NSNumber *) [pieceSolution objectForKey:@"rotations"];
    
    return [pieceRotations floatValue];
}

- (NSInteger)numberOfFlipsForPiece:(NSString *)tileName {
    NSDictionary *solutionDictionary = self.solutions[self.currentBoardNumber - 1];
    NSDictionary *pieceSolution = [solutionDictionary objectForKey:tileName];
    NSNumber *pieceFlips = (NSNumber *) [pieceSolution objectForKey:@"flips"];
    
    return [pieceFlips floatValue];
}

- (CGPoint)nextPieceStartLocation:(CGPoint)currentOrigin forPieceWithSize:(CGSize)size usingRightBound:(CGFloat)rightBound {
    if (currentOrigin.x + size.width > rightBound) {
        currentOrigin.x = kPlayingPieceInitialHorizontalPosition;
        currentOrigin.y += kPlayingPieceVerticalPadding;
    } else {
        currentOrigin.x += size.width + kPlayingPieceHorizontalPadding;
    }
    
    self.solutionFound = NO;
    return currentOrigin;
}

- (UIImage *)switchToBoard:(NSInteger)boardNumber {
    self.solutionFound = NO;
    self.currentBoardNumber = boardNumber;
    return self.boardImages[boardNumber];
}

- (NSArray *)createBoardImages {
    NSMutableArray *newBoardImages = [[NSMutableArray alloc] init];
    for (NSInteger boardImageNumber = 0; boardImageNumber < kNumberBoardImages; boardImageNumber++) {
        NSString *boardImageFileName = [[NSString alloc] initWithFormat:@"%@%d.%@", kBoardImagePrefix, boardImageNumber, kBoardImageFileExtension];
        UIImage *boardImage = [UIImage imageNamed:boardImageFileName];
        [newBoardImages addObject:boardImage];
    }
    
    return newBoardImages;
}

- (NSArray *)createPlayingPieceImageViews {
    NSArray *tileNames = @[@"F", @"I", @"L", @"N", @"P", @"T", @"U", @"V", @"W", @"X", @"Y", @"Z"];
    NSMutableArray *playingPieces = [[NSMutableArray alloc] init];
    
    for (NSString *tileName in tileNames) {
        NSString *playingPieceImageFileName = [[NSString alloc] initWithFormat:@"%@%@.%@", kPlayingPieceImagePrefix, tileName, kPlayingPieceImageFileExtension];
        UIImage *playingPieceImage = [UIImage imageNamed:playingPieceImageFileName];
        PlayingPiece *playingPiece = [[PlayingPiece alloc] initWithImage:playingPieceImage andTileName:tileName];
        
        CGRect frame = CGRectMake(0.0, 0.0, playingPieceImage.size.width / 2, playingPieceImage.size.height / 2);
        playingPiece.frame = frame;
        playingPiece.userInteractionEnabled = YES;
        [playingPiece registerGestureRecognizers];
        [playingPieces addObject:playingPiece];
    }
    
    return playingPieces;
}

- (NSArray *)loadSolutions {
    NSString *solutionsFilePath = [[NSBundle mainBundle] pathForResource:kSolutionsFileName ofType:kSolutionsFileExtention];
    NSMutableArray *array = [[NSMutableArray alloc] initWithContentsOfFile:solutionsFilePath];
    return array;
}

@end
