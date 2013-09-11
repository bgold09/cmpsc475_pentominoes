//
//  ViewController.m
//  cmpsc475 Pentominoes
//
//  Created by BRIAN J GOLDEN on 9/9/13.
//  Copyright (c) 2013 BRIAN J GOLDEN. All rights reserved.
//

#import "ViewController.h"

#define kNumberBoardImages                     6
#define kPlayingPieceInitialHorizontalPosition 80
#define kPlayingPieceInitialVerticalPadding    50
#define kPlayingPieceVerticalPadding           120
#define kPlayingPieceHorizontalPadding         20
#define kPlayingPieceRightBoundPadding         75
#define kBoardSquareSideLength                 30.0

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *board;
@property (strong, nonatomic) NSArray *boardImages;
@property (strong, nonatomic) NSArray *playingPieceImageViews;
@property (strong, nonatomic) NSArray *solutions;
@property NSInteger currentBoardNumber;
- (IBAction)BoardButtonPressed:(UIButton *)sender;
- (IBAction)ResetPressed:(UIButton *)sender;
- (IBAction)SolvePressed:(UIButton *)sender;

@end

@implementation ViewController

static NSString *kBoardImagePrefix = @"Board";
static NSString *kBoardImageFileExtension = @"png";
static NSString *kPlayingPieceImagePrefix = @"tile";
static NSString *kPlayingPieceImageFileExtension = @"png";
static NSString *kSolutionsFileName = @"Solutions";
static NSString *kSolutionsFileExtention = @"plist";

- (void)viewDidLoad
{
    [super viewDidLoad];
    _boardImages = [self createBoardImages];
    _playingPieceImageViews = [self createPlayingPieceImageViews];
    _solutions = [self loadSolutions];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void) viewDidAppear:(BOOL)animated
{
    [self placePlayingPiecesInStartPositions];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)BoardButtonPressed:(UIButton *)sender {
    NSInteger buttonTag = [sender tag];
    [self switchBoards:buttonTag];
}

- (IBAction)ResetPressed:(UIButton *)sender {
}

- (IBAction)SolvePressed:(UIButton *)sender {
    [self solveBoard:self.currentBoardNumber];
}

- (void) solveBoard:(NSInteger)boardNumber {
    NSInteger solutionIndex = boardNumber - 1;
    
    // the blank puzzle has no solution
    if (solutionIndex < 0) {
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
                
        /* 
         The dictionary for each tile contains coordinates x and y, 
           plus the number of (clockwise) rotations and flips (along vertical axis). 
         To convert these coordinates into origin coordinates on the board
           you need to multiply each value by the length of the side of a square (30). 
         Rotations should be performed before flips (these operations are not commutative).
        */
        
        /*
         Moving a piece from the main view to the board (and vice-versa) requires 
           removing the piece from its current superview and adding it as a subview to its new view. 
           Fortunately, the method - addSubview: automatically removes its argument from its superview (if it is already a subview). 
         But, you must explicitly change the piece’s frame to use the new superview’s coordinate system.
         You should use UIView’s -convertPoint:toView: method for this. 
         Also remember that a view can be visible as a subview even if its frame 
           is not within the bounds of its superview (unless the superview’s clipToBounds property is set to YES).
        */
        
        UIView *playingPieceView = self.playingPieceImageViews[i];
        CGSize playingPieceSize = playingPieceView.frame.size;
        playingPieceView.frame = CGRectMake(solutionRelativeOrigin.x, solutionRelativeOrigin.y, playingPieceSize.width, playingPieceSize.height);

        // rotate the piece
        // flip the piece
        
        [self.board addSubview:playingPieceView];
    }
}

- (void) switchBoards:(NSInteger)buttonTag {
    UIImage *newBoard = self.boardImages[buttonTag];
    [self.board setImage:newBoard];
    self.currentBoardNumber = buttonTag;
}

- (void) placePlayingPiecesInStartPositions {
    CGRect viewFrame = self.view.frame;
    CGFloat rightBound = viewFrame.origin.x + viewFrame.size.width - kPlayingPieceRightBoundPadding;
    CGFloat lowerBound = self.board.frame.origin.y + self.board.frame.size.height;
    
    CGPoint currentOrigin =
        CGPointMake(kPlayingPieceInitialHorizontalPosition,
                    lowerBound + kPlayingPieceInitialVerticalPadding);
    
    for (UIImageView *playingPiece in self.playingPieceImageViews) {
        CGSize playingPieceSize = playingPiece.frame.size;
        
        // check if there is enough horizontal room to place the piece
        if (currentOrigin.x + playingPieceSize.width > rightBound) {
            currentOrigin.x = kPlayingPieceInitialHorizontalPosition;
            currentOrigin.y += kPlayingPieceVerticalPadding;
        }
        
        playingPiece.frame = CGRectMake(currentOrigin.x, currentOrigin.y, playingPieceSize.width, playingPieceSize.height);
        [self.view addSubview:playingPiece];
        
        currentOrigin.x += playingPieceSize.width + kPlayingPieceHorizontalPadding;
    }
}

- (NSArray *) createBoardImages {
    NSMutableArray *newBoardImages = [[NSMutableArray alloc] init];
    
    for (NSInteger boardImageNumber = 0; boardImageNumber < kNumberBoardImages; boardImageNumber++) {
        NSString *boardImageFileName = [[NSString alloc] initWithFormat:@"%@%d.%@", kBoardImagePrefix, boardImageNumber, kBoardImageFileExtension];
        UIImage *boardImage = [UIImage imageNamed:boardImageFileName];
        [newBoardImages addObject:boardImage];
    }
    
    return newBoardImages;
}

- (NSArray *) createPlayingPieceImageViews {
    NSArray *tileNames = @[@"F", @"I", @"L", @"N", @"P", @"T", @"U", @"V", @"W", @"X", @"Y", @"Z"];
    NSMutableArray *playingPieces = [[NSMutableArray alloc] init];
    
    for (NSString *tileName in tileNames) {
        NSString *playingPieceImageFileName = [[NSString alloc] initWithFormat:@"%@%@.%@", kPlayingPieceImagePrefix, tileName, kPlayingPieceImageFileExtension];
        UIImage *playingPieceImage = [UIImage imageNamed:playingPieceImageFileName];
        UIImageView *playingPieceImageView = [[UIImageView alloc] initWithImage:playingPieceImage];
        
        CGRect frame = CGRectMake(0.0, 0.0, playingPieceImage.size.width / 2, playingPieceImage.size.height / 2);
        playingPieceImageView.frame = frame;
        
        [playingPieces addObject:playingPieceImageView];
    }
    
    return playingPieces;
}

- (NSArray *) loadSolutions {
    NSString *solutionsFilePath = [[NSBundle mainBundle] pathForResource:kSolutionsFileName ofType:kSolutionsFileExtention];
    NSMutableArray *array = [[NSMutableArray alloc] initWithContentsOfFile:solutionsFilePath];    
    return array;
}

@end
