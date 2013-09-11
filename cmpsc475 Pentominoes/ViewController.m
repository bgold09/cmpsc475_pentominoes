//
//  ViewController.m
//  cmpsc475 Pentominoes
//
//  Created by BRIAN J GOLDEN on 9/9/13.
//  Copyright (c) 2013 BRIAN J GOLDEN. All rights reserved.
//

#import "ViewController.h"

#define kNumberBoardImages 6

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *Board;
@property (strong, nonatomic) NSArray *boardImages;
@property (strong, nonatomic) NSArray *playingPieceImageViews;
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    _boardImages = [self createBoardImages];
    _playingPieceImageViews = [self createPlayingPieceImageViews];
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
    UIImage *newBoard = self.boardImages[buttonTag];
    [self.Board setImage:newBoard];
    self.currentBoardNumber = buttonTag;
}

- (IBAction)ResetPressed:(UIButton *)sender {
}

- (IBAction)SolvePressed:(UIButton *)sender {
}

- (void) placePlayingPiecesInStartPositions {
    for (UIImageView *playingPiece in self.playingPieceImageViews) {
        [self.view addSubview:playingPiece];
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

@end
