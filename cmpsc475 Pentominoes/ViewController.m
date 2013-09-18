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
#define kPlayingPieceInitialVerticalPadding    90
#define kPlayingPieceVerticalPadding           120
#define kPlayingPieceHorizontalPadding         20
#define kPlayingPieceRightBoundPadding         75
#define kBoardSquareSideLength                 30.0
#define kAnimationDuration                     1.0

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *board;
@property (strong, nonatomic) NSArray *boardImages;
@property (strong, nonatomic) NSArray *playingPieceImageViews;
@property (strong, nonatomic) NSArray *solutions;
@property NSInteger currentBoardNumber;
@property BOOL solutionFound;
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
    [self placePlayingPiecesInStartPositions];
    self.solutionFound = NO;
}

- (IBAction)SolvePressed:(UIButton *)sender {
    if (self.solutionFound == NO) {
        [self placePlayingPiecesInStartPositions];
    }
    [self solveBoard:self.currentBoardNumber];
}

- (void) solveBoard:(NSInteger)boardNumber {
    NSInteger solutionIndex = boardNumber - 1;
    
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
        
        UIView *playingPieceView = self.playingPieceImageViews[i];
        CGPoint newOrigin = [self.view convertPoint:playingPieceView.frame.origin toView:self.board];
        CGRect newFrame = CGRectMake(newOrigin.x, newOrigin.y, playingPieceView.frame.size.width, playingPieceView.frame.size.height);
        
        [UIView animateWithDuration:kAnimationDuration
                         animations:^{
                             playingPieceView.frame = newFrame;
                             [self.board addSubview:playingPieceView];
                             
                             playingPieceView.transform =
                                [self rotatePlayingPiece:playingPieceView.transform numberOfRotations:[pieceRotations floatValue]];
                             playingPieceView.transform =
                                [self flipPlayingPiece:playingPieceView.transform numberOfFlips:[pieceFlips integerValue]];
                             
                             playingPieceView.frame =
                                CGRectMake(solutionRelativeOrigin.x, solutionRelativeOrigin.y, playingPieceView.frame.size.width, playingPieceView.frame.size.height);
                         }
         ];
    }

    self.solutionFound = YES;
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

- (void) switchBoards:(NSInteger)buttonTag {
    UIImage *newBoard = self.boardImages[buttonTag];
    [self.board setImage:newBoard];
    [self placePlayingPiecesInStartPositions];
    self.currentBoardNumber = buttonTag;
    self.solutionFound = NO;
}

- (void) placePlayingPiecesInStartPositions {
    CGRect viewFrame = self.view.frame;
    CGFloat rightBound = viewFrame.origin.x + viewFrame.size.width - kPlayingPieceRightBoundPadding;
    CGFloat lowerBound = self.board.frame.origin.y + self.board.frame.size.height;
    
    CGPoint currentOrigin =
        CGPointMake(kPlayingPieceInitialHorizontalPosition,
                    lowerBound + kPlayingPieceInitialVerticalPadding);
    
    for (UIImageView *playingPiece in self.playingPieceImageViews) {        
        // check if there is enough horizontal room to place the piece
        if (currentOrigin.x + playingPiece.frame.size.width > rightBound) {
            currentOrigin.x = kPlayingPieceInitialHorizontalPosition;
            currentOrigin.y += kPlayingPieceVerticalPadding;
        }
        
        CGPoint origin = [playingPiece.superview convertPoint:playingPiece.frame.origin toView:self.view];
        CGRect currentFrame = CGRectMake(origin.x, origin.y, playingPiece.frame.size.width, playingPiece.frame.size.height);
                
        [UIView animateWithDuration:kAnimationDuration
                         animations:^{
                             playingPiece.transform = CGAffineTransformIdentity;
                             playingPiece.frame = currentFrame;
                             playingPiece.frame =
                                CGRectMake(currentOrigin.x, currentOrigin.y, playingPiece.frame.size.width, playingPiece.frame.size.height);
                             [self.view addSubview:playingPiece];
                         }];
        
        currentOrigin.x += playingPiece.frame.size.width + kPlayingPieceHorizontalPadding;
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
