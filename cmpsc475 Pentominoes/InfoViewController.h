//
//  InfoViewController.h
//  cmpsc475 Pentominoes
//
//  Created by BRIAN J GOLDEN on 9/19/13.
//  Copyright (c) 2013 BRIAN J GOLDEN. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol InfoDelegate <NSObject>

- (void)dismissMe;

@end

@interface InfoViewController : UIViewController
@property (nonatomic, assign) id<InfoDelegate> delegate;

@end
