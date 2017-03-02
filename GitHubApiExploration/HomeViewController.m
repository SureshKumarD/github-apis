//
//  HomeViewController.m
//  GitHubApiExploration
//
//  Created by Suresh on 12/17/15.
//  Copyright © 2015 Suresh. All rights reserved.
//

#import "HomeViewController.h"
#import "InfoViewController.h"
#import "Headers.pch"
#import "Constants.pch"
#import "AppDelegate.h"
#import "CustomTableView.h"
@interface HomeViewController ()<UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>
@property (weak, nonatomic) IBOutlet CustomTableView *tableView;

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property BOOL isPageRefresing;
@property NSInteger currentpagenumber;
@property (strong, nonatomic)NSString *searchedText;
@property (strong, nonatomic) NSMutableArray *searchResults;

@end

@implementation HomeViewController

/***
 * Concept implemented :- Start typing any programming language name, 
 * the server call fetches corresponding github language repositories, where the results are sorted by star rating in descending order. And lazyloading technique is implemented through pagination. Every hit fetches 50 entries, scolling down again fetches more results available.
 ***/

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initializations];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initializations {
    
    self.searchBar.delegate = self;
    self.currentpagenumber = NUMBER_ONE;
    self.searchResults = [[NSMutableArray alloc] init];
    self.title = HOME_SCREEN_TITLE;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
}
#pragma mark - UISearchbar Delegate
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [self.searchResults removeAllObjects];
    _currentpagenumber = NUMBER_ONE;
    if(!searchText || [searchText length] == NUMBER_ZERO) {
        [self.tableView reloadData];
        return;
    }
    searchText = [searchText lowercaseString];
    _searchedText = [searchText stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
    [self getResults:_currentpagenumber];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self.searchResults removeAllObjects];
    [self.tableView reloadData];
    [searchBar resignFirstResponder];
    _currentpagenumber = NUMBER_ONE;
    [self getResults:_currentpagenumber];
}

#pragma mark - TableView DataSource & Delegates
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return NUMBER_ONE;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.searchResults count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"Cell";
    static NSString *descriptionString = nil;
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if(!cell ) {
        cell = [[ UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.numberOfLines = NUMBER_ZERO;
        cell.textLabel.minimumScaleFactor = 0.5;
        cell.detailTextLabel.numberOfLines = NUMBER_ZERO;
        cell.detailTextLabel.minimumScaleFactor = 0.25;
    }
    @try {
        cell.textLabel.text =  [[self.searchResults objectAtIndex:[indexPath row]] valueForKey:@"full_name"];
        descriptionString = [[self.searchResults objectAtIndex:[indexPath row]] valueForKey:@"description"];
        if([descriptionString length] > 50)
            descriptionString = [descriptionString substringToIndex:50];
        cell.detailTextLabel.text =  descriptionString;

    }
    @catch (NSException *exception) {
        NSLog(@"Exception caught : %@", [exception description]);
    }
      
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self stopAllNetworkCalls];
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    InfoViewController *infoVC = [storyBoard instantiateViewControllerWithIdentifier:@"InfoViewController"];
    infoVC.repositoryInfo = [self.searchResults objectAtIndex:[indexPath row]];
    [self.navigationController pushViewController:infoVC animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80.0f;
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
    
    UIView * additionalSeparator = [[UIView alloc] initWithFrame:CGRectMake(15,cell.frame.size.height-0.5,cell.frame.size.width-30,0.5)];
    additionalSeparator.backgroundColor = kGRAY_COLOR;
    [cell addSubview:additionalSeparator];
}



#pragma mark - ScrollView

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [self.view endEditing:YES];
    
    if(self.tableView.contentOffset.y >= (self.tableView.contentSize.height - self.tableView.bounds.size.height)) {
        
        if(_isPageRefresing == NO){
            _isPageRefresing = YES;
            _currentpagenumber = _currentpagenumber +1;
            [self getResults:_currentpagenumber];
        }
    }
    
}

/**
 * Update the UI once data has been fetched successfully.
 **/
-(void)updateTableViewWithResults:(NSArray *)results forPage:(NSInteger)pageNo{
    if(pageNo == 1){
        self.searchResults = [results mutableCopy];
    }
    else{
        [self.searchResults addObjectsFromArray:results];
    }
    _isPageRefresing = NO;
    [self.tableView reloadData];
}


-(void)getResults:(NSInteger)pageNumber{
    
    NSString *urlString = [NSString stringWithFormat:@"%@%@q=%@%@%@%@&page=%d&per_page=50",BASE_URL,URL_SEARCH_REPOS, _searchedText,URL_SEARCH_REPO_QUERY_FRAGMENT,_searchedText,URL_SEARCH_REPO_TRAIL_FRAGMENT,(int)pageNumber ];
    NSLog(@"urlString %@",urlString);
    [[NetworkManager sharedInstance]  getResponseWithUrl:urlString  withRequestApiName:REPOS withCompletionHandler:^(id response, NSError *error) {
//        NSLog(@"%@", response);
        [self updateTableViewWithResults:[response valueForKey:@"items"] forPage:_currentpagenumber];
    }];

}

- (void)stopAllNetworkCalls {
    [[NetworkManager sharedInstance] cancelAllRequests];
}
@end
