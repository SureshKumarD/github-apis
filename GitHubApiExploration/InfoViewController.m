//
//  InfoViewController.m
//  GitHubApiExploration
//
//  Created by Suresh on 12/17/15.
//  Copyright © 2015 Suresh. All rights reserved.
//

#import "InfoViewController.h"
#import "Constants.pch"
#import "AppDelegate.h"

#import "InfoHeaderCell.h"
#import "InfoTableViewCell.h"
#import "CustomTableView.h"

#import "SDWebImage/UIImageView+WebCache.h"


@interface InfoViewController ()<UITableViewDataSource, UITableViewDelegate>
@property NSString *owner,*repoName;

@property (weak, nonatomic) IBOutlet UILabel *repoTitleLabel;

@property (weak, nonatomic) IBOutlet UILabel *repoDescriptionLabel;
@property (weak, nonatomic) IBOutlet CustomTableView *tableView;
@property (strong, atomic)NSArray *issuesInfoArray, *contributorInfoArray;
@property BOOL isLoadedFirstTime;

@end

@implementation InfoViewController

/***
 * Concept implemented :- The repository object(NSDictionary) being passed to this screen,
 * Here, we parse the required attributes, and make a server call to fetch newest 3 issues(by default, the issues github api returns the newest api, so sorting parameters applied), and updated in the UITableView, in which only the particular section is being reloaded. In this case issues section is '0'
 * Similarly the contributors also being fetched by the server call, and updates the corresponding 
 * UITableView section, in this case section is '1'
 ***/

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initializations];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setTranslucent:NO];
    /**
     *  Call to fetch top 3 issues.
     **/
    [self getTopThreeItems:NO];
    
    /**
     *  Call to fetch top 3 contributors.
     **/

    [self getTopThreeItems:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.tableView.delegate = nil;
    self.tableView.dataSource = nil;
    [self stopAllNetworkCalls];
}
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)initializations {
    self.owner = [[self.repositoryInfo valueForKey:@"owner"] valueForKey:@"login"];
    self.repoName = [self.repositoryInfo valueForKey:@"name"];
    self.title = self.repoName;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    self.tableView.allowsSelection = NO;
    self.repoTitleLabel.text = [self.repositoryInfo valueForKey:@"full_name"];
    self.repoDescriptionLabel.text = [self.repositoryInfo valueForKey:@"description"];
    self.isLoadedFirstTime = YES;
}

/**
 * Get Top 3 Issues/ Contributors
 **/

- (void)getTopThreeItems:(BOOL)isContributors{
    NSString *trailingPart = nil;
    API_NAME apiName;
    if(isContributors) {
        trailingPart = URL_CONTRIBUTORS;
        apiName = CONTRIBUTORS;
    }
    else {
        trailingPart = URL_ISSUES_EVENTS;
        apiName = ISSUES;
    }
    
    NSString *urlString = [NSString stringWithFormat:@"%@%@%@/%@%@",BASE_URL,URL_ISSUES_REPOS,self.owner,self.repoName ,trailingPart];
    NSLog(@"urlString %@",urlString);
    
    [APP_DELEGATE_INSTANCE.netWorkObject getResponseWithUrl:urlString  withRequestApiName:apiName  withCompletionHandler:^(id response, NSError *error) {
        //        NSLog(@"%@", response);
        if([response isKindOfClass:[NSArray class]]) {
            if(!isContributors) {
                /**
                 *  Load the issues data, and update the UI
                 **/
                self.issuesInfoArray = [[NSArray alloc]initWithArray:response];
                NSRange range = NSMakeRange(0, 1);
                NSIndexSet *section = [NSIndexSet indexSetWithIndexesInRange:range];
                [self.tableView reloadSections:section withRowAnimation:UITableViewRowAnimationTop];
            }else {
                
                /**
                 *  Load the contributors data, and update the UI
                 **/
                self.contributorInfoArray = [[NSArray alloc]initWithArray:response];
                NSRange range = NSMakeRange(1, 1);
                NSIndexSet *section = [NSIndexSet indexSetWithIndexesInRange:range];
                [self.tableView reloadSections:section withRowAnimation:UITableViewRowAnimationTop];
            }
           
        }
       
    }];

}

#pragma mark - TableView Delegate & Datasources

#pragma mark - TableView DataSource & Delegates
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger arrayCount = 0;
    if(section == 0) {
        arrayCount = [self.issuesInfoArray count];
        if (arrayCount == 0) {
            if(self.isLoadedFirstTime)
                return arrayCount;
            else
                return 1;
        }else
            return arrayCount;
    }else {
        arrayCount = [self.contributorInfoArray count];
        if (arrayCount == 0) {
            if(self.isLoadedFirstTime)
                return arrayCount;
            else
                return 1;
        }else
            return arrayCount;
    }
        
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    /**
     * If the array count is zero, display ' no data available ' text.
     **/
    static NSString *urlString;
    if((([indexPath section] == NUMBER_ZERO) && ([self.issuesInfoArray count ] == NUMBER_ZERO)) || (([indexPath section] == NUMBER_ONE) && [self.contributorInfoArray count] == NUMBER_ZERO)) {
        InfoHeaderCell *cell = [ tableView dequeueReusableCellWithIdentifier:@"InfoHeaderCell"];
        cell.headerLabel.text = @"No Data Available";
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        return cell;
    }else {
    
        /**
         * If the array count is greater than 1, display each data;
         **/
        
        InfoTableViewCell *cell = [ tableView dequeueReusableCellWithIdentifier:@"InfoTableViewCell"];
        NSDictionary *dictionary = nil;
        if([indexPath section] == 0){
            dictionary = [self.issuesInfoArray objectAtIndex:[indexPath row]];
            cell.ownerCaptionLabel.text = @"Actor";
            cell.infoLabel1.text = [NSString stringWithFormat:@"Issue id: %@", [dictionary valueForKey:@"id"] ];
            cell.infoLabel2.text = [NSString stringWithFormat:@"Created at: %@",[dictionary valueForKey:@"created_at"]];
            urlString = [[dictionary valueForKey:@"actor"] valueForKey:@"avatar_url"];
            [cell.ownerAvatarImageView sd_setImageWithURL:[NSURL URLWithString:urlString] placeholderImage:[UIImage imageNamed:@"placeholder"]];
        }else {
            
            dictionary = [self.contributorInfoArray objectAtIndex:[indexPath row]];
            cell.ownerCaptionLabel.text = @"Owner";
            cell.infoLabel1.text = [NSString stringWithFormat:@"Contributor username: %@", [dictionary valueForKey:@"login"] ];
            cell.infoLabel2.text = [NSString stringWithFormat:@"Contributions: %@",[dictionary valueForKey:@"contributions"]];
            urlString = [dictionary valueForKey:@"avatar_url"];
            [cell.ownerAvatarImageView sd_setImageWithURL:[NSURL URLWithString:urlString] placeholderImage:[UIImage imageNamed:@"placeholder"]];
        }
        
        
        return cell;
        
    }
    
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
     if(((section == NUMBER_ZERO) && ([self.issuesInfoArray count ] == NUMBER_ZERO)) || ((section == NUMBER_ONE) && [self.contributorInfoArray count] == NUMBER_ZERO))
        return NUMBER_ZERO;
    else
        
        return 44.0f;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 90.0f;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view =[[UIView alloc] initWithFrame:(CGRect){0,0,WINDOW_FRAME_WIDTH, 44.0f}];
    UILabel *label = [[UILabel alloc] initWithFrame:(CGRect) {15,12,WINDOW_FRAME_WIDTH-30, 21.0f}];
    if(section == 0)
        label.text = @"Top Issues";
    else
        label.text = @"Top Contributors";
    [label setFont:[UIFont fontWithName:@"Times New Roman-Bold" size:13.0f]];
    label.textColor = kBLACK_COLOR;
    label.textAlignment = NSTextAlignmentLeft;
    [view addSubview:label];
    return view;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Remove seperator inset
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    // Prevent the cell from inheriting the Table View's margin settings
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        [cell setPreservesSuperviewLayoutMargins:NO];
    }
    
    // Explictly set your cell's layout margins
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
    
    UIView * additionalSeparator = [[UIView alloc] initWithFrame:CGRectMake(15,cell.frame.size.height-1,cell.frame.size.width-30,1)];
    additionalSeparator.backgroundColor = kGRAY_COLOR;
    [cell addSubview:additionalSeparator];
}


-(void)dealloc {
    self.tableView.delegate = nil;
    self.tableView.dataSource = nil;
    [self stopAllNetworkCalls];
}

- (void)stopAllNetworkCalls {
    [APP_DELEGATE_INSTANCE.netWorkObject cancelAllRequests];
}


@end
