//
//  InfoViewController.h
//  cmpsc475 Pentominoes
//
//  Created by BRIAN J GOLDEN on 9/19/13.
//  Copyright (c) 2013 BRIAN J GOLDEN. All rights reserved.
//

#import <UIKit/UIKit.h>

@class InfoViewController;

@protocol InfoDelegate <NSObject>

- (void)dismissMe:(NSDictionary *)themeColors withThemeNumber:(NSInteger)themeNumber;

@end

@interface InfoViewController : UIViewController
@property (nonatomic, assign) id<InfoDelegate> delegate;
@property NSInteger themeNumber;

@end
