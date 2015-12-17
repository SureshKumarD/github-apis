//
//  BaseViewController.m
//  GitHubApiExploration
//
//  Created by Suresh on 12/17/15.
//  Copyright © 2015 Suresh. All rights reserved.
//

#import "BaseViewController.h"
#import "Headers.pch"

@interface BaseViewController ()

@end

@implementation BaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self addReachabilityObserver];
    
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self removeReachabilityObserver];
}



/**
 * Add Reachability Observer, when the view did appear
 **/
- (void)addReachabilityObserver {
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkChanged:) name:AFNetworkingReachabilityDidChangeNotification object:nil];
}



/**
 * Remove Reachability Observer, while leaving particular viewcontroller
 **/
- (void)removeReachabilityObserver {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:AFNetworkingReachabilityDidChangeNotification
     
                                                  object:nil];
}


/**
 * Observer Notificed, when the network changed
 **/

- (void)networkChanged:(id)sender {
    BOOL isReachable = [AFNetworkReachabilityManager sharedManager].reachable;
    if(!isReachable) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Network Unavailable!" message:@"You're seems to be offline, please check your internet connection" delegate:nil cancelButtonTitle:@"Ok, Got It!" otherButtonTitles:nil, nil];
        [alertView show];
    }
}





#pragma mark - Navigation

/*// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
