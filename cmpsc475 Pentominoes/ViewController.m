//
//  ViewController.m
//  cmpsc475 Pentominoes
//
//  Created by BRIAN J GOLDEN on 9/9/13.
//  Copyright (c) 2013 BRIAN J GOLDEN. All rights reserved.
//

#import "ViewController.h"
#import "InfoViewController.h"
#import "Model.h"
#import "PlayingPiece.h"

#define kPlayingPieceInitialHorizontalPosition 80
#define kPlayingPieceInitialVerticalPadding    45
#define kPlayingPieceVerticalPadding           120
#define kPlayingPieceHorizontalPadding         20
#define kPlayingPieceRightBoundPadding         250
#define kBoardSquareSideLength                 30.0
#define kAnimationDuration                     1.0
#define kPieceSnapAnimationDuration            0.3

@interface ViewController () <InfoDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *board;
@property (strong, nonatomic) NSArray *boardImages;
@property (strong, nonatomic) NSArray *playingPieces;
@property (strong, nonatomic) Model *model;
- (IBAction)BoardButtonPressed:(UIButton *)sender;
- (IBAction)ResetPressed:(UIButton *)sender;
- (IBAction)SolvePressed:(UIButton *)sender;
- (IBAction)unwindSegue:(UIStoryboardSegue *)segue;

@end

@implementation ViewController

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        _model = [[Model alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _boardImages = [self.model allBoardImages];
    _playingPieces = [self.model allPlayingPieces];
    [self registerGestureRecognizersOnPlayingPieces];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidAppear:(BOOL)animated
{
    [self placePiecesInStartPositions];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    if (!self.model.solutionFound) {
        [self placePiecesInStartPositions];
    }
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
    [self placePiecesInStartPositions];
}

- (IBAction)SolvePressed:(UIButton *)sender {
    //[self placePiecesInStartPositions];
    [self solveBoard];
}

- (void)solveBoard {
    if (![self.model solutionExists]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Solution"
                                                        message:@"The blank board has no solution!"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    if (self.model.solutionFound == YES) {
        return;
    }
    
    for (PlayingPiece *playingPiece in self.playingPieces) {
        CGPoint solutionRelativeOrigin = [self.model solutionLocationForPiece:playingPiece];
        CGPoint newOrigin = [playingPiece.superview convertPoint:playingPiece.frame.origin toView:self.board];
        CGRect newFrame = CGRectMake(newOrigin.x, newOrigin.y, playingPiece.frame.size.width, playingPiece.frame.size.height);
        NSInteger pieceRotations = [self.model numberOfRotationsForPiece:playingPiece];
        NSInteger pieceFlips = [self.model numberOfFlipsForPiece:playingPiece];
        
        [UIView animateWithDuration:kAnimationDuration animations:^{
            playingPiece.frame = newFrame;
            [self.board addSubview:playingPiece];
            
            [playingPiece rotateImage:pieceRotations];
            if (pieceFlips > 0) {
                [playingPiece flipImage];
            }
            
            playingPiece.frame =
            CGRectMake(solutionRelativeOrigin.x, solutionRelativeOrigin.y,
                       playingPiece.frame.size.width, playingPiece.frame.size.height);
        }];
    }
    
    self.model.solutionFound = YES;
}

-(void)switchBoards:(NSInteger)boardNumber {
    UIImage *newBoard = [self.model switchToBoard:boardNumber];
    [self.board setImage:newBoard];
    [self placePiecesInStartPositions];
}

- (BOOL)useWidthOfScreenForRightBound {
    UIInterfaceOrientation interfaceOrientation = self.interfaceOrientation;
    return UIInterfaceOrientationIsPortrait(interfaceOrientation);
}

- (CGPoint)nextPieceStartLocation:(CGPoint)currentOrigin forPieceWithSize:(CGSize)size usingRightBound:(CGFloat)rightBound {
    if (currentOrigin.x + size.width > rightBound) {
        currentOrigin.x = kPlayingPieceInitialHorizontalPosition;
        currentOrigin.y += kPlayingPieceVerticalPadding;
    } else {
        currentOrigin.x += size.width + kPlayingPieceHorizontalPadding;
    }
    
    return currentOrigin;
}

- (void)placePiecesInStartPositions {
    CGFloat rightBoundValue = [self useWidthOfScreenForRightBound] ? self.view.frame.size.width : self.view.frame.size.height;
    CGFloat rightBound = self.view.frame.origin.x + rightBoundValue - kPlayingPieceRightBoundPadding;
    CGFloat lowerBound = self.board.frame.origin.y + self.board.frame.size.height;
    
    CGPoint currentOrigin =
    CGPointMake(kPlayingPieceInitialHorizontalPosition,
                lowerBound + kPlayingPieceInitialVerticalPadding);
    
    for (PlayingPiece *playingPiece in self.playingPieces) {
        [UIView animateWithDuration:kAnimationDuration animations:^{
            playingPiece.transform = CGAffineTransformIdentity;
            CGPoint origin = [playingPiece.superview convertPoint:playingPiece.frame.origin toView:self.view];
            CGRect currentFrame = CGRectMake(origin.x, origin.y, playingPiece.frame.size.width, playingPiece.frame.size.height);
            playingPiece.frame = currentFrame;
            playingPiece.frame =
            CGRectMake(currentOrigin.x, currentOrigin.y, playingPiece.frame.size.width, playingPiece.frame.size.height);
            [self.view addSubview:playingPiece];
        }];
        
        currentOrigin = [self nextPieceStartLocation:currentOrigin forPieceWithSize:playingPiece.frame.size usingRightBound:rightBound];
    }
    
    self.model.solutionFound = NO;
}

#pragma mark - Gestures

- (void)registerGestureRecognizersOnPlayingPieces {
    for (PlayingPiece *playingPiece in self.playingPieces) {
        UITapGestureRecognizer *singleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
        UITapGestureRecognizer *doubleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
        UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
        [singleTapRecognizer requireGestureRecognizerToFail:doubleTapRecognizer];
        doubleTapRecognizer.numberOfTapsRequired = 2;
        [playingPiece addGestureRecognizer:singleTapRecognizer];
        [playingPiece addGestureRecognizer:doubleTapRecognizer];
        [playingPiece addGestureRecognizer:panRecognizer];
    }
}

- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer {
    PlayingPiece *playingPiece = (PlayingPiece *) recognizer.view;
    [playingPiece rotateImage:1];
}

- (void)handleDoubleTap:(UITapGestureRecognizer *)recognizer {
    PlayingPiece *playingPiece = (PlayingPiece *) recognizer.view;
    [playingPiece flipImage];
}

- (void)handlePanGesture:(UIPanGestureRecognizer *)recognizer {
    PlayingPiece *playingPiece = (PlayingPiece *) recognizer.view;
    
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan:
            break;
        case UIGestureRecognizerStateChanged:
        {
            playingPiece.center = [recognizer locationInView:playingPiece.superview];
            break;
        }
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        {
            CGPoint playingPieceOrigin = playingPiece.frame.origin;
            UIView *newSuperView;
            CGPoint newOrigin;
            
            if (CGRectContainsPoint(self.board.frame, playingPieceOrigin) ||
                CGRectContainsPoint(self.board.frame, CGPointMake(playingPieceOrigin.x + playingPiece.frame.size.width,
                                                                  playingPieceOrigin.y + playingPiece.frame.size.height))) {
                newSuperView = self.board;
                newOrigin = [playingPiece.superview convertPoint:playingPiece.frame.origin toView:newSuperView];
                playingPiece.frame = CGRectMake(newOrigin.x, newOrigin.y, playingPiece.frame.size.width, playingPiece.frame.size.height);
                newOrigin = [self snapPieceToBoard:newOrigin];
                
                [UIView animateWithDuration:kPieceSnapAnimationDuration animations:^{
                    playingPiece.frame = CGRectMake(newOrigin.x, newOrigin.y, playingPiece.frame.size.width, playingPiece.frame.size.height);
                }];
            } else {
                newSuperView = self.view;
                newOrigin = [playingPiece.superview convertPoint:playingPiece.frame.origin toView:newSuperView];
                playingPiece.frame = CGRectMake(newOrigin.x, newOrigin.y, playingPiece.frame.size.width, playingPiece.frame.size.height);
            }
            
            if (newSuperView != playingPiece.superview) {
                [newSuperView addSubview:playingPiece];
                playingPiece.frame = CGRectMake(newOrigin.x, newOrigin.y, playingPiece.frame.size.width, playingPiece.frame.size.height);
            }
        }
            break;
        default:
            break;
    }
    
    self.model.solutionFound = NO;
}

- (CGPoint)snapPieceToBoard:(CGPoint)currentOrigin {
    CGPoint point =
    CGPointMake(kBoardSquareSideLength * floorf((currentOrigin.x/kBoardSquareSideLength) + 0.5),
                kBoardSquareSideLength * floorf((currentOrigin.y / kBoardSquareSideLength) + 0.5));
    
    return point;
}

#pragma mark - Info Delegate

- (void)dismissMe {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - Segues
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"InfoSegue"]) {
        InfoViewController *infoViewController = segue.destinationViewController;
        infoViewController.delegate = self;
    }
}

- (IBAction)unwindSegue:(UIStoryboardSegue *)segue {
    
}

@end
