//
//  ViewController.m
//  cmpsc475 Pentominoes
//
//  Created by BRIAN J GOLDEN on 9/9/13.
//  Copyright (c) 2013 BRIAN J GOLDEN. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
- (IBAction)BoardButtonPressed:(UIButton *)sender;
- (IBAction)ResetPressed:(UIButton *)sender;
- (IBAction)SolvePressed:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UIImageView *Board;

@end

@implementation ViewController

static NSString *kBoardImagePrefix = @"Board";
static NSString *kBoardImageFileExtension = @"png";

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)BoardButtonPressed:(UIButton *)sender {
    NSInteger buttonTag = [sender tag];
    NSString *boardFileName = [[NSString alloc] initWithFormat:@"%@%d", kBoardImagePrefix, buttonTag];
    NSString *boardFilePath = [[NSBundle mainBundle] pathForResource:boardFileName
                                                     ofType:kBoardImageFileExtension];
    UIImage *newBoard = [[UIImage alloc] initWithContentsOfFile:boardFilePath];
    
    [self.Board setImage:newBoard];
}

- (IBAction)ResetPressed:(UIButton *)sender {
}

- (IBAction)SolvePressed:(UIButton *)sender {
}
@end
