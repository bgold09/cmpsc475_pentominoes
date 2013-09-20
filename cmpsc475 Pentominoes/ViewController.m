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

@interface ViewController () <InfoDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *board;
@property (strong, nonatomic) NSArray *boardImages;
@property (strong, nonatomic) NSArray *playingPieceImageViews;
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
    _boardImages = [self.model createBoardImages];
    _playingPieceImageViews = [self.model createPlayingPieceImageViews];
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
    if (self.model.solutionFound == NO) {
        [self placePiecesInStartPositions];
    }
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
    
    NSArray *tileNames = @[@"F", @"I", @"L", @"N", @"P", @"T", @"U", @"V", @"W", @"X", @"Y", @"Z"];
    
    for (NSInteger i = 0; i < [tileNames count]; i++) {
        NSString *tileName = tileNames[i];
        CGPoint solutionRelativeOrigin = [self.model pieceSolutionLocation:tileName];
        PlayingPiece *playingPiece = self.playingPieceImageViews[i];
        CGPoint newOrigin = [self.view convertPoint:playingPiece.frame.origin toView:self.board];
        CGRect newFrame = CGRectMake(newOrigin.x, newOrigin.y, playingPiece.frame.size.width, playingPiece.frame.size.height);
        NSInteger pieceRotations = [self.model numberOfRotationsForPiece:tileName];
        NSInteger pieceFlips = [self.model numberOfFlipsForPiece:tileName];
        
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

- (CGAffineTransform)rotatePlayingPiece:(CGAffineTransform)transform numberOfRotations:(CGFloat)numberOfRotations {
    return CGAffineTransformRotate(transform, M_PI_2 * numberOfRotations);
}

- (CGAffineTransform)flipPlayingPiece:(CGAffineTransform)transform numberOfFlips:(NSInteger)numberOfFlips {
    if (numberOfFlips == 1) {
        return CGAffineTransformScale(transform, -1.0, 1.0);
    }
    return transform;
}

- (BOOL)useWidthOfScreenForRightBound {
    UIDevice *device = [UIDevice currentDevice];
    UIDeviceOrientation orientation = [device orientation];
    return UIDeviceOrientationIsPortrait(orientation) || orientation == UIDeviceOrientationUnknown;
}

- (void)placePiecesInStartPositions {
    CGFloat rightBoundValue = [self useWidthOfScreenForRightBound] ? self.view.frame.size.width : self.view.frame.size.height;
    CGRect bounds = [[UIScreen mainScreen] bounds];
    CGFloat rightBound = bounds.origin.x + rightBoundValue - kPlayingPieceRightBoundPadding;
    CGFloat lowerBound = self.board.frame.origin.y + self.board.frame.size.height;

    CGPoint currentOrigin =
        CGPointMake(kPlayingPieceInitialHorizontalPosition,
                    lowerBound + kPlayingPieceInitialVerticalPadding);
    
    for (UIImageView *playingPiece in self.playingPieceImageViews) {
        [UIView animateWithDuration:kAnimationDuration animations:^{
            playingPiece.transform = CGAffineTransformIdentity;
            CGPoint origin = [playingPiece.superview convertPoint:playingPiece.frame.origin toView:self.view];
            CGRect currentFrame = CGRectMake(origin.x, origin.y, playingPiece.frame.size.width, playingPiece.frame.size.height);
            playingPiece.frame = currentFrame;
            playingPiece.frame =
                CGRectMake(currentOrigin.x, currentOrigin.y, playingPiece.frame.size.width, playingPiece.frame.size.height);
            [self.view addSubview:playingPiece];
            
        }];
        
        currentOrigin = [self.model nextPieceStartLocation:currentOrigin forPieceWithSize:playingPiece.frame.size usingRightBound:rightBound];
    }
}

#pragma mark - Gestures

- (void)registerGestureRecognizersOnPlayingPieces {
    for (PlayingPiece *playingPiece in self.playingPieceImageViews) {
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
                playingPiece.frame = CGRectMake(newOrigin.x, newOrigin.y, playingPiece.frame.size.width, playingPiece.frame.size.height);
            } else {
                newSuperView = self.view;
                newOrigin = [playingPiece.superview convertPoint:playingPiece.frame.origin fromView:newSuperView];
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
