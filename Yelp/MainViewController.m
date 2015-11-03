//
//  MainViewController.m
//  Yelp
//
//  Created by Timothy Lee on 3/21/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

#import "MainViewController.h"
#import "YelpBusiness.h"
#import "YelpContentCell.h"
#import "FiltersViewController.h"
#import "JTProgressHUD.h"

@interface MainViewController () <UITableViewDataSource, UITableViewDelegate, FiltersViewControllerDelegate, UISearchBarDelegate>
@property (weak, nonatomic) IBOutlet UITableView *yelpTableView;
@property (strong, nonatomic) NSMutableArray *businesses;
@property (strong, nonatomic) NSMutableString *searchTerm;
@property (strong, nonatomic) NSNumber *dealsOn;
@property (strong, nonatomic) NSString *categoryFilter;
@property (strong, nonatomic) NSNumber *sortMode;
@property (strong, nonatomic) NSNumber *distance;
@property (strong, nonatomic) NSNumber *currentOffset;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.searchTerm = [[NSMutableString alloc] initWithString:@"Restaurants"];
    self.yelpTableView.dataSource = self;
    self.yelpTableView.delegate = self;
    [self.yelpTableView registerNib:[UINib nibWithNibName:@"YelpContentCell" bundle:nil] forCellReuseIdentifier:@"yelpContentCell"];
    self.yelpTableView.rowHeight = UITableViewAutomaticDimension;
    self.yelpTableView.estimatedRowHeight = 120;
    self.businesses = [[NSMutableArray alloc] init];
    self.title = @"Listing";
    UISearchBar *search = [[UISearchBar alloc] init];
    search.returnKeyType = UIReturnKeySearch;
    search.delegate = self;
    self.navigationItem.titleView = search;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Filter" style:UIBarButtonItemStylePlain target:self action:@selector(onFilterTapped)];
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    gestureRecognizer.cancelsTouchesInView = NO;
    [self.yelpTableView addGestureRecognizer:gestureRecognizer];
    [self yelpSearch:self.searchTerm withCategory:@"" withDeals:[@NO boolValue] withSortMode:YelpSortModeBestMatched withDistance:nil atOffset:@0];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    CGFloat actualPosition = scrollView.contentOffset.y;
    CGFloat contentHeight = scrollView.contentSize.height - self.yelpTableView.frame.size.height;
    if (actualPosition >= contentHeight && self.businesses.count > 0) {
        NSLog(@"Reached end");
        YelpSortMode yelpSortMode;
        if(self.sortMode) {
            yelpSortMode = (YelpSortMode) [self.sortMode intValue];
        } else {
            yelpSortMode = YelpSortModeBestMatched;
        }
        self.currentOffset = [NSNumber numberWithInt:([self.currentOffset intValue] + 20)];
        [self yelpSearch:self.searchTerm withCategory:self.categoryFilter withDeals:[self.dealsOn boolValue] withSortMode:yelpSortMode withDistance:self.distance atOffset:self.currentOffset];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.yelpTableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self hideKeyboard];
    NSString *text = [searchBar text];
    [self searchWithTerm:text];
}

- (void) searchWithTerm:(NSString*) text {
    if(text && [text length] != 0) {
        NSLog(@"Search term typed %@", text);
        self.searchTerm = text;
    } else {
        self.searchTerm = @"Restaurants";
    }
    [self yelpSearch:self.searchTerm withCategory:@"" withDeals:[@NO boolValue] withSortMode:YelpSortModeBestMatched withDistance:nil atOffset:@0];
}

- (void) hideKeyboard {
    UISearchBar *searchBar = (UISearchBar*)[self.navigationItem titleView];
    [searchBar resignFirstResponder];
    NSString *text = [searchBar text];
    if(![text isEqualToString:self.searchTerm]) {
        [self searchWithTerm:text];
    }
}

- (void) yelpSearch:(NSString *) searchTerm withCategory:(NSString *) categoryFilter withDeals:(BOOL) isOn withSortMode:(YelpSortMode) sortMode withDistance:(NSNumber *) distance atOffset:(NSNumber *) offset {
    [JTProgressHUD show];
    [YelpBusiness searchWithTerm:searchTerm
                        sortMode:sortMode
                      categories:@[categoryFilter]
                           deals:isOn
                        distance:distance
                          offset:offset
                      completion:^(NSArray *businesses, NSError *error) {
                          [self.businesses addObjectsFromArray:businesses];
                          [self.yelpTableView reloadData];
                          [JTProgressHUD hide];
                      }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.businesses.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    YelpContentCell *cell = [self.yelpTableView dequeueReusableCellWithIdentifier:@"yelpContentCell"];
    cell.yelpBusiness = self.businesses[indexPath.row];
    return cell;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void) filtersViewController:(FiltersViewController *)filtersViewController didChangeFilters:(NSDictionary *)filters {
    self.businesses = [[NSMutableArray alloc] init];
    self.dealsOn = [filters objectForKey:@"deals_on"];
    self.sortMode = [filters objectForKey:@"sort_mode"];
    self.distance = [filters objectForKey:@"distance"];
    self.categoryFilter = [filters objectForKey:@"category_filter"];
    self.currentOffset = @0;
    YelpSortMode yelpSortMode;
    if(self.sortMode) {
        yelpSortMode = (YelpSortMode) [self.sortMode intValue];
    } else {
        yelpSortMode = YelpSortModeBestMatched;
    }
    [self yelpSearch:self.searchTerm withCategory:self.categoryFilter withDeals:[self.dealsOn boolValue] withSortMode:yelpSortMode withDistance:self.distance atOffset:self.currentOffset];
}
- (void) onFilterTapped {
    FiltersViewController *viewController = [[FiltersViewController alloc] init];
    viewController.delegate = self;
    UINavigationController *navigation = [[UINavigationController alloc] initWithRootViewController:viewController];
    [self presentViewController:navigation animated:YES completion:nil];
}

@end
