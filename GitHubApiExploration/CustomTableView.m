//
//  CustomTableView.m
//  GitHubApiExploration
//
//  Created by Suresh on 12/17/15.
//  Copyright © 2015 Suresh. All rights reserved.
//

#import "CustomTableView.h"

@implementation CustomTableView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (BOOL)allowsHeaderViewsToFloat {
    
    return NO;
}

- (BOOL) allowsFooterViewsToFloat {
    return NO;
}


@end
