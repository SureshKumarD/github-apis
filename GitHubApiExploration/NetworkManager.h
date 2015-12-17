//
//  NetworkManager.h
//  GitHubApiExploration
//
//  Created by Suresh on 12/17/15.
//  Copyright © 2015 Suresh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking/AFNetworking.h"
#import "ActivityIndicatorView.h"
#import "Constants.pch"

@interface NetworkManager : NSObject

@property (nonatomic,strong) AFHTTPRequestOperationManager *manager;
@property (nonatomic, strong) AFHTTPRequestOperation *operation;
@property (nonatomic, strong) ActivityIndicatorView *activityIndicatorView;

/**
 * Create a single instance for NetworkManager class.
 **/
+(NetworkManager *)sharedNetworkManager;


/**
 * GET request with handler
 **/
- (void)getResponseWithUrl:(NSString *)urlString withRequestApiName:(API_NAME)apiName withCompletionHandler:(void (^)(id response, NSError *error))handler;

- (void) cancelAllRequests;
@end
