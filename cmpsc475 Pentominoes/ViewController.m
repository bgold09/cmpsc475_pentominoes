//
//  ViewController.m
//  cmpsc475 Pentominoes
//
//  Created by BRIAN J GOLDEN on 9/9/13.
//  Copyright (c) 2013 BRIAN J GOLDEN. All rights reserved.
//

#import "ViewController.h"
#import "Model.h"
#import "PlayingPiece.h"

#define kPlayingPieceInitialHorizontalPosition 80
#define kPlayingPieceInitialVerticalPadding    45
#define kPlayingPieceVerticalPadding           120
#define kPlayingPieceHorizontalPadding         20
#define kPlayingPieceRightBoundPadding         250
#define kBoardSquareSideLength                 30.0
#define kAnimationDuration                     1.0

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *board;
@property (strong, nonatomic) NSArray *boardImages;
@property (strong, nonatomic) NSArray *playingPieceImageViews;
@property (strong, nonatomic) Model *model;
- (IBAction)BoardButtonPressed:(UIButton *)sender;
- (IBAction)ResetPressed:(UIButton *)sender;
- (IBAction)SolvePressed:(UIButton *)sender;

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

@end
