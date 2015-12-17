//
//  NetworkManager.m
//  GitHubApiExploration
//
//  Created by Suresh on 12/17/15.
//  Copyright © 2015 Suresh. All rights reserved.
//

#import "NetworkManager.h"
#import "Constants.pch"
#define ShowNetworkActivityIndicator() [UIApplication sharedApplication].networkActivityIndicatorVisible = YES
#define HideNetworkActivityIndicator() [UIApplication sharedApplication].networkActivityIndicatorVisible = NO

@implementation NetworkManager
@synthesize operation = _operation, manager = _manager;
static NetworkManager *networkManager = nil;

- (instancetype)init {
    if(self = [super init]) {
        self.activityIndicatorView = [[ActivityIndicatorView alloc] init];
        self.manager = [AFHTTPRequestOperationManager manager];
        self.operation = [[AFHTTPRequestOperation alloc]init];
    }
    return self;
}
+(NetworkManager *)sharedNetworkManager {
    if(!networkManager) {
        networkManager = [[NetworkManager alloc]init];
    }
    return networkManager;
    
}


- (void)getResponseWithUrl:(NSString *)urlString withRequestApiName:(API_NAME)apiName withCompletionHandler:(void (^)(id response, NSError *error))handler {
    if(!(apiName == REPOS && [urlString containsString:@"page=1"]))
    [self startActivity];
     ShowNetworkActivityIndicator();
//    NSURL *url = [[NSURL alloc] initWithString:urlString];
//    NSURLRequest *request = [NSURLRequest requestWithURL:url];
//    AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
//    op.responseSerializer = [AFJSONResponseSerializer serializer];
//    [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
//        
//        [self stopActivity];
//         HideNetworkActivityIndicator();
//        if(!operation.error) {
//            //Return to the caller method.
//            
//            handler(responseObject,operation.error);
//        }
//        
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//    
//        [self stopActivity];
//         HideNetworkActivityIndicator();
//        NSLog(@"Error  %@", [error localizedDescription]);
//    }];
//    
//   
//    [[NSOperationQueue mainQueue] addOperation:op];
    _manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    _manager.responseSerializer = [AFJSONResponseSerializer serializer];
    _manager.requestSerializer.HTTPMethodsEncodingParametersInURI = [NSSet setWithArray:@[@"POST", @"GET"]];

    _operation =
    
    [_manager GET:urlString parameters:nil success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        [self stopActivity];
        HideNetworkActivityIndicator();

        if(!operation.error) {
            /* call back to the caller */
            handler(responseObject,operation.error);
        }else
            handler(nil,nil);
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        [self stopActivity];
        HideNetworkActivityIndicator();
        NSLog(@"Error  %@", [error localizedDescription]);
    }];
    
    [_operation start];
    
}

- (void)startActivity {
    
    [self.activityIndicatorView startActivityWithText:@"Processing..."];
   
}

- (void)stopActivity {
    [self.activityIndicatorView stopActivity];
   
}

- (void)cancelAllRequests {
    NSLog(@"Cancel all request called");
    [_operation cancel];
}
@end
