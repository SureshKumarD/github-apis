//
//  ActivityIndicatorView.m
//  GitHubApiExploration
//
//  Created by Suresh on 12/17/15.
//  Copyright © 2015 Suresh. All rights reserved.
//

#import "ActivityIndicatorView.h"
#import "Constants.pch"

@implementation ActivityIndicatorView

@synthesize currentActivityLabel = _currentActivityLabel,loadingView = _loadingView, activityImageView = _activityImageView;

- (id) init {
    
    if(self = [super init]) {
        
        self.frame = (CGRect){[[UIScreen mainScreen] bounds].size.width/2 - 60,[[UIScreen mainScreen] bounds].size.height/2 - 50, 120, 100};
        
        _loadingView = [[UIActivityIndicatorView alloc]initWithFrame:(CGRect){self.frame.size.width/2 - 25, 20, 50, 50}];
        _loadingView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
        [self addSubview:_loadingView];
        
        _currentActivityLabel = [[UILabel alloc]init];
        _currentActivityLabel.frame = (CGRect){10,70,self.frame.size.width-20,30};
        _currentActivityLabel.textAlignment = NSTextAlignmentCenter;
        _currentActivityLabel.textColor = [UIColor whiteColor];
        _currentActivityLabel.adjustsFontSizeToFitWidth = YES;
        [_currentActivityLabel setMinimumScaleFactor:0.5];
        [_currentActivityLabel setFont:[UIFont fontWithName:@"Times New Roman" size:13.0f]];
        [self addSubview:_currentActivityLabel];
        
        self.layer.cornerRadius = 5.0f;
        self.backgroundColor = kDARK_BLUE_COLOR;
        
    }
    
    return self;
}

-(void)startActivityWithText:(NSString *)text{
    UIWindow* mainWindow = [[UIApplication sharedApplication] keyWindow];
    [UIView animateWithDuration:1.0 animations:^{
        
            [mainWindow addSubview: self];
            [_loadingView startAnimating];
            [_currentActivityLabel setText:text];
        
        
    }];
    
    
}
- (void)stopActivity{
    UIWindow* mainWindow = [[UIApplication sharedApplication] keyWindow];
    [UIView animateWithDuration:1.0 animations:^{
        for(UIView *view in mainWindow.subviews) {
            
            if([view isKindOfClass:[ActivityIndicatorView class]]) {
                [view removeFromSuperview];
            }
        }
        [_loadingView stopAnimating];
    }];
}




@end
