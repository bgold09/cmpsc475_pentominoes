//
//  InfoViewController.m
//  cmpsc475 Pentominoes
//
//  Created by BRIAN J GOLDEN on 9/19/13.
//  Copyright (c) 2013 BRIAN J GOLDEN. All rights reserved.
//

#import "InfoViewController.h"
#import "Model.h"

@interface InfoViewController ()
@property (retain, nonatomic) Model *model;
@property (retain, nonatomic) NSArray *textColors;
@property (retain, nonatomic) NSDictionary *themeColors;
@property (retain, nonatomic) IBOutlet UIButton *originalThemeButton;
@property (retain, nonatomic) IBOutlet UIButton *grapeThemeButton;
@property (retain, nonatomic) IBOutlet UIButton *honeydewThemeButton;
@property (retain, nonatomic) IBOutlet UIImageView *originalCheckMark;
@property (retain, nonatomic) IBOutlet UIImageView *grapeCheckMark;
@property (retain, nonatomic) IBOutlet UIImageView *honeydewCheckMark;
- (IBAction)themeButtonPressed:(UIButton *)sender;
- (IBAction)dismissPressed:(UIButton *)sender;

@end

@implementation InfoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (id) initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        _model = [[Model alloc] init];
        _textColors = [[self.model allTextColors] retain];
    }
    return self;
}

- (void)dealloc {
    [_textColors release];
    [_themeColors release];
    [_originalThemeButton release];
    [_grapeThemeButton release];
    [_honeydewThemeButton release];
    [_originalCheckMark release];
    [_grapeCheckMark release];
    [_honeydewCheckMark release];
    [super dealloc];
}

- (void)viewDidLoad
{   
    [super viewDidLoad];
    UIColor *backgroundColor = [UIColor blackColor];
    
    switch (self.themeNumber) {
        case 0:
            backgroundColor = self.originalThemeButton.backgroundColor;
            break;
        case 1:
            backgroundColor = self.grapeThemeButton.backgroundColor;
            break;
        case 2:
            backgroundColor = self.honeydewThemeButton.backgroundColor;
            break;
        default:
            break;
    }
    
    UIColor *textColor = [self.model textColorForTheme:self.themeNumber];
    NSDictionary *theme = [[NSDictionary alloc] initWithObjectsAndKeys:backgroundColor, @"background-color", textColor, @"text-color", nil];
    [theme autorelease];
    
    self.themeColors = theme;
    [self setCheckMarkToAppearForTheme:self.themeNumber];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)themeButtonPressed:(UIButton *)sender {
    NSInteger buttonNumber = sender.tag;
    self.themeNumber = buttonNumber;
    UIColor *backgroundColor = [sender backgroundColor];
    UIColor *textColor = [self.model textColorForTheme:self.themeNumber];
    NSDictionary *theme = [[NSDictionary alloc] initWithObjectsAndKeys:backgroundColor, @"background-color", textColor, @"text-color", nil];
    [theme autorelease];
    self.themeColors = theme;
    [self setCheckMarkToAppearForTheme:self.themeNumber];
}

- (IBAction)dismissPressed:(UIButton *)sender {
    [self.delegate dismissMe:self.themeColors withThemeNumber:self.themeNumber];
}

- (void)setCheckMarkToAppearForTheme:(NSInteger)themeNumber {
    self.originalCheckMark.hidden = YES;
    self.grapeCheckMark.hidden = YES;
    self.honeydewCheckMark.hidden = YES;
    
    switch (themeNumber) {
        case 0:
            self.originalCheckMark.hidden = NO;
            break;
        case 1:
            self.grapeCheckMark.hidden = NO;
            break;
        case 2:
            self.honeydewCheckMark.hidden = NO;
        default:
            break;
    }
}

@end
