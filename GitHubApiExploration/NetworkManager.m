//
//  NetworkManager.m
//  GitHubApiExploration
//
//  Created by Suresh on 12/17/15.
//  Copyright © 2015 Suresh. All rights reserved.
//

#import "NetworkManager.h"

@implementation NetworkManager
static NetworkManager *networkManager = nil;

- (instancetype)init {
    if(self = [super init]) {
        
    }
    return self;
}
+(NetworkManager *)sharedNetworkManager {
    if(!networkManager) {
        networkManager = [[NetworkManager alloc]init];
    }
    return networkManager;
    
}


- (void)getResponseWithUrl:(NSString *)url withCompletionHandler:(void (^)(id response, NSError *error))handler {
    NSURL *URL = [NSURL URLWithString:url];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager GET:URL.absoluteString parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        handler(responseObject,task.error);
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];}

@end
