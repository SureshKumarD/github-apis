//
//  NetworkManager.m
//  GitHubApiExploration
//
//  Created by Suresh on 12/17/15.
//  Copyright © 2015 Suresh. All rights reserved.
//

#import "NetworkManager.h"
#define ShowNetworkActivityIndicator() [UIApplication sharedApplication].networkActivityIndicatorVisible = YES
#define HideNetworkActivityIndicator() [UIApplication sharedApplication].networkActivityIndicatorVisible = NO

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


- (void)getResponseWithUrl:(NSString *)urlString withCompletionHandler:(void (^)(id response, NSError *error))handler {
    ShowNetworkActivityIndicator();
    NSURL *url = [[NSURL alloc] initWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    op.responseSerializer = [AFJSONResponseSerializer serializer];
    [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        HideNetworkActivityIndicator();
        if(!operation.error) {
            //Return to the caller method.
            
            handler(responseObject,operation.error);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        HideNetworkActivityIndicator();
        NSLog(@"Error  %@", [error localizedDescription]);
    }];
    
   
    [[NSOperationQueue mainQueue] addOperation:op];
    
}

@end
