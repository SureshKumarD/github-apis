//
//  HomeViewController.m
//  GitHubApiExploration
//
//  Created by Suresh on 12/17/15.
//  Copyright © 2015 Suresh. All rights reserved.
//

#import "HomeViewController.h"
#import "Headers.pch"
#import "Constants.pch"
#import "AppDelegate.h"

@interface HomeViewController ()<UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property BOOL isPageRefresing;
@property NSInteger currentpagenumber;
@property (strong, nonatomic)NSString *searchedText;
@property (strong, nonatomic) NSMutableArray *searchResults;

@end

@implementation HomeViewController

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
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.searchBar.delegate = self;
    self.currentpagenumber = 0;
    self.searchResults = [[NSMutableArray alloc] init];
}
#pragma mark - UISearchbar Delegate
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    _searchedText = [searchText stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] ;
    [self getResults:_currentpagenumber];
}


#pragma mark - TableView DataSource & Delegates
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.searchResults count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if(!cell ) {
        cell = [[ UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
    }
    cell.textLabel.text =  [[self.searchResults objectAtIndex:[indexPath row]] valueForKey:@"name"];
    cell.detailTextLabel.text =  [[self.searchResults objectAtIndex:[indexPath row]] valueForKey:@"full_name"];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80.0f;
}


#pragma mark - ScrollView

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    if(self.tableView.contentOffset.y >= (self.tableView.contentSize.height - self.tableView.bounds.size.height)) {
        
        //NSLog(@" scroll to bottom!");
        if(_isPageRefresing == NO){ // no need to worry about threads because this is always on main thread.
            
            _isPageRefresing = YES;
//            [self showMBProfressHUDOnView:self.view withText:@"Please wait..."];
            _currentpagenumber = _currentpagenumber +1;
            [self getResults:_currentpagenumber];
        }
    }
    
}

// you can get pageNo from tag
// make sure this is called in main thread
-(void)didFinishRecordsRequest:(NSArray *)results forPage:(NSInteger)pageNo{
    if(pageNo == 1){
        self.searchResults = [results mutableCopy];
    }
    else{
        [self.searchResults addObjectsFromArray:results];
    }
    _isPageRefresing = NO;
    [self.tableView reloadData];
}


-(void)didFailedChalkBoardRequestWithError:(NSError *)error{
    
    //If Since subsequent refresh calls(for page 2 or page 3 fails)
    //then undo the current page number
    _currentpagenumber--;
    _isPageRefresing = NO;
}


-(void)getResults:(NSInteger)pageNumber{
    
    
    NSString *urlString = [NSString stringWithFormat:@"%@%@%@%@%@&page=%d&per_page=50",BASE_URL,URL_FRAGMENT_REPOS, URL_SEARCH_REPO_QUERY_FRAGMENT,_searchedText,URL_SEARCH_REPO_TRAIL_FRAGMENT,(int)pageNumber ];
    [APP_DELEGATE_INSTANCE.netWorkObject getResponseWithUrl:urlString withCompletionHandler:^(id response, NSError *error) {
        NSLog(@"%@", response);
        [self didFinishRecordsRequest:[response valueForKey:@"items"] forPage:_currentpagenumber];
    }];

}
@end