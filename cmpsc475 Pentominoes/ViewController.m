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
@property NSInteger currentBoardNumber;
- (IBAction)BoardButtonPressed:(UIButton *)sender;
- (IBAction)ResetPressed:(UIButton *)sender;
- (IBAction)SolvePressed:(UIButton *)sender;

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
    self.currentBoardNumber = buttonTag;
}

- (IBAction)ResetPressed:(UIButton *)sender {
}

- (IBAction)SolvePressed:(UIButton *)sender {
}
                    
- (NSArray *) createBoardImages {
    NSMutableArray *newBoardImages = [[NSMutableArray alloc] init];
    NSBundle *bundle = [NSBundle mainBundle];
    
    for (NSInteger boardImageNumber = 0; boardImageNumber < kNumberBoardImages; boardImageNumber++) {
        NSString *boardImageFileName = [[NSString alloc] initWithFormat:@"%@%d", kBoardImagePrefix, boardImageNumber];
        NSString *boardImageFilePath = [bundle pathForResource:boardImageFileName ofType:kBoardImageFileExtension];
        UIImage *boardImage = [[UIImage alloc] initWithContentsOfFile:boardImageFilePath];
        [newBoardImages addObject:boardImage];
    }
    
    return newBoardImages;
}

@end
