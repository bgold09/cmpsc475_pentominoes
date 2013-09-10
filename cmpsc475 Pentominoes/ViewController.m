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
- (IBAction)BoardButtonPressed:(UIButton *)sender;
- (IBAction)ResetPressed:(UIButton *)sender;
- (IBAction)SolvePressed:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UIImageView *Board;
@property (strong, nonatomic) NSArray *boardImages;

@end

@implementation ViewController

static NSString *kBoardImagePrefix = @"Board";
static NSString *kBoardImageFileExtension = @"png";

- (void)viewDidLoad
{
    [super viewDidLoad];
    _boardImages = [self createBoardImages];
	// Do any additional setup after loading the view, typically from a nib.
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
}

- (IBAction)ResetPressed:(UIButton *)sender {
}

- (IBAction)SolvePressed:(UIButton *)sender {
}
                    
- (NSArray *) createBoardImages {
    NSMutableArray *newBoardImages = [[NSMutableArray alloc] init];
    
    for (NSInteger boardImageNumber = 0; boardImageNumber < kNumberBoardImages; boardImageNumber++) {
        NSString *boardImageFileName = [[NSString alloc] initWithFormat:@"%@%d", kBoardImagePrefix, boardImageNumber];
        NSString *boardImageFilePath = [[NSBundle mainBundle] pathForResource:boardImageFileName ofType:kBoardImageFileExtension];
        UIImage *boardImage = [[UIImage alloc] initWithContentsOfFile:boardImageFilePath];
        [newBoardImages addObject:boardImage];
    }
    
    return newBoardImages;
}

@end
