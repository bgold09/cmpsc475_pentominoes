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
#define kNumberOfThemes                        3

@interface Model ()
@property (retain, nonatomic) NSArray *boardImages;
@property (retain, nonatomic) NSArray *solutions;
@property (retain, nonatomic) NSArray *textColors;
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
        _solutions = [[self allSolutions] retain];
        _boardImages = [[self allBoardImages] retain];
        _textColors = [[self allTextColors] retain];
    }
    return self;
}

- (void)dealloc {
    [_solutions release];
    [_boardImages release];
    [_textColors release];
    [super dealloc];
}

- (BOOL)solutionExists {
    if (self.currentBoardNumber < 1) {
        return NO;
    }
    return YES;
}

- (CGPoint)solutionLocationForPiece:(PlayingPiece *)playingPiece {
    NSString *tileName = playingPiece.tileName;
    NSDictionary *solutionDictionary = self.solutions[self.currentBoardNumber - 1];
    NSDictionary *pieceSolution = [solutionDictionary objectForKey:tileName];
    NSNumber *piecePositionX = (NSNumber *) [pieceSolution objectForKey:@"x"];
    NSNumber *piecePositionY = (NSNumber *) [pieceSolution objectForKey:@"y"];
    
    CGPoint solutionRelativeOrigin =
    CGPointMake([piecePositionX floatValue] * kBoardSquareSideLength,
                [piecePositionY floatValue] * kBoardSquareSideLength);
    
    return solutionRelativeOrigin;
}

- (NSInteger)numberOfRotationsForPiece:(PlayingPiece *)playingPiece {
    NSString *tileName = playingPiece.tileName;
    NSDictionary *solutionDictionary = self.solutions[self.currentBoardNumber - 1];
    NSDictionary *pieceSolution = [solutionDictionary objectForKey:tileName];
    NSNumber *pieceRotations = (NSNumber *) [pieceSolution objectForKey:@"rotations"];
    
    return [pieceRotations floatValue];
}

- (NSInteger)numberOfFlipsForPiece:(PlayingPiece *)playingPiece {
    NSString *tileName = playingPiece.tileName;
    NSDictionary *solutionDictionary = self.solutions[self.currentBoardNumber - 1];
    NSDictionary *pieceSolution = [solutionDictionary objectForKey:tileName];
    NSNumber *pieceFlips = (NSNumber *) [pieceSolution objectForKey:@"flips"];
    
    return [pieceFlips floatValue];
}

- (UIImage *)switchToBoard:(NSInteger)boardNumber {
    self.solutionFound = NO;
    self.currentBoardNumber = boardNumber;
    return self.boardImages[boardNumber];
}

- (UIColor *)textColorForTheme:(NSInteger)themeNumber {
    if (themeNumber >= 0 && themeNumber < kNumberOfThemes) {
        return [self.textColors objectAtIndex:themeNumber];
    }
    return nil;
}

- (NSArray *)allBoardImages {
    NSMutableArray *newBoardImages = [[NSMutableArray alloc] init];
    for (NSInteger boardImageNumber = 0; boardImageNumber < kNumberBoardImages; boardImageNumber++) {
        NSString *boardImageFileName = [[NSString alloc] initWithFormat:@"%@%d.%@", kBoardImagePrefix, boardImageNumber, kBoardImageFileExtension];
        UIImage *boardImage = [UIImage imageNamed:boardImageFileName];
        [boardImageFileName release];
        [newBoardImages addObject:boardImage];
    }
    
    [newBoardImages autorelease];
    return newBoardImages;
}

- (NSArray *)allPlayingPieces {
    NSArray *tileNames = @[@"F", @"I", @"L", @"N", @"P", @"T", @"U", @"V", @"W", @"X", @"Y", @"Z"];
    NSMutableArray *playingPieces = [[NSMutableArray alloc] init];
    
    for (NSString *tileName in tileNames) {
        NSString *playingPieceImageFileName = [[NSString alloc] initWithFormat:@"%@%@.%@", kPlayingPieceImagePrefix, tileName, kPlayingPieceImageFileExtension];
        UIImage *playingPieceImage = [UIImage imageNamed:playingPieceImageFileName];
        [playingPieceImageFileName release];
        PlayingPiece *playingPiece = [[PlayingPiece alloc] initWithImage:playingPieceImage andTileName:tileName];
        
        CGRect frame = CGRectMake(0.0, 0.0, playingPieceImage.size.width / 2, playingPieceImage.size.height / 2);
        playingPiece.frame = frame;
        playingPiece.userInteractionEnabled = YES;
        [playingPieces addObject:playingPiece];
        [playingPiece release];
    }
    
    [playingPieces autorelease];
    return playingPieces;
}

- (NSArray *)allSolutions {
    NSString *solutionsFilePath = [[NSBundle mainBundle] pathForResource:kSolutionsFileName ofType:kSolutionsFileExtention];
    NSMutableArray *solutions = [[NSMutableArray alloc] initWithContentsOfFile:solutionsFilePath];
    [solutions autorelease];
    return solutions;
}

- (NSArray *)allTextColors {
    NSMutableArray *themes = [[NSMutableArray alloc] initWithObjects:[UIColor yellowColor], [UIColor whiteColor], [UIColor blackColor], nil];
    [themes autorelease];
    return themes;
}

@end
