//
//  NetworkManager.h
//  GitHubApiExploration
//
//  Created by Suresh on 12/17/15.
//  Copyright © 2015 Suresh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking/AFNetworking.h"
@interface NetworkManager : NSObject
@property (nonatomic,strong) AFURLSessionManager *manager;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicatorView;

/**
 * Create a single instance for NetworkManager class.
 **/
+(NetworkManager *)sharedNetworkManager;


/**
 * GET request with handler
 **/
- (void)getResponseWithUrl:(NSString *)url withCompletionHandler:(void (^)(id response, NSError *error))handler;
@end
