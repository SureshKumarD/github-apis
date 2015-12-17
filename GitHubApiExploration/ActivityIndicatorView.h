//
//  ActivityIndicatorView.h
//  GitHubApiExploration
//
//  Created by Suresh on 12/17/15.
//  Copyright © 2015 Suresh. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ActivityIndicatorView : UIView


@property (nonatomic,strong) UIActivityIndicatorView *loadingView;
@property (nonatomic, strong) UILabel *currentActivityLabel;
@property (nonatomic, strong) UIImageView *activityImageView;

-(void)startActivityWithText:(NSString *)text;
- (void)stopActivity;

@end
